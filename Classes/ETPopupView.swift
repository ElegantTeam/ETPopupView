//
//  ETPopupView.swift
//  ETPopupView
//
//  Created by Volley on 2017/4/8.
//  Copyright © 2017年 Volley. All rights reserved.
//

import Foundation
import UIKit

class ETPopupWindow: UIWindow, UIGestureRecognizerDelegate {
    
    open var touchWildToHide = false
    
    open var attachView: UIView {
        return (self.rootViewController?.view!)!
    }
    
    // MARK: sharedInstance
    
    private static let shared: ETPopupWindow = {
        
        let instance = ETPopupWindow.init(frame: UIScreen.main.bounds)
        instance.rootViewController = UIViewController()
        
        return instance
    }()
    
    open class func sharedWindow() -> ETPopupWindow {
        return shared
    }
    
    // MARK: init
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        self.windowLevel = UIWindowLevelStatusBar + 1
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(actionTap(gesture:)))
        tap.cancelsTouchesInView = false
        tap.delegate = self
        self.addGestureRecognizer(tap)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func cacheWindow() {
        self.makeKeyAndVisible()
        
        (UIApplication.shared.delegate?.window!)!.makeKeyAndVisible()
        self.attachView.mm_dimBackgroundView.isHidden = false
        self.isHidden = true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return touch.view == self.attachView.mm_dimBackgroundView
    }
    
    @objc private func actionTap(gesture: UITapGestureRecognizer) {
        if touchWildToHide && !self.mm_dimBackgroundAnimating {
            self.attachView.mm_dimBackgroundView.subviews.forEach({ (view) in
                if view.isKind(of: ETPopupView.self) {
                    (view as! ETPopupView).hide()
                }
            })
        }
    }
    
}

enum ETPopupType {
    case alert
    case sheet
    case custom
}

typealias ETpopupBlock = (ETPopupView) -> Void
typealias ETPopupCompletionBlock = (ETPopupView, Bool) -> Void

class ETPopupView: UIView {
    
    open var type: ETPopupType = .alert {
        didSet {
            switch type {
            case .alert:
                self.showAnimation = alertShowAnimation()
                self.hideAnimation = alertHideAnimation()
                
            case .sheet:
                self.showAnimation = sheetShowAnimation()
                self.hideAnimation = sheetHideAnimation()
                
            case .custom:
                self.showAnimation = customShowAnimation()
                self.hideAnimation = customHideAnimation()
            }
        }
    }
    
    open var animationDuration: TimeInterval = 0.3 {
        didSet {
            attachedView.mm_dimAnimationDuration = animationDuration
        }
    }
    
    open var visible: Bool {
        
        return self.attachedView.mm_dimBackgroundView.isHidden
    }
    
    open var attachedView: UIView = ETPopupWindow.sharedWindow().attachView
    
    open var showCompletionBlock: ETPopupCompletionBlock?
    open var hideCompletionBlock: ETPopupCompletionBlock?
    
    open var showAnimation: ETpopupBlock?
    open var hideAnimation: ETpopupBlock?
    
    // MARK: noti.name
    private struct ETPopupNoti {
        static var HideAllNotification = "ETPopupNoti.HideAllNotification"
    }
    
