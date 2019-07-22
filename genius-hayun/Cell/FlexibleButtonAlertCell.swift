//
//  FlexibleButtonAlertCell.swift
//  genius-hayun
//
//  Created by 하윤2 on 21/07/2019.
//  Copyright © 2019 하윤2. All rights reserved.
//

import UIKit
import RxSwift

/// FlexibleButtonAlertVC의 버튼이 표시되는 UICollectionView에서
/// 사용되는 커스텀 UICollectionViewCell
///
/// 이 셀의 스타일은 AlertButtonType으로 정의됩니다.
/// setBtnStyle(AlertButtonType:)로 쉽게 변경 가능합니다.
class FlexibleButtonAlertCell: UICollectionViewCell {
    
    /// FlexibleButtonAlertCell의 스타일 타입
    ///
    /// - blue: 파란색 버튼의 스타일
    /// - white: 하얀색 버튼의 스타일
    enum AlertButtonType {
        case blue
        case white
    }
    
    /// FlexibleButtonAlertCell의 버튼
    @IBOutlet weak var btn: UIButton!
    /// 파란색 버튼의 배경 이미지
    let img_alertBtnBlueType = UIImage(named: "btn_alert_cancel")
    /// 하얀색 버튼의 배경 이미지
    let img_alertBtnWhiteType = UIImage(named: "btn_alert_confirm")
    
    var disposeBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        btn.titleLabel?.adjustsFontSizeToFitWidth = true
        btn.titleLabel?.numberOfLines = 1
        btn.titleLabel?.minimumScaleFactor = 0.5
    }
    
    /// 버튼의 스타일을 지정합니다.
    ///
    /// - Parameter style: 이 스타일의 값에 따라 스타일을 지정합니다.
    func setBtnStyle(style: AlertButtonType) {
        switch style {
            
        case .blue:
            self.btn.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
            self.btn.setBackgroundImage(img_alertBtnBlueType, for: .normal)
            
        case .white:
            self.btn.setTitleColor(#colorLiteral(red: 0.4862745098, green: 0.4862745098, blue: 0.4862745098, alpha: 1), for: .normal)
            self.btn.setBackgroundImage(img_alertBtnWhiteType, for: .normal)
        }
    }
    
    override func prepareForReuse() {
        disposeBag = DisposeBag()
    }
}
