//
//  SearchVM.swift
//  genius-hayun
//
//  Created by 하윤2 on 20/07/2019.
//  Copyright © 2019 하윤2. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import ObjectMapper

/// 검색어 입력에 의하여 적절한 이미지 목록을 제공하는 ViewModel
///
/// 이미지 검색 API와 동영상 검색 API를 활용하여 이미지 URL의 정보들을 방출합니다.
/// 그리고 UIImage를 로드할 수 있도록 ImageManager도 같이 방출하여 줍니다.
class SearchVM {
    
    /// 검색 API로 검색 요청 시 응답되는 값들을 SearchVM에서 필요한 정보들로 정의한 튜플
    ///
    /// 이미지 검색 API 또는 동영상 검색 API는 응답 값으로 더 검색이 가능한지에 대한 정보를
    /// 제공해주는데, 이 튜플의 isEnd가 그에 해당합니다.
    typealias SearchResults = (thumbNailUrlList: [ImageInfo], isEnd: Bool)
    
    private let disposeBag = DisposeBag()
    
    /// 최초 검색 옵저버블
    ///
    /// 검색어를 기준으로 검색을 요청합니다.
    /// 이 옵저버블이 발행될 때 기존에 검색된 이미지 URL 목록은 사라집니다.
    private let rx_requestSearch: Observable<String>
    
    /// 현재 검색어로 더 검색을 요청할 때 발행되는 옵저버블
    ///
    /// rx_requestSearch의 최근 검색어를 기준으로 추가 검색을 요청합니다.
    private let rx_requestMore: Observable<Void>
    
    // 이미지 API 요청과 응답 관련
    private let rx_requestImage = PublishSubject<(APIManager.API, APIManager.Parameters?)>() // 이미지 API 검색 요청
    private let rx_responseImageList = PublishSubject<SearchResults>() // 이미지 API 검색 요청(rx_requestImage)에 의한 응답 방출용
    
    // 동영상 API 요청과 응답 관련
    private let rx_requestVCLip = PublishSubject<(APIManager.API, APIManager.Parameters?)>()
    private let rx_responseVCLipList = PublishSubject<SearchResults>()
    
    private let rx_totalList = BehaviorSubject<[ImageInfo]>(value: [])
    
    lazy var rx_result = self.fetchData()
    
    private let size = 10
    private var imageListPage = 1
    private var vclipListPage = 1
    
    private let apiManager = APIManager()
    private let imageManager: ImageManager
    
    
    deinit {
        Log.d(output: "소멸")
    }
    
    init(rx_requestSearch: Observable<String>, rx_requestMore: Observable<Void>) {
        self.rx_requestSearch = rx_requestSearch
        self.rx_requestMore = rx_requestMore
        self.imageManager = ImageManager(disposeBag: self.disposeBag)
        
        self.connectAPIManagerWithRx()
        self.setupRxSearch()
        self.setupRxList()
        self.setupRxMoreSearch()
    }
    
    private func fetchData() -> Driver<[(imageInfo: ImageInfo, imageManager: ImageManager)]> {
        return rx_totalList
            .map { [unowned self] imageInfo in
                return imageInfo.map { ($0, self.imageManager)}
            }
            .asDriver(onErrorJustReturn: [])
    }
    
    
    private func connectAPIManagerWithRx() {
        // 검색 요청(rx_reqeustImage) -> 응답 -> 검색 결과 방출
        apiManager.request(requestObservable: rx_requestImage)
            .subscribe(onNext: { [unowned self] data, response, err in
                
                guard err == nil else {
                    Log.d(output: "Error occur: \(String(describing: err))")
                    return
                }
                
                guard let data = data, let resp = response as? HTTPURLResponse, resp.statusCode == 200 else {
                    Log.d(output: "Response Error: \(response?.description ?? "Response is nil"))")
                    return
                }
                
                // json 테스트
                guard let json = try? JSONSerialization.jsonObject(with: data) else {
                    Log.d(output: "json to Any Error")
                    return
                }
                
                // 응답 객체 매핑
                guard let imageResp = Mapper<ImageResp>().map(JSONObject: json) else {
                    Log.d(output: "Error occur...ObjectMapper Mappaing is fail")
                    return
                }
                
                let searchResults = imageResp.documents.compactMap { imageDocument -> ImageInfo in
                    
                    let imageInfo = ImageInfo(thumbNailUrl: imageDocument.thumbnail_url, date: imageDocument.datetime ?? Date())
                    
                    return imageInfo
                }
                
                self.rx_responseImageList.onNext(SearchResults(searchResults, imageResp.is_end))
            })
            .disposed(by: disposeBag)
        
        // 검색 요청(rx_requestVCLip) -> 응답 -> 검색 결과 방출
        apiManager.request(requestObservable: rx_requestVCLip)
            .subscribe(onNext: { [unowned self] data, response, err in
                
                guard err == nil else {
                    Log.d(output: "Error occur: \(String(describing: err))")
                    return
                }
                
                guard let data = data, let resp = response as? HTTPURLResponse, resp.statusCode == 200 else {
                    Log.d(output: "Response Error: \(response?.description ?? "Response is nil"))")
                    return
                }
                    
                // json 테스트
                guard let json = try? JSONSerialization.jsonObject(with: data) else {
                    Log.d(output: "json to Any Error")
                    return
                }
                
                // 응답 객체 매핑
                guard let vclipResp = Mapper<VCLipResp>().map(JSONObject: json) else {
                    Log.d(output: "Error occur...ObjectMapper Mappaing is fail")
                    return
                }
                
                let searchResults = vclipResp.documents.compactMap { vclipDocument -> ImageInfo in
                    
                    let imageInfo = ImageInfo(thumbNailUrl: vclipDocument.thumbnail, date: vclipDocument.datetime ?? Date())
                    
                    return imageInfo
                }
                
                self.rx_responseVCLipList.onNext(SearchResults(searchResults, vclipResp.is_end))
                
            })
            .disposed(by: disposeBag)
    }
    
