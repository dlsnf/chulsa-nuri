//
//  NaviController.swift
//  LovePet
//
//  Created by Nu-Ri Lee on 2017. 5. 29..
//  Copyright © 2017년 nuri lee. All rights reserved.
//

import UIKit


class PinReporterNaviController : UINavigationController{
    
    override var shouldAutorotate: Bool{
        
        if UIDevice.current.userInterfaceIdiom == .phone{
            return true;
        }else{
            return true;
        }
    }
    
    //화면 회전 고정
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        if UIDevice.current.userInterfaceIdiom == .phone{
            return [UIInterfaceOrientationMask.portrait]
        }else{
            return [UIInterfaceOrientationMask.all]
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
    }
}



