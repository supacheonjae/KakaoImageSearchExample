//
//  FlexibleButtonAlertVC.swift
//  genius-hayun
//
//  Created by 하윤2 on 21/07/2019.
//  Copyright © 2019 하윤2. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
/**
 버튼 개수가 유동적인 팝업 View Controller 입니다.
 
 화면에 표시(present)되기 전에 buttons를 먼저 정의해주세요.
 
 제목은 rx_title, 내용은 rx_content에 옵저버블을 바인딩 시켜주세요.
 
     Observable
        .just("Just Content.")
        .bind(to: rx_content)
 
 */
class FlexibleButtonAlertVC: ViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    typealias AlertButton = (title: String, type: FlexibleButtonAlertCell.AlertButtonType, action: () -> ())
    
    /// 이 팝업의 버튼들을 담는 UICollectionView
    @IBOutlet weak var collectionView_btns: UICollectionView!
    /// 제목
    @IBOutlet weak var lbl_title: UILabel!
    /// 내용
    @IBOutlet weak var lbl_content: UILabel!
    
    /// 제목이 바인딩될 Observable
    let rx_title = BehaviorRelay<String>(value: "")
    /// 내용이 바인딩될 Observable
    let rx_content = BehaviorRelay<String>(value: "")
    
    /// 버튼의 최대 너비 값
    private let maxCellWidth: CGFloat = 111.0
    /// 버튼 사이 간격
    private let spacing: CGFloat = 10.0
    
    /// 팝업의 버튼들
    ///
    /// 이 버튼들의 개수에 따라 버튼 사이즈가 조절됩니다.
    var buttons: [AlertButton] = []
    /// 버튼(정확히는 버튼을 표시하는 셀)의 실제 너비
    private lazy var cellWidth: CGFloat = self.getCellWidth()
    
    deinit {
        Log.d(output: "소멸")
    }
    
    // MARK: - 초기화 관련
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView_btns.delegate = self
        self.collectionView_btns.dataSource = self
        
        setupRx()
    }
    
    /// Rx 바인딩
    private func setupRx() {
        rx_title.asDriver(onErrorJustReturn: "")
            .drive(lbl_title.rx.text)
            .disposed(by: disposeBag)
        
        rx_content.asDriver(onErrorJustReturn: "")
            .drive(lbl_content.rx.text)
            .disposed(by: disposeBag)
    }
    
    /// 버튼의 개수에 따라 버튼의 사이즈를 계산해서 반환해주는 메서드
    ///
    /// - Returns: 현재 버튼에 적합한 너비 값을 반환
    private func getCellWidth() -> CGFloat {
        
        guard buttons.count > 0 else {
            return 0
        }
        
        var cellWidth = (collectionView_btns.frame.size.width / CGFloat(buttons.count)) - spacing
        cellWidth = (cellWidth > maxCellWidth) ? maxCellWidth : cellWidth
        
        return cellWidth
    }
    
    // MARK:- UICollectionView protocols override
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return buttons.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FlexibleButtonAlertCell", for: indexPath) as! FlexibleButtonAlertCell
        
        let btnProperty = buttons[indexPath.row]
        cell.btn.setTitle(btnProperty.title, for: .normal)
        cell.setBtnStyle(style: btnProperty.type)
        cell.btn.rx.tap
            .subscribe({ _ in
                btnProperty.action()
            })
            .disposed(by: cell.disposeBag)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: cellWidth, height: collectionView.frame.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        let leftMargin: CGFloat = (collectionView.frame.size.width - (((cellWidth + spacing) * CGFloat(buttons.count)) - spacing)) / 2.0
        
        return UIEdgeInsets(top: 0, left: leftMargin, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return spacing
    }
}
