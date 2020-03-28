//
//  DeveloperViewController.swift
//  ChulsaGo
//
//  Created by nuri Lee on 2018. 1. 1..
//  Copyright © 2018년 nuri lee. All rights reserved.
//

import UIKit

class DeveloperViewController : UIViewController{
    
    
    @IBAction func leftBarButtonPress(_ sender: Any) {
        self.dismissView();
    }
    
    
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
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        //status bar
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as! UIView
            if ( statusBar.alpha != 1.0 )
            {
                UIView.animate(withDuration: 0.2,
                               delay: 0,
                               options: .curveEaseInOut,
                               animations: {
                                
                                
                                statusBar.alpha = 1.0;
                })
            }
        }//status
        
        
        
        
        
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //gesture drag view dismiss
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(draggedView(_:)))
        self.view.addGestureRecognizer(panGesture);
        
        
    }
    
    
    @objc func draggedView(_ recognizer : UIPanGestureRecognizer){
        //let point = recognizer.location(in: view);
        let translation = recognizer.translation(in: view);
        
        //print(translation);
        
        if ( translation.y > 0 ){
            
            self.navigationController?.view.frame.origin.y = translation.y;
            
            //뒷배경 어둡게 하기
            if ( translation.y > 170 ){
                
                self.navigationController?.view.superview?.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0)
                
            }else{
                var percent : CGFloat = 1 - ( translation.y / 1.7 ) / 100;
                
                if ( percent >= 0.5 ){
                    //percent = 0.5;
                }
                
                if ( percent >= 0 ){
                    self.navigationController?.view.superview?.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: percent)
                }
                
                
            }
            
            
        }
        
        
        
        if ( recognizer.state == .ended ){
            
            if translation.y >= 170{
                
                
                //dismiss view
                
                self.dismissView();
            }else{
                //return to the original position
                UIView.animate(withDuration: 0.3, animations: {
                    self.navigationController?.view.frame.origin = CGPoint(x: 0, y: 0);
                })
            }
        }
    }
    
    func dismissView(){
        
        let noti = Notification.init(name : Notification.Name(rawValue: "statusBarHide"));
        NotificationCenter.default.post(noti);
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
}
