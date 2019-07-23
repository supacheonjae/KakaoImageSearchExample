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

/// '내 보관함'의 이미지를 앨범으로 보내는 역할을 담당하는 ViewModel
class MyImageDetailVM: NSObject {
    
    private let disposeBag = DisposeBag()
    
    /// 앨범에 저장 요청 옵저버블
    private var rx_sendAlbum: Observable<ImageInfo>
    
    /// 앨범에 저장 시도 후 결과를 방출하는 Driver
    lazy var rx_result = self.sendAlbum()
    
    /// 결과 알림용 Subject
    private let rx_completion = PublishSubject<SendAlbumError?>()
    
    private let imageManager: ImageManager
    
    
    deinit {
        Log.d(output: "소멸")
    }
    
    init(rx_sendAlbum: Observable<ImageInfo>) {
        self.rx_sendAlbum = rx_sendAlbum
        self.imageManager = ImageManager(disposeBag: nil) // MyImagesVM에서 유지되는 imageManager가 캐시를 사용하고 있을 수 있으므로 매개변수를 nil로...
    }
    
    private func sendAlbum() -> Driver<SendAlbumError?> {
        
        rx_sendAlbum
            .debug()
            .flatMapLatest { [unowned self] imageInfo -> Observable<UIImage?> in
                return self.imageManager.loadImage(urlStr: imageInfo.thumbNailUrl)
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
    
    /// 앨범으로 사진 전송 시도 후 호출되는 메서드
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
