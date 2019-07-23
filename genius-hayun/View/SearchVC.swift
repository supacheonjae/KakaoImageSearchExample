//
//  SearchVC.swift
//  genius-hayun
//
//  Created by 하윤2 on 20/07/2019.
//  Copyright © 2019 하윤2. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

/// 검색 화면
class SearchVC: ViewController, UITextFieldDelegate, UICollectionViewDelegate {
    
    @IBOutlet weak var btn_search: UIButton!
    @IBOutlet weak var txtFld_search: UITextField!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    /// 검색 버튼(btn_search)에 반응하는 Subject
    private let rx_requestSearch = PublishSubject<String>()
    /// 현재 검색어를 기반으로 더 검색 요청하는 Subject
    private let rx_requestMore = PublishSubject<Void>()
    private var searchVM: SearchVM? // 뷰모델
    
    /// collectionView의 각 셀의 이미지 높이에 대한 딕셔너리
    ///
    /// 각 셀의 IndexPath.Item을 Key로 갖고, 이미지 높이 값을 Value로 갖습니다.
    private var photoHeightDic: [Int : CGFloat] = [:]
    
    deinit {
        Log.d(output: "소멸")
    }
    
    // MARK: - 초기화 관련
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 노랑 네비게이션 바 스타일로 세팅
        self.navigationController?.isNavigationBarHidden = false
        self.naviBarStyle = .yellow
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        txtFld_search.delegate = self
        collectionView.delegate = self
        if let layout = collectionView.collectionViewLayout as? DaumSearchCollectionViewLayout {
            layout.delegate = self
        }
        
        setupRx()
        setupViewModel()
        setupRxCollectionView()
    }
    
    private func setupRx() {
        // 검색 버튼 바인딩
        btn_search.rx.tap
            .subscribe(onNext: { [unowned self] _ in
                
                self.view.endEditing(true)
                
                guard let keyword = self.txtFld_search.text, !keyword.isEmpty else { return }
                
                self.rx_requestSearch.onNext(keyword)
            })
            .disposed(by: disposeBag)
    }
    
    private func setupViewModel() {
        
        // 뷰모델 초기화 및 바인딩
        searchVM = SearchVM(rx_requestSearch: rx_requestSearch,
                            rx_requestMore: rx_requestMore.throttle(.seconds(1), scheduler: MainScheduler.instance))
        
        searchVM?.rx_result
            .asDriver(onErrorJustReturn: [])
            .drive(collectionView.rx.items(cellIdentifier: "ImageCell", cellType: ImageCell.self)) { (idxPath, imageInfoWithImageManager, cell) in

                let imageInfo = imageInfoWithImageManager.imageInfo
                let imageManager = imageInfoWithImageManager.imageManager
                
                imageManager
                    .loadImage(urlStr: imageInfo.thumbNailUrl)
                    .bind(to: cell.imgView.rx.image)
                    .disposed(by: cell.disposeBag)
                
                // 높이 값 저장
                /*
                imageManager
                    .loadImage(urlStr: imageInfo.thumbNailUrl)
                    .subscribe(onNext: { image in
                        
                        guard let img = image else {
                            return
                        }
                        
                        // 이미지가 nil 아닐 때만 높이 값 저장
                        self.photoHeightDic[idxPath] = img.size.height
                        Log.d(output: "idx(\(idxPath)) - \(self.photoHeightDic.description)")
                    })
                    .disposed(by: cell.disposeBag)
                 */
            }
            .disposed(by: disposeBag)
        
    }
    
    private func setupRxCollectionView() {
        // Item 셀렉트 시에 동작 정의
        collectionView.rx.itemSelected
            .debug()
            .subscribe(onNext: { [unowned self] idxPath in
                
                self.collectionView.deselectItem(at: idxPath, animated: true)
                
                guard let searchDetailVC = self.storyboard?.instantiateViewController(withIdentifier: "SearchDetailVC") as? SearchDetailVC else {
                    return
                }
                
                searchDetailVC.willMoveIdx = idxPath.item
                
                self.searchVM?.rx_result
                    .map { $0.map { $0.imageInfo } }
                    .drive(searchDetailVC.rx_items)
                    .disposed(by: searchDetailVC.disposeBag)
                
                self.present(searchDetailVC, animated: true) {
                    self.collectionView.scrollToItem(at: idxPath, at: .centeredVertically, animated: false)
                }
                
                // 스크롤 이동 바인딩
                searchDetailVC.rx_collectionViewIdx
                    .subscribe(onNext: { [unowned self] idx in
                        
                        // FIXME: 스크롤 제대로 작동하도록 할 것(추가 검색이 있을 때 가끔 동작 안함)
                        self.collectionView.scrollToItem(at: IndexPath(item: idx, section: 0), at: .centeredVertically, animated: false)
                        
                        if idx == 0 { return }
                        
                        let lastSectionIndex = max(0, self.collectionView.numberOfSections - 1);
                        let lastRowIndex = max(0, self.collectionView.numberOfItems(inSection: lastSectionIndex) - 1);
                        let lastIndexPath = IndexPath(row: lastRowIndex, section: lastSectionIndex)
                        
                        // 마지막 아이템이 보이려고 하면 더 검색!!
                        if idx == (lastIndexPath.item) - 1 {
                            self.rx_requestMore.onNext(())
                        }
                    })
                    .disposed(by: searchDetailVC.disposeBag)
                
            })
            .disposed(by: disposeBag)
    }

    // MARK: - 텍스트 필드 Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        self.btn_search.sendActions(for: .touchUpInside)
        return true
    }
    
    // MARK: - 컬렉션 뷰 대리자
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if indexPath.item == 0 { return }
        
        let lastSectionIndex = max(0, collectionView.numberOfSections - 1);
        let lastRowIndex = max(0, collectionView.numberOfItems(inSection: lastSectionIndex) - 1);
        let lastIndexPath = IndexPath(row: lastRowIndex, section: lastSectionIndex)
        
        // 마지막 아이템 - 2가 보이려고 하면 더 검색!!
        if indexPath.item == (lastIndexPath.item) - 2 {
            rx_requestMore.onNext(())
        }
    }
    
}

// MARK: - DaumSearchCollectionViewLayoutDelegate 구현
extension SearchVC: DaumSearchCollectionViewLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        heightForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat {
        
        Log.d(output: "idxPath(\(indexPath.description)) - \(self.photoHeightDic.description)")
        return photoHeightDic[indexPath.item] ?? CGFloat(collectionView.frame.size.height / 5)
    }
}
