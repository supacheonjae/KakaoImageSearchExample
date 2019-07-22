//
//  UIView.swift
//  genius-hayun
//
//  Created by 하윤2 on 20/07/2019.
//  Copyright © 2019 하윤2. All rights reserved.
//

import UIKit

@IBDesignable extension UIView {
    
    /// 그림자 색상
    ///
    /// 기본 색상은 검정색입니다.
    @IBInspectable var shadowColor: UIColor? {
        set {
            layer.shadowColor = newValue?.cgColor
        }
        get {
            guard let color = layer.shadowColor else {
                return nil
            }
            
            return UIColor(cgColor: color)
        }
    }
    
    /// 그림자 투명도 값
    ///
    /// 0.0(투명)부터 1.0(불투명)까지의 값을 설정해주세요.
    /// 기본 값은 0.0입니다.
    @IBInspectable var shadowOpacity: Float {
        set {
            layer.shadowOpacity = newValue
        }
        get {
            return layer.shadowOpacity
        }
    }
    
    /// 그림자 위치 값
    ///
    /// 기본 값은 (0.0, -3.0)입니다.
    @IBInspectable var shadowOffset: CGPoint {
        set {
            layer.shadowOffset = CGSize(width: newValue.x, height: newValue.y)
        }
        get {
            return CGPoint(x: layer.shadowOffset.width, y: layer.shadowOffset.height)
        }
    }
    
    /// 그림자 Radius 값
    ///
    /// 기본 값은 3.0입니다.
    @IBInspectable var shadowRadius: CGFloat {
        set {
            layer.shadowRadius = newValue
        }
        get {
            return layer.shadowRadius
        }
    }
    
    /// 테두리 Radius 값
    ///
    /// 기본 값은 0.0입니다.
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    /// 테두리 두께 값
    ///
    /// 기본 값은 0.0입니다.
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    /// 테두리 색상
    ///
    /// 기본 색상은 검정색입니다.
    @IBInspectable var borderColor: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
}
