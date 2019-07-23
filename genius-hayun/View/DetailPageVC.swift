//
//  DetailPageVC.swift
//  genius-hayun
//
//  Created by 하윤2 on 21/07/2019.
//  Copyright © 2019 하윤2. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

/// 상세보기 화면의 페이징 부분의 VC
class DetailPageVC: UIPageViewController,  UIPageViewControllerDataSource {
    
    let disposeBag = DisposeBag()
    
    /// Rx기반의 UIPageViewControllerDataSource를 구현하지 못했으므로 동기적인 작업에 사용할 DataSoruce 선언
    private var imageList: [ImageInfo] = []
    
    let rx_imageList = BehaviorRelay<[ImageInfo]>(value: [])
    
    /// 현재 보여지는 페이지의 인덱스 값을 발행하는 목적
    let rx_currentPage = BehaviorSubject<Int>(value: 0)
    
    /// 이 화면이 보여질 때 첫 페이지를 선택하는 Subject
    let rx_willMovePageIndex = BehaviorSubject<Int>(value: 0)
    
    
    // 이전, 다음 페이지 버튼 연동을 위한 rx
    /// 이전 페이지 이동을 위한 Subject
    ///
    /// 외부에서 이전 페이지로 이동을 원할 때 이 Subject를 활용하세요.
    let rx_prev = PublishSubject<Void>()
    
    /// 다음 페이지 이동을 위한 Subject
    ///
    /// 외부에서 다음 페이지로 이동을 원할 때 이 Subject를 활용하세요.
    let rx_next = PublishSubject<Void>()
    
    deinit {
        Log.d(output: "소멸")
    }
    
    // MARK: - 초기화 관련
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dataSource = self
        
        setupRx()
        movePageByWillMovePageIndex()
    }
    
    // Rx 세팅
    private func setupRx() {
        // 이미지 리스트 구독
        rx_imageList
            .subscribe(onNext: { [unowned self] imageList in
                self.imageList = imageList
            })
            .disposed(by: disposeBag)
        
        
        // 이전, 다음 페이지 rx 세팅
        let rx_currentPageOnImageList = Observable
            .combineLatest(rx_currentPage, rx_imageList)
            .asDriver(onErrorDriveWith: .empty())
        
        rx_prev
            .withLatestFrom(rx_currentPageOnImageList)
            .subscribe(onNext: { [unowned self] (idx, list) in
                
                guard idx > 0 else {
                    return
                }
                
                let viewControllers = [self.viewControllerAtIndex(index: idx - 1)]
                
                self.setViewControllers(
                    viewControllers as? [UIViewController],
                    direction: .reverse,
                    animated: true,
                    completion: nil)
                
                self.rx_currentPage.onNext(idx - 1)
            })
            .disposed(by: disposeBag)
        
        rx_next
            .withLatestFrom(rx_currentPageOnImageList)
            .subscribe(onNext: { [unowned self] (idx, list) in
                
                guard idx < list.count - 1 else {
                    return
                }
                let viewControllers = [self.viewControllerAtIndex(index: idx + 1)]
                
                self.setViewControllers(
                    viewControllers as? [UIViewController],
                    direction: .forward,
                    animated: true,
                    completion: nil)
                
                self.rx_currentPage.onNext(idx + 1)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK:- 기능성 메서드
    /// 이동할 페이지가 예약되어 있을 때
    private func movePageByWillMovePageIndex() {
        let rx_willMoveIndex = Observable.combineLatest(rx_willMovePageIndex, rx_imageList)
        
        Observable.just(())
            .withLatestFrom(rx_willMoveIndex)
            .subscribe(onNext: { [unowned self] index, imageList in
                
                if index < 0 || index >= imageList.count {
                    return
                }
                
                guard let contentVC = self.viewControllerAtIndex(index: index) else {
                    return
                }
                
                let viewControllers = [contentVC]
                
                self.setViewControllers(
                    viewControllers,
                    direction: .forward,
                    animated: false,
                    completion: nil)
                
                self.rx_currentPage.onNext(index)
            })
            .disposed(by: DisposeBag())
    }
    
    /// 특정 인덱스에 따라 DetailPageItemVC를 초기화 후 반환해주는 메서드
    ///
    /// - Parameter index: 페이지 인덱스
    /// - Returns: 만약 DetailPageVC의 imageList가 지정된 인덱스의 값을 가지고 있다면 DetailPageItemVC를 반환,
    ///            imageList에 존재하지 않는 인덱스라면 nil 반환
    private func viewControllerAtIndex(index: Int) -> DetailPageItemVC? {
        
        if index < 0 || index >= imageList.count {
            return nil
        }
        
        guard let contentVC = self.storyboard?.instantiateViewController(withIdentifier: "DetailPageItemVC") as? DetailPageItemVC else {
            return nil
        }
        
        contentVC.pageIndex = index
        
        Observable.just(imageList[index])
            .bind(to: contentVC.rx_imageInfo)
            .disposed(by: contentVC.disposeBag)
        
        return contentVC
    }
    
    // MARK: - DataSource
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let contentVC = viewController as? DetailPageItemVC else {
            return nil
        }
        
        self.rx_currentPage.onNext(contentVC.pageIndex)
        return viewControllerAtIndex(index: contentVC.pageIndex - 1)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard let contentVC = viewController as? DetailPageItemVC else {
            return nil
        }
        
        self.rx_currentPage.onNext(contentVC.pageIndex)
        return viewControllerAtIndex(index: contentVC.pageIndex + 1)
    }
    
}
