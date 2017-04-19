//
//  ViewController.swift
//  ETPopupView
//
//  Created by Volley on 2017/4/17.
//  Copyright © 2017年 Elegant Team. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    @IBAction func alertAnimationAction(_ sender: UIButton) {
        let customView = Bundle.main.loadNibNamed("CustomView", owner: nil, options: nil)?.first as! CustomView
        customView.type = .alert
        customView.show()
    }
    
    @IBAction func customAnimationAction(_ sender: Any) {
        let customView = Bundle.main.loadNibNamed("CustomView", owner: nil, options: nil)?.first as! CustomView
        customView.type = .custom
        customView.show()
    }
    
    @IBAction func sheetAnimationAction(_ sender: Any) {
        let sheetView = Bundle.main.loadNibNamed("SheetView", owner: nil, options: nil)?.first as! SheetView
        sheetView.show()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

