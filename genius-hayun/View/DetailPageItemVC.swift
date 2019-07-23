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

/// DetailPageVC의 각 페이지 내용물이 되는 VC
class DetailPageItemVC: ViewController {
    
    @IBOutlet weak var imgView: UIImageView!
    
    let rx_imageInfo = BehaviorRelay<ImageInfo?>(value: nil)
    /// 이 화면의 페이지 인덱스
    var pageIndex: Int = 0
    
    private var detailPageItemVM: DetailPageItemVM?
    
    deinit {
        Log.d(output: "소멸")
    }
    
    // MARK: - 초기화 관련
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViewModel()
    }
    
    private func setupViewModel() {
        
        let rx_filteredImageInfo = rx_imageInfo
            .compactMap { $0 }
        
        detailPageItemVM = DetailPageItemVM(rx_imageURL: rx_filteredImageInfo)
        
        // 이미지 바인딩
        detailPageItemVM?.rx_image
            .drive(imgView.rx.image)
            .disposed(by: disposeBag)
    }

}
