//
//  UIView+ETPopupView.swift
//  ETPopupView
//
//  Created by Volley on 2017/4/8.
//  Copyright © 2017年 Elegant Team. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

extension UIView {
    
    private struct AssociatedKeys {
        static var mm_dimBackgroundViewKey = "ETPopView.mm_dimBackgroundViewKey"
        static var mm_dimAnimationDurationKey = "ETPopView.mm_dimAnimationDurationKey"
        static var mm_dimReferenceCountKey = "ETPopView.mm_dimReferenceCountKey"
        static var mm_dimBackgroundAnimatingKey = "ETPopView.mm_dimBackgroundAnimatingKey"
    }
    
    internal var mm_dimBackgroundView: UIView {
        
        guard let view = objc_getAssociatedObject(self, &AssociatedKeys.mm_dimBackgroundViewKey) as? UIView else {
            
            let dimView = UIView()
            self.addSubview(dimView)
            dimView.snp.makeConstraints({ (make) in
                make.edges.equalTo(self)
            })
            dimView.alpha = 0.0
            dimView.backgroundColor = UIColor(colorHex: 0x000000,alpha: 0.5)
            dimView.layer.zPosition = CGFloat(FLT_MAX)
            
            self.mm_dimAnimationDuration = 0.3
            
            objc_setAssociatedObject(self, &AssociatedKeys.mm_dimBackgroundViewKey, dimView, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            return dimView
        }
        
        return view
    }
    
    internal var mm_dimAnimationDuration: TimeInterval {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.mm_dimAnimationDurationKey) as! TimeInterval
        }
        
        set (duration) {
            objc_setAssociatedObject(self, &AssociatedKeys.mm_dimAnimationDurationKey, duration, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    internal var mm_dimBackgroundAnimating: Bool {
        get {
            
            guard let animating = objc_getAssociatedObject(self, &AssociatedKeys.mm_dimBackgroundAnimatingKey) as? Bool else {
                
                let initialAnimating = false
                
               objc_setAssociatedObject(self, &AssociatedKeys.mm_dimBackgroundAnimatingKey, initialAnimating, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                
                return initialAnimating
            }
            
            return animating
        }
        
        set (animating) {
            objc_setAssociatedObject(self, &AssociatedKeys.mm_dimBackgroundAnimatingKey, animating, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private var mm_dimReferenceCount: Int {
        
        get {
            guard let count = objc_getAssociatedObject(self, &AssociatedKeys.mm_dimReferenceCountKey) as? Int else {
                
                let initialCount: Int = 0
                
                objc_setAssociatedObject(self, &AssociatedKeys.mm_dimReferenceCountKey, initialCount, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                
                return initialCount
            }
            
            return count
        }
        
        set (count) {
            objc_setAssociatedObject(self, &AssociatedKeys.mm_dimReferenceCountKey, count, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    internal func mm_showDimBackground() {
        mm_dimReferenceCount += 1;
        
        if mm_dimReferenceCount > 1 {
            return
        }
        
        mm_dimBackgroundView.isHidden = false
        mm_dimBackgroundAnimating = true
        
        if self == ETPopupWindow.sharedWindow().attachView {
            ETPopupWindow.sharedWindow().isHidden = false
            ETPopupWindow.sharedWindow().makeKeyAndVisible()
            
        } else if self.isKind(of: UIWindow.self) {
            
            self.isHidden = false
            (self as! UIWindow).makeKeyAndVisible()
            
        } else {
            self.bringSubview(toFront: self.mm_dimBackgroundView)
        }
        
        UIView.animate(withDuration: self.mm_dimAnimationDuration,
                       delay: 0,
                       options: [.curveEaseOut, .beginFromCurrentState],
                       animations: {
                        
                        self.mm_dimBackgroundView.alpha = 1.0
                        
        }) { (finished) in
            
            if finished {
                self.mm_dimBackgroundAnimating = false
            }
        }
        
    }
    
    internal func mm_hideDimBackground() {
        mm_dimReferenceCount -= 1
        
        if mm_dimReferenceCount > 0 {
            return
        }
        
        mm_dimBackgroundAnimating = true
        
        UIView.animate(withDuration: mm_dimAnimationDuration,
                       delay: 0,
                       options: [.curveEaseIn, .beginFromCurrentState],
                       animations: {
                        
                        self.mm_dimBackgroundView.alpha = 0.0
                        
        }) { (finished) in
            
            if finished {
                self.mm_dimBackgroundAnimating = false
                
                if self == ETPopupWindow.sharedWindow().attachView {
                    
                    ETPopupWindow.sharedWindow().isHidden = true
                    UIApplication.shared.delegate?.window??.makeKey()
                    
                } else if self == ETPopupWindow.sharedWindow() {
                    
                    self.isHidden = true
                    UIApplication.shared.delegate?.window??.makeKey()
                }
                
            }
        }
    }
    
}

fileprivate extension UIColor {
    convenience init(colorHex: UInt,alpha: CGFloat) {
        self.init(
            red: CGFloat((colorHex & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((colorHex & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(colorHex & 0x0000FF) / 255.0,
            alpha: alpha
        )
    }
}
