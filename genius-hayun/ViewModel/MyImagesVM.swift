//
//  MyImagesVM.swift
//  genius-hayun
//
//  Created by 하윤2 on 21/07/2019.
//  Copyright © 2019 하윤2. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RealmSwift
import RxRealm

/// '내 보관함'에 저장되어 있는 이미지를 불러오는 역할 담당하는
/// ViewModel
class MyImagesVM {
    
    /// '내 보관함'에 저장되어 있는 이미지를 방출하는 Driver
    lazy var rx_images = self.fetchData()
    
    
    deinit {
        Log.d(output: "소멸")
    }
    
    private func fetchData() -> Driver<[ImageInfo]> {
        
        // 1. DB에서 이미지 정보를 가져옴
        let myImageInfos = RealmManager.instance.getAllImageInfos()
        
        return Observable.array(from: myImageInfos)
            .map { myImageInfos -> [ImageInfo] in
                
                return myImageInfos.map { myImagesInfo -> ImageInfo in
                    
                    // 2. DB에서 가져온 이미지 정보로 이미지 File을 찾아서 ImageInfo 객체를 생성해서 방출
                    let image = DaumImageFileManager.shared.searchStoredImage(filePath: myImagesInfo.filePath)
                    let imageInfo = ImageInfo(thumbNailUrl: myImagesInfo.thumbnailUrl, date: myImagesInfo.storeDate)
                    imageInfo.rx_image.onNext(image)
                    
                    return imageInfo
                }
            }
            .asDriver(onErrorJustReturn: [])
    }
}