    // MARK: init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        NotificationCenter.default.addObserver(self, selector: #selector(notifyHideAll(noti:)), name: NSNotification.Name(rawValue: ETPopupNoti.HideAllNotification), object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        NotificationCenter.default.addObserver(self, selector: #selector(notifyHideAll(noti:)), name: NSNotification.Name(rawValue: ETPopupNoti.HideAllNotification), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue:ETPopupNoti.HideAllNotification), object: nil)
    }
    
    @objc private func notifyHideAll(noti: Notification) {
        
        guard let _ = noti.object as? ETPopupView else {
            return
        }
        
        hide()
    }
    
    open class func hideAll() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue:ETPopupNoti.HideAllNotification), object: ETPopupView.self)
    }
    
    open func hide() {
        
        hideWithBlock(nil)
    }
    
    open func show() {
        
        showWithBlock(nil)
    }
    
    open func showWithBlock(_ block: ETPopupCompletionBlock?) {
        
        self.showCompletionBlock = block
        self.attachedView.mm_showDimBackground()
        
        if let show = self.showAnimation {
            show(self)
        }
    }
    
    open func hideWithBlock(_ block: ETPopupCompletionBlock?) {
        
        self.showCompletionBlock = block
        self.attachedView.mm_hideDimBackground()
        
        if let hide = self.hideAnimation {
            hide(self)
        }
    }
    
    // MARK: 默认动画
    private func alertShowAnimation() -> ETpopupBlock {
        
        let block: (ETPopupView) -> Void = {
            [weak self] (popupView: ETPopupView) in
            
            if self?.superview == nil {
                self?.attachedView.mm_dimBackgroundView.addSubview(self!)
                self?.snp.makeConstraints({ (make) in
                    make.center.equalTo((self?.attachedView)!)
                })
                
                self?.superview?.layoutIfNeeded()
            }
            
            self?.layer.transform = CATransform3DMakeScale(1.2, 1.2, 1.2)
            self?.alpha = 0.0
            
            UIView.animate(withDuration: (self?.animationDuration)!,
                           delay: 0.0,
                           options: [.curveEaseOut, .beginFromCurrentState],
                           animations: {
                            
                            self?.layer.transform = CATransform3DIdentity
                            self?.alpha = 1.0
                
                            }, completion: { (finished) in
                                
                                if let complete = self?.showCompletionBlock {
                                    complete(self!, finished)
                                }
                                
                            })
            
        }
        
        return block
    }
    
    private func alertHideAnimation() -> ETpopupBlock {
        
        let block: (ETPopupView) -> Void = {
            [weak self] (popupView: ETPopupView) in
            
            UIView.animate(withDuration: (self?.animationDuration)!,
                           delay: 0.0,
                           options: [.curveEaseIn, .beginFromCurrentState],
                           animations: {
                
                                self?.alpha = 0.0;
                
                            }, completion: { (finished) in
                                
                                if finished {
                                    self?.removeFromSuperview()
                                }
                                
                                if let complete = self?.hideCompletionBlock {
                                    
                                    complete(self!, finished)
                                }
                                
                            })
            
        }
        
        
        return block
    }
    
    private func sheetShowAnimation() -> ETpopupBlock {
        
        let block: (ETPopupView) -> Void = {
            [weak self] (popupView: ETPopupView) in
            
            if self?.superview == nil {
                
                self?.attachedView.mm_dimBackgroundView.addSubview(self!)
                self?.snp.makeConstraints({ (make) in
                    make.centerX.equalTo((self?.attachedView)!)
                    make.bottom.equalTo((self?.attachedView.snp.bottom)!).offset((self?.attachedView.frame.size.height)!)
                })
                
                self?.superview?.layoutIfNeeded()
            }
            
            UIView.animate(withDuration: (self?.animationDuration)!,
                           delay: 0.0,
                           options: [.curveEaseOut, .beginFromCurrentState],
                           animations: {
                            
                            self?.snp.updateConstraints({ (make) in
                                make.bottom.equalTo((self?.attachedView.snp.bottom)!).offset(0)
                            })
                            
                            self?.superview?.layoutIfNeeded()
                
                            }, completion: { (finished) in
                                
                                if let complete = self?.showCompletionBlock {
                                    complete(self!, finished)
                                }
                
                            })
            
        }
        
        
        return block
    }
    
    private func sheetHideAnimation() -> ETpopupBlock {
        
        let block: (ETPopupView) -> Void = {
            [weak self] (popupView: ETPopupView) in
            
            UIView.animate(withDuration: (self?.animationDuration)!,
                           delay: 0.0,
                           options: [.curveEaseIn, .beginFromCurrentState],
                           animations: {
                            
                            self?.snp.updateConstraints({ (make) in
                                make.bottom.equalTo((self?.attachedView.snp.bottom)!).offset((self?.attachedView.frame.size.height)!)
                            })
                            
                            self?.superview?.layoutIfNeeded()
                
                            }, completion: { (finished) in
                                
                                if finished {
                                    self?.removeFromSuperview()
                                }
                                
                                if let complete = self?.hideCompletionBlock {
                                    complete(self!, finished)
                                }
                
                            })
            
        }
        
        return block
    }
    
    private func customShowAnimation() -> ETpopupBlock {
        
        let block: (ETPopupView) -> Void = {
            [weak self] _ in
            
            if self?.superview == nil {
               self?.attachedView.mm_dimBackgroundView.addSubview(self!)
                self?.snp.makeConstraints({ (make) in
                    make.centerX.equalTo((self?.attachedView)!).offset(0)
                    make.centerY.equalTo((self?.attachedView)!).offset((self?.attachedView.bounds.size.height)!)
                })
                
                self?.superview?.layoutIfNeeded()
            }
            
            UIView.animate(withDuration: (self?.animationDuration)!,
                           delay: 0.0,
                           options: [.curveEaseOut, .beginFromCurrentState],
                           animations: {
                
                            self?.snp.updateConstraints({ (make) in
                                make.centerY.equalTo((self?.attachedView)!).offset(0)
                            })
                            self?.superview?.layoutIfNeeded()
                            
                            }, completion: { (finished) in
                                
                                if let complete = self?.showCompletionBlock {
                                    complete(self!, finished)
                                }
                
                            })
            
            
        }
        
        return block
    }
    
    private func customHideAnimation() -> ETpopupBlock {
        
        let block: (ETPopupView) -> Void = {
            [weak self] _ in
            
            UIView.animate(withDuration: (self?.animationDuration)!,
                           delay: 0.0,
                           options: [.curveEaseIn, .beginFromCurrentState],
                           animations: {
                            
                            self?.snp.updateConstraints({ (make) in
                                make.centerY.equalTo((self?.attachedView)!).offset((self?.attachedView.bounds.size.height)!)
                                
                            })
                            self?.superview?.layoutIfNeeded()
                
                            }, completion: { (finished) in
                                
                                if finished {
                                    self?.removeFromSuperview()
                                }
                                
                                if let complete = self?.hideCompletionBlock {
                                    complete(self!, finished)
                                }
                
                            })
            
        }
        
        
        return block
    }
    
}
