//
//  MyImagesVC.swift
//  genius-hayun
//
//  Created by 하윤2 on 20/07/2019.
//  Copyright © 2019 하윤2. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

/// '내 보관함' 화면
class MyImagesVC: ViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var myImagesVM: MyImagesVM? // 뷰모델
    
    /// collectionView의 각 셀의 이미지 높이에 대한 딕셔너리
    ///
    /// 각 셀의 IndexPath.Item을 Key로 갖고, 이미지 높이 값을 Value로 갖습니다.
    private var photoHeightDic: [Int : CGFloat] = [:]
    
    deinit {
        Log.d(output: "소멸")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 노랑 네비게이션 바 스타일로 세팅
        self.navigationController?.isNavigationBarHidden = false
        self.naviBarStyle = .yellow
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let layout = collectionView.collectionViewLayout as? DaumSearchCollectionViewLayout {
            layout.delegate = self
        }

        setupViewModel()
        setupRxCollectionView()
    }
    
    private func setupViewModel() {
        myImagesVM = MyImagesVM()
        
        // 컬렉션 뷰 바인딩
        myImagesVM?.rx_images
            .drive(collectionView.rx.items(cellIdentifier: "ImageCell", cellType: ImageCell.self)) { idx, imageInfoWithImageManager, cell in
                
                let imageInfo = imageInfoWithImageManager.imageInfo
                let imageManager = imageInfoWithImageManager.imageManager
                
                imageManager
                    .loadImage(urlStr: imageInfo.thumbNailUrl)
                    .bind(to: cell.imgView.rx.image)
                    .disposed(by: cell.disposeBag)
            }
            .disposed(by: disposeBag)
    }
    
    private func setupRxCollectionView() {
        // Item 셀렉트 시에 동작 정의
        collectionView.rx.itemSelected
            .subscribe(onNext: { [unowned self] idxPath in
                
                self.collectionView.deselectItem(at: idxPath, animated: true)
                
                guard let myImagesDetailVC = self.storyboard?.instantiateViewController(withIdentifier: "MyImagesDetailVC") as? MyImagesDetailVC else {
                    return
                }
                
                myImagesDetailVC.willMoveIdx = idxPath.item
                
                self.myImagesVM?.rx_images
                    .map { $0.map { $0.imageInfo } }
                    .drive(myImagesDetailVC.rx_items)
                    .disposed(by: myImagesDetailVC.disposeBag)
                
                // 스크롤 이동 바인딩
                myImagesDetailVC.rx_collectionViewIdx
                    .subscribe(onNext: { [unowned self] idx in
                        // FIXME: 스크롤 제대로 작동하도록 할 것
                        self.collectionView.scrollToItem(at: IndexPath(item: idx, section: 0), at: .centeredVertically, animated: false)
                    })
                    .disposed(by: myImagesDetailVC.disposeBag)
                
                self.present(myImagesDetailVC, animated: true, completion: nil)
                
            })
            .disposed(by: disposeBag)
    }

}

extension MyImagesVC: DaumSearchCollectionViewLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        heightForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat {
        
        return photoHeightDic[indexPath.item] ?? CGFloat(collectionView.frame.size.height / 5)
    }
}
