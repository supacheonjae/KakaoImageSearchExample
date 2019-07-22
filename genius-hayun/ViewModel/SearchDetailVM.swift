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

class SearchDetailVM {
    
    let disposeBag = DisposeBag()
    
    /// 이미지 저장 요청 옵저버블
    private var rx_requestStore: Observable<ImageInfo>
    
    /// 내 보관함에 이미지 저장 시도 후 결과를 방출하는 드라이버
    lazy var rx_result = self.storeData()
    
    
    deinit {
        Log.d(output: "소멸")
    }
    
    init(rx_requestStore: Observable<ImageInfo>) {
        self.rx_requestStore = rx_requestStore
    }
    
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
