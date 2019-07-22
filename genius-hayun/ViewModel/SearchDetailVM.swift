//
//  SearchDetailVM.swift
//  genius-hayun
//
//  Created by 하윤2 on 21/07/2019.
//  Copyright © 2019 하윤2. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

/// 검색된 이미지 자세히 보기 화면에서 현재 내가 보고 있는 이미지를
/// '내 보관함'에 저장할 수 있도록 뒤처리를 해주는 ViewModel
class SearchDetailVM {
    
    /// 이미지 저장 요청 옵저버블
    private let rx_requestStore: Observable<ImageInfo>
    
    /// 내 보관함에 이미지 저장 시도 후 결과를 방출하는 드라이버
    lazy var rx_result = self.storeData()
    
    
    deinit {
        Log.d(output: "소멸")
    }
    
    init(rx_requestStore: Observable<ImageInfo>) {
        self.rx_requestStore = rx_requestStore
    }
    
    /// rx_requestStore의 요청에 의한 '내 보관함' 저장 시도 결과 여부를 방출하는 Driver를
    /// 반환
    ///
    /// - Returns: '내 보관함' 저장 시도 결과 여부를 반환하는데, 반환 값이 nil이면 저장 성공!
    private func storeData() -> Driver<StoreError?> {
        
        return rx_requestStore
            .debug()
            .flatMapLatest { imageInfo -> Observable<StoreError?> in
                // 1. DB 탐색
                let hasImage = RealmManager.instance.hasImage(urlStr: imageInfo.thumbNailUrl)
                guard !hasImage else {
                    return Observable.just(.duplicate)
                }
                
                // 2. 디스크 스토리지 저장 시도
                if let error = DaumImageFileManager.shared.storeImage(imageInfo: imageInfo) {
                    return Observable.just(error)
                }
                
                // 3. 저장 깔끔. DB에도 정보 저장..
                let myImageInfo = MyImagesInfo()
                myImageInfo.thumbnailUrl = imageInfo.thumbNailUrl
                myImageInfo.filePath = imageInfo.fileName
                
                RealmManager.instance.storeImageInfo(imageInfo: myImageInfo)
                
                return Observable.just(nil)
            }
            .asDriver(onErrorJustReturn: .unknown)
    }
    
}
