//
//  MyImageDetailVM.swift
//  genius-hayun
//
//  Created by 하윤2 on 21/07/2019.
//  Copyright © 2019 하윤2. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class MyImageDetailVM: NSObject {
    
    let disposeBag = DisposeBag()
    
    /// 앨범에 저장 요청 옵저버블
    private var rx_sendAlbum: Observable<ImageInfo>
    
    /// 앨범에 저장 시도 후 결과를 방출하는 드라이버
    lazy var rx_result = self.sendAlbum()
    
    /// 결과 알림용
    let rx_completion = PublishSubject<SendAlbumError?>()
    
    deinit {
        Log.d(output: "소멸")
    }
    
    init(rx_sendAlbum: Observable<ImageInfo>) {
        self.rx_sendAlbum = rx_sendAlbum
    }
    
    private func sendAlbum() -> Driver<SendAlbumError?> {
        
        rx_sendAlbum
            .debug()
            .flatMapLatest { imageInfo -> Observable<UIImage?> in
                return imageInfo.rx_image
            }
            .subscribe(onNext: { [unowned self] image in
                
                // UIImage가 잘못됨
                guard let uiImage = image else {
                    self.rx_completion.onNext(.unknown)
                    return
                }
                
                UIImageWriteToSavedPhotosAlbum(uiImage,
                                               self,
                                               #selector(self.imageToAlbum(_:didFinishSavingWithError:contextInfo:)),
                                               nil)
                
            })
            .disposed(by: disposeBag)
        
        return rx_completion.asDriver(onErrorDriveWith: .empty())
    }
    
    @objc private func imageToAlbum(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        //사진 저장 한후
        if let err = error {
            Log.d(output: "앨범에 저장 실패.. \(err)")
            self.rx_completion.onNext(.unknown)
        } else {
            self.rx_completion.onNext(nil)
        }
    }
}
