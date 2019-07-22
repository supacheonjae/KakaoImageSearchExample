//
//  DetailPageItemVC.swift
//  genius-hayun
//
//  Created by 하윤2 on 21/07/2019.
//  Copyright © 2019 하윤2. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class DetailPageItemVC: ViewController {
    
    @IBOutlet weak var imgView: UIImageView!
    
    var rx_imageInfo = BehaviorRelay<ImageInfo?>(value: nil)
    var pageIndex: Int = 0
    
    
    deinit {
        Log.d(output: "소멸")
    }
    
    // MARK: - 초기화 관련
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupRx()
    }
    
    /// 기본적인 Rx 세팅
    private func setupRx() {
        // 이미지 바인딩
        rx_imageInfo
            .flatMap { imageInfo -> Observable<UIImage?> in
                guard let imageInfo = imageInfo else {
                    return Observable.empty()
                }
                
                return imageInfo.rx_image
            }
            .bind(to: imgView.rx.image)
            .disposed(by: disposeBag)
    }

}
