//
//  DetailPageItemVM.swift
//  genius-hayun
//
//  Created by 하윤2 on 23/07/2019.
//  Copyright © 2019 하윤2. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

/// ImageInfo에 의해 UIImage를 보여주는 역할을 하는 ViewModel
class DetailPageItemVM {
    
    /// UIImage 요청 옵저버블
    private let rx_imageURL: Observable<ImageInfo>
    
    lazy var rx_image = self.loadImage()
    
    private let imageManager: ImageManager
    
    
    deinit {
        Log.d(output: "소멸")
    }
    
    init(rx_imageURL: Observable<ImageInfo>) {
        self.rx_imageURL = rx_imageURL
        self.imageManager = ImageManager(disposeBag: nil)
    }
    
    private func loadImage() -> Driver<UIImage?> {
        
        return rx_imageURL
            .flatMapLatest { [unowned self] imageInfo -> Observable<(image: UIImage?, hasCache: Bool)> in
                return self.imageManager.loadImage(urlStr: imageInfo.thumbNailUrl)
            }
            .map { $0.image }
            .asDriver(onErrorJustReturn: nil)
    }
    
}
