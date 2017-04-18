//
//  CustomView.swift
//  ETPopupView
//
//  Created by Volley on 2017/4/17.
//  Copyright © 2017年 Elegant Team. All rights reserved.
//

import UIKit
import SnapKit

class CustomView: ETPopupView {

    let SCREEN_WIDTH = UIScreen.main.bounds.width

    override func awakeFromNib() {
        super.awakeFromNib()
        
        animationDuration = 0.3
        type = .alert
        
        ETPopupWindow.sharedWindow().touchWildToHide = true
        
        self.snp.makeConstraints { (make) in
            make.width.equalTo(SCREEN_WIDTH*0.8)
            make.height.equalTo(214)
        }
    }
    
    @IBAction func close(_ sender: UIButton) {
        hide()
    }

}