    // 검색, 더 보기 방출에 따른 연결 동작
    private func setupRxSearch() {
        // 검색 버튼 -> 누적 리스트 초기화 -> 검색 요청
        rx_requestSearch
            .subscribe(onNext: { [unowned self] keyword in
                // 비워줌
                self.rx_totalList.onNext([])
                self.rx_responseImageList.onNext(([], true))
                self.rx_responseVCLipList.onNext(([], true))
                
                // 페이지 초기화
                self.imageListPage = 1
                self.vclipListPage = 1
                
                let params: [String : Any] = [
                    "query": keyword,
                    "size": self.size,
                    "page": 1
                ]
                
                self.rx_requestImage.onNext((.searchImage, params))
                self.rx_requestVCLip.onNext((.searchVCLip, params))
            })
            .disposed(by: disposeBag)
    }
    
    // 응답 리스트에 따른 리스트 누적
    private func setupRxList() {
        // 응답 리스트 + 누적 리스트
        let comb_allList = Observable
            .combineLatest(rx_responseImageList, rx_responseVCLipList, rx_totalList)
        
        // 응답 리스트들 zip(동시에 두 요청이 이루어지는데 요놈들을 묶어서 소팅을 해야 함)
        let zip_respList = Observable
            .zip(rx_responseImageList, rx_responseVCLipList)

        
        // 응답 리스트들 zip 소팅 -> 현재 검색 리스트에 누적
        // 한 요청에 의해 각각의 응답 옵저버블(rx_responseImageList, rx_responseVCLipList)은 반드시 반응
        // (이 각각의 응답 옵저버블은 더 이상 검색할 것이 없는 상태여도 빈 배열을 방출함)
        zip_respList
            .withLatestFrom(comb_allList)
            .map { responseImageList, responseVCLipList, totalList in
                
                // 새 검색 또는 더 검색에 의한 이미지 목록들을 날짜 최신순으로 소팅
                let sortedList = (responseImageList.thumbNailUrlList + responseVCLipList.thumbNailUrlList)
                    .sorted {
                        // 날짜 최신순 소팅
                        return $0.date > $1.date
                    }
                
                return totalList + sortedList // 기존에 보여주던 녀석들은 순서 유지
            }
            .bind(to: rx_totalList)
            .disposed(by: disposeBag)
    }
    
    /// 더 검색 요청 구현
    private func setupRxMoreSearch() {
        
        let comb_searchImage = Observable
            .combineLatest(rx_requestSearch, rx_responseImageList, rx_responseVCLipList)
        
        // 이미지 더 검색 요청 시도
        rx_requestMore
            .withLatestFrom(comb_searchImage)
            .subscribe(onNext: { [unowned self] keyword, responseImageList, responseVCLipList in
                
                // 끝나지 않았으면 계속 더 검색 요청
                if !responseImageList.isEnd {
                    self.imageListPage += 1 // 검색 페이지 1 증가
                    
                    let params: [String : Any] = [
                        "query": keyword,
                        "size": self.size,
                        "page": self.imageListPage
                    ]
                    
                    self.rx_requestImage.onNext((.searchImage, params))
                } else {
                    // 검색이 끝났을 때 빈 배열 방출(zip으로 결과를 묶어서 최신순으로 소팅하려고...)
                    self.rx_responseImageList.onNext(([], true))
                }
                
                // 동영상 검색도 끝나지 않았으면 더 검색 요청
                if !responseVCLipList.isEnd {
                    self.vclipListPage += 1
                    
                    let params: [String : Any] = [
                        "query": keyword,
                        "size": self.size,
                        "page": self.vclipListPage
                    ]
                    
                    self.rx_requestVCLip.onNext((.searchVCLip, params))
                } else {
                    // 검색이 끝났을 때 빈 배열 방출(zip으로 결과를 묶어서 최신순으로 소팅하려고...)
                    self.rx_responseVCLipList.onNext(([], true))
                }
            })
            .disposed(by: disposeBag)
        
    }
}
