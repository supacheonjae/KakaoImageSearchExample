//
//  SearchDetailVC.swift
//  genius-hayun
//
//  Created by 하윤2 on 21/07/2019.
//  Copyright © 2019 하윤2. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

/// 검색을 통한 이미지 자세히 보기 화면
class SearchDetailVC: ViewController {
    
    @IBOutlet weak var btn_close: UIButton!
    @IBOutlet weak var btn_storeImage: UIButton!
    @IBOutlet weak var btn_prePage: UIButton!
    @IBOutlet weak var btn_nextPage: UIButton!
    
    /// 현재 페이지에 대한 값
    private let rx_currentPage = BehaviorRelay<Int>(value: 0)
    /// 페이지 뷰 컨트롤러의 아이템들이 될 녀석들
    let rx_items = BehaviorRelay<[ImageInfo]>(value: [])
    
    /// 이미지 저장 로직 담당 뷰 모델
    private var searchDetailVM: SearchDetailVM?
    /// 내 보관함에 이미지 저장 요청 서브젝트
    private let rx_requestStore = PublishSubject<ImageInfo>()
    
    /// 이동할 페이지
    var willMoveIdx = 0
    
    /// 스크롤 이동 용도
    let rx_collectionViewIdx = PublishSubject<Int>()
    
    deinit {
        Log.d(output: "소멸")
    }
    
    // MARK: - 초기화 관련
    override func viewDidLoad() {
        super.viewDidLoad()

        setupRx()
        setupViewModel()
    }
    
    private func setupRx() {
        // 닫기 버튼
        btn_close.rx.tap
            .withLatestFrom(rx_currentPage)
            .subscribe(onNext: { [unowned self] currentIdx in
                self.dismiss(animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
        
        // 내 보관함에 저장 버튼
        let comb_itemsAndIndex = Observable.combineLatest(rx_items, rx_currentPage)
        btn_storeImage.rx.tap
            .withLatestFrom(comb_itemsAndIndex)
            .subscribe(onNext: { [unowned self] items, currentIdx in
                self.rx_requestStore.onNext(items[currentIdx])
            })
            .disposed(by: disposeBag)
        
        rx_currentPage
            .subscribe(onNext: { [unowned self] currentIdx in
                self.rx_collectionViewIdx.onNext(currentIdx)
            })
            .disposed(by: disposeBag)
    }
    
    private func setupViewModel() {
        searchDetailVM = SearchDetailVM(rx_requestStore: rx_requestStore)
        
        searchDetailVM?.rx_result
            .drive(onNext: { [unowned self] storeError in
                
                // 얼럿 띄우기
                guard let err = storeError else {
                    // 내 보관함에 저장 성공!
                    self.showOneButtonNormalAlert(title: "알림", content: "내 보관함에 저장 완료!", btnTitle: "확인")
                    return
                }
                
                self.showOneButtonNormalAlert(title: "알림", content: err.description, btnTitle: "확인")
            })
            .disposed(by: disposeBag)
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // 여기서 페이지 뷰 컨트롤러 초기화
        if let pageVC = segue.destination as? DetailPageVC {
            
            // DetailPageVC에게 이미지들 옵저버블 제공
            rx_items
                .asDriver(onErrorJustReturn: [])
                .drive(pageVC.rx_imageList)
                .disposed(by: pageVC.disposeBag)
            
            // 이전 페이지 버튼 터치 이벤트를 알려줌
            btn_prePage.rx.tap
                .subscribe(onNext: { _ in
                    pageVC.rx_prev.onNext(())
                })
                .disposed(by: pageVC.disposeBag)
            
            // 다음 페이지 버튼 터치 이벤트를 알려줌
            btn_nextPage.rx.tap
                .subscribe(onNext: { _ in
                    pageVC.rx_next.onNext(())
                })
                .disposed(by: pageVC.disposeBag)
            
            // PageVC에서만 rx_currentPage를 방출(조작)하도록 유도
            pageVC.rx_currentPage
                .bind(to: self.rx_currentPage)
                .disposed(by: pageVC.disposeBag)
            
            // 페이지 이동
            pageVC.rx_willMovePageIndex.onNext(willMoveIdx)
        }
    }
}
