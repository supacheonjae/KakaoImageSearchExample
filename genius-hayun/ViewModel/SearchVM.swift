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

class SearchVM {
    
    typealias SearchResults = (thumbNailUrlList: [ImageInfo], isEnd: Bool)
    
    let disposeBag = DisposeBag()
    
    private var rx_requestSearch: Observable<String>
    private var rx_requestMore: Observable<Void>
    
    // 이미지 API 요청과 응답 관련
    private var rx_requestImage = PublishSubject<(APIManager.API, APIManager.Parameters?)>()
    private var rx_responseImageList = PublishSubject<SearchResults>()
    private var rx_moreImageSearch = PublishSubject<Void>()
    
    // 동영상 API 요청과 응답 관련
    private var rx_requestVCLip = PublishSubject<(APIManager.API, APIManager.Parameters?)>()
    private var rx_responseVCLipList = PublishSubject<SearchResults>()
    private var rx_moreVCLipSearch = PublishSubject<Void>()
    
    private var rx_totalList = BehaviorSubject<[ImageInfo]>(value: [])
    
    lazy var rx_result = self.fetchData()
    
    private let size = 10
    private var imageListPage = 1
    private var vclipListPage = 1
    
    private let apiManager = APIManager()
    private let imageManager = ImageManager()
    
    
    deinit {
        Log.d(output: "소멸")
    }
    
    init(rx_requestSearch: Observable<String>, rx_requestMore: Observable<Void>) {
        self.rx_requestSearch = rx_requestSearch
        self.rx_requestMore = rx_requestMore
        
        self.connectAPIManager()
        self.setupRxBtn()
        self.setupRxList()
        self.setupMoreSearchRx()
    }
    
    private func fetchData() -> Driver<[ImageInfo]> {
        
        return rx_totalList
            .asDriver(onErrorJustReturn: [])
    }
    
    private func connectAPIManager() {
        // 검색 요청(rx_reqeustImage) -> 응답 -> 검색 결과 방출
        apiManager.request(requestObservable: rx_requestImage)
            .subscribe(onNext: { [unowned self] data, response, err in
                
                guard err == nil else {
                    Log.d(output: "Error occur: \(String(describing: err))")
                    return
                }
                
                if let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 {
                    
                    // json 테스트
                    guard let json = try? JSONSerialization.jsonObject(with: data) else {
                        Log.d(output: "json to Any Error")
                        return
                    }
                    
                    // 응답 객체 매핑
                    guard let imageResp = Mapper<ImageResp>().map(JSONObject: json) else {
                        return
                    }
                    
                    let searchResults = imageResp.documents.compactMap { imageInfo -> ImageInfo in
                        
                        let imageRef = ImageInfo(thumbNailUrl: imageInfo.thumbnail_url, date: imageInfo.datetime ?? Date())
                        self.imageManager.loadImage(imageInfo: imageRef)
                        
                        return imageRef
                    }
                    
                    self.rx_responseImageList.onNext(SearchResults(searchResults, imageResp.is_end))
                }
            })
            .disposed(by: disposeBag)
        
        // 검색 요청(rx_requestVCLip) -> 응답 -> 검색 결과 방출
        apiManager.request(requestObservable: rx_requestVCLip)
            .subscribe(onNext: { [unowned self] data, response, err in
                
                guard err == nil else {
                    Log.d(output: "Error occur: \(String(describing: err))")
                    return
                }
                
                if let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 {
                    
                    // json 테스트
                    guard let json = try? JSONSerialization.jsonObject(with: data) else {
                        Log.d(output: "json to Any Error")
                        return
                    }
                    
                    // 응답 객체 매핑
                    guard let vclipResp = Mapper<VCLipResp>().map(JSONObject: json) else {
                        return
                    }
                    
                    let searchResults = vclipResp.documents.compactMap { vclipInfo -> ImageInfo in
                        
                        let imageRef = ImageInfo(thumbNailUrl: vclipInfo.thumbnail, date: vclipInfo.datetime ?? Date())
                        self.imageManager.loadImage(imageInfo: imageRef)
                        
                        return imageRef
                    }
                    
                    self.rx_responseVCLipList.onNext(SearchResults(searchResults, vclipResp.is_end))
                }
            })
            .disposed(by: disposeBag)
    }
    
    // 검색, 더 보기 방출에 따른 연결 동작
    private func setupRxBtn() {
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
        
        // 더 보기 -> 이미지 더 검색 요청
        rx_requestMore
            .bind(to: rx_moreImageSearch)
            .disposed(by: disposeBag)
 
        // 더 보기 -> 동영상 더 검색 요청
        rx_requestMore
            .bind(to: rx_moreVCLipSearch)
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

        
        // 검색 요청(rx_requestSearch, rx_moreImageSearch) -> 응답 리스트들 zip 소팅 -> 현재 검색 리스트에 누적
        zip_respList
            .withLatestFrom(comb_allList)
            .map { responseImageList, responseVCLipList, totalList in
                
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
    
    // 더 검색 요청 구현
    private func setupMoreSearchRx() {
        
        let comb_searchImage = Observable
            .combineLatest(rx_requestSearch, rx_responseImageList, rx_responseVCLipList)
        
        // 이미지 더 검색 요청 시도
        rx_moreImageSearch
            .withLatestFrom(comb_searchImage)
            .subscribe(onNext: { [unowned self] keyword, responseImageList, responseVCLipList in
                
                // 끝나지 않았으면 계속 더 검색 요청
                if !responseImageList.isEnd {
                    self.imageListPage += 1
                    
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
