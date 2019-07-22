//
//  ImageInfo.swift
//  genius-hayun
//
//  Created by 하윤2 on 21/07/2019.
//  Copyright © 2019 하윤2. All rights reserved.
//

import UIKit
import RxSwift

class ImageInfo {

    var thumbNailUrl: String
    var date: Date
    
    // 이미지 로드는 비동기이므로 rx로 마련함
    let rx_image: BehaviorSubject<UIImage?>
    
    // Data타입 변환 관련
    var imgType = ImageType.jpg
    /// 이미지 추출하여 파일로 저장하기 위하여
    private var image: UIImage?
    var data: Data? {
        
        switch imgType {
        case .jpg:
            return image?.jpegData(compressionQuality: 1.0)
        case .png:
            return image?.pngData()
        }
    }
    
    var fileName: String {
        return thumbNailUrl.filter { $0 != "/" } + "." + imgType.rawValue
    }
    
    let disposeBag = DisposeBag()
    
    
    init(thumbNailUrl: String, date: Date) {
        self.thumbNailUrl = thumbNailUrl
        self.date = date
        self.rx_image = BehaviorSubject<UIImage?>(value: nil)
        
        self.rx_image
            .subscribe(onNext: { [unowned self] img in
                self.image = img
            })
            .disposed(by: disposeBag)
    }

}

extension ImageInfo {
    // 이미지 확장자
    enum ImageType: String {
        case jpg = "jpg"
        case png = "png"
    }
}
