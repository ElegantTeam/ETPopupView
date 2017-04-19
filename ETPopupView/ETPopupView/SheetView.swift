//
//  SheetView.swift
//  ETPopupView
//
//  Created by Volley on 2017/4/19.
//  Copyright © 2017年 Elegant Team. All rights reserved.
//

import UIKit
import SnapKit

class SheetView: ETPopupView {

    override func awakeFromNib() {
        super.awakeFromNib()
        
        animationDuration = 0.3
        type = .sheet
        
        ETPopupWindow.sharedWindow().touchWildToHide = true
        
        self.snp.makeConstraints { (make) in
            make.width.equalTo(SCREEN_WIDTH)
            make.height.equalTo(360)
        }
    }
    
    @IBAction func closeAction(_ sender: UIButton) {
        hide()
    }
    
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
