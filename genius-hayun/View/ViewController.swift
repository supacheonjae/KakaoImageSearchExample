//
//  ViewController.swift
//  genius-hayun
//
//  Created by 하윤2 on 19/07/2019.
//  Copyright © 2019 하윤2. All rights reserved.
//

import UIKit
import RxSwift

class ViewController: UIViewController {
    
    // MARK: - Rx 관련
    /// ViewController와 생명주기를 같이하는 DisposeBag
    var disposeBag = DisposeBag()
    
    
    // MARK: - Navigation Bar 관련
    /// Navigation Bar Style 구분 enum
    ///
    /// - yellow: 노랑 바탕, 검정 틴트 스타일
    enum NaviBarStyle {
        case yellow
    }
    
    
    /// Navigation Bar Style 값
    ///
    /// 현재 ViewController가 NavigationController에 속해있다면
    /// 이 값을 바꿀 때마다 Navigation Bar Style이 바뀝니다.
    ///
    /// 기본 값은 NaviBarStyle.white 입니다.
    var naviBarStyle: NaviBarStyle = .yellow {
        didSet {
            
            switch naviBarStyle {
            case .yellow:
                self.navigationController?.navigationBar.backgroundColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
                self.navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
                self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black]
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


    // MARK: - 알림창 관련
    
    /// 버튼이 하나인 알림 팝업을 보여주는 메서드
    ///
    /// 버튼의 타이틀과 제목, 내용을 지정할 수 있습니다.
    ///
    /// - Parameters:
    ///   - title: 알림 팝업의 제목
    ///   - content: 알림 팝업의 내용
    ///   - btnTitle: 알림 팝업 버튼의 텍스트
    func showOneButtonNormalAlert(title: String, content: String, btnTitle: String) {
        
        
        // 버튼들 정의
        let confirmBtn: FlexibleButtonAlertVC.AlertButton = (btnTitle, .blue, { [unowned self] in
            self.dismiss(animated: true)
        })
        
        let buttons = [confirmBtn]
        
        
        guard let alertVC = self.getAlertVC(title: title, content: content, buttons: buttons) else {
            return
        }
        
        self.present(alertVC, animated: true)
    }
    
    /// 공용 팝업 VC를 반환해주는 메서드
    ///
    /// - Parameters:
    ///   - title: 팝업의 제목
    ///   - content: 팝업의 내용
    ///   - buttons: 팝업의 버튼들
    /// - Returns: title, content, buttons에 의해 초기화 된 FlexibleButtonAlertVC를 반환
    func getAlertVC(title: String, content: String, buttons: [FlexibleButtonAlertVC.AlertButton]) -> FlexibleButtonAlertVC? {
        
        guard let alertVC = self.storyboard?.instantiateViewController(withIdentifier: "FlexibleButtonAlertVC") as? FlexibleButtonAlertVC else {
            return nil
        }
        alertVC.modalTransitionStyle = .crossDissolve
        alertVC.modalPresentationStyle = .overCurrentContext
        
        // 경보 제목
        Observable.just(title)
            .bind(to: alertVC.rx_title)
            .disposed(by: alertVC.disposeBag)
        
        // 경보 내용
        Observable.just(content)
            .bind(to: alertVC.rx_content)
            .disposed(by: alertVC.disposeBag)
        
        // 버튼들 정의
        alertVC.buttons = buttons
        
        return alertVC
    }
}

