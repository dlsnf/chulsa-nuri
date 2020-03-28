//
//  MenuClass.swift
//  menuNuri
//
//  Created by Nu-Ri Lee on 2017. 5. 31..
//  Copyright © 2017년 nuri lee. All rights reserved.
//

import UIKit

class MenuClass : UIViewController{
    
    // ---- menu ----
    static var menuVC : MenuViewController!
    static let menuBlack = UIView();
    
    
    static var menuBool = true;
    
    static func menuInit(){
        
        menuBool = true;
        
        //최상단에서 추가된것 제거
        
        let rootView = UIApplication.shared.keyWindow!.rootViewController?.view
        let windows = rootView?.subviews
        for window in windows!{
            if window.tag == 1002 {
                window.removeFromSuperview()
            }

            if window.tag == 1001 {
                window.removeFromSuperview()
            }
        }
        
        
        //window
        //let window = UIApplication.shared.keyWindow!
        
        //background
        menuBlack.backgroundColor = UIColor.black.withAlphaComponent(0.0);
        menuBlack.isUserInteractionEnabled = false;
        menuBlack.tag = 1002;
        
        
//        window.rootViewController?.view.addSubview(menuBlack)
        
        DispatchQueue.main.async() {
            
            rootView?.insertSubview(menuBlack, at: 2)
            
                
            menuBlack.translatesAutoresizingMaskIntoConstraints = false;
            menuBlack.leadingAnchor.constraint(equalTo: (rootView?.leadingAnchor)!, constant: 0).isActive = true;
            menuBlack.topAnchor.constraint(equalTo: (rootView?.topAnchor)!, constant: 0).isActive = true;
            menuBlack.bottomAnchor.constraint(equalTo: (rootView?.layoutMarginsGuide.bottomAnchor)!, constant: 0).isActive = true;
            menuBlack.trailingAnchor.constraint(equalTo: (rootView?.trailingAnchor)!, constant: 0).isActive = true;
            
        }
        
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        //스토리보드에서 menu 뷰 컨트롤러 가져오기
        menuVC = storyboard.instantiateViewController(withIdentifier: "MenuViewController") as! MenuViewController
        menuVC.view.tag = 1001;
        
        
        //self.addChildViewController(menuVC);
        //window.addSubview()
        
        DispatchQueue.main.async() {
            rootView?.insertSubview(menuVC.view, at: 3)
            
            menuVC.view.translatesAutoresizingMaskIntoConstraints = false;
            menuVC.view.leadingAnchor.constraint(equalTo: (rootView?.leadingAnchor)!, constant: 0).isActive = true;
            menuVC.view.topAnchor.constraint(equalTo: (rootView?.topAnchor)!, constant: 0).isActive = true;
            
            menuVC.view.bottomAnchor.constraint(equalTo: (rootView?.layoutMarginsGuide.bottomAnchor)!, constant: 0
                ).isActive = true;
            
            menuVC.view.widthAnchor.constraint(equalToConstant: 262).isActive = true;
            menuVC.view.isUserInteractionEnabled = false;
            menuVC.view.isHidden = true;
            menuVC.view.bounds.origin.x = menuVC.view.frame.size.width;
            menuVC.view.bounds.origin.y = 0;
            
            
            //그림자
            menuVC.view.subviews.first?.layer.shadowColor = UIColor.black.cgColor
            menuVC.view.subviews.first?.layer.shadowOpacity = 0.5
            menuVC.view.subviews.first?.layer.shadowOffset = CGSize.zero
            menuVC.view.subviews.first?.layer.shadowRadius = 5
            
            menuVC.view.subviews.first?.layer.shadowPath = UIBezierPath(rect: (menuVC.view.subviews.first?.bounds)!).cgPath
        }
        
        //menuVC.view.subviews.first?.layer.shouldRasterize = true
        
    }
    
    static func showMenu(){
        
        menuVC.view.isHidden = false;
        
        //self.setNeedsStatusBarAppearanceUpdate()
        
        
        UIView.animate(withDuration: 0.2,
                       delay:0,
                       options:UIViewAnimationOptions.curveEaseOut,
                       animations: {
                        self.menuBlack.backgroundColor = UIColor.black.withAlphaComponent(0.5);
                        
                        self.menuVC.view.bounds.origin.x = 0;
                        
                        
                        MenuClass.menuBool = false;
                        
        }, completion: { (finished) -> Void in
            //print("end");
            self.menuBlack.isUserInteractionEnabled = true;
            self.menuVC.view.isUserInteractionEnabled = true;
            
            let tap = UITapGestureRecognizer(target: self, action:#selector(self.closeMenu))
            self.menuBlack.addGestureRecognizer(tap)
            
            
        })
        
        
        //status bar
        let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as! UIView

        UIView.animate(withDuration: 0.2,
                       delay: 0,
                       options: .curveEaseInOut,
                       animations: {


                        statusBar.alpha = 0.0;
        })
        
        
        
    }
    
    
    @objc static func closeMenu(){
        
        
        
        UIView.animate(withDuration: 0.2,
                       delay:0,
                       options:UIViewAnimationOptions.curveEaseInOut,
                       animations: {
                        self.menuBlack.backgroundColor = UIColor.black.withAlphaComponent(0.0);
                        
                        self.menuVC.view.bounds.origin.x = self.menuVC.view.frame.size.width;
                        
        }, completion: { (finished) -> Void in
            //print("end");
            //            let subViews = self.view.subviews
            //            for subview in subViews{
            //                if subview.tag == 1001 {
            //                    subview.removeFromSuperview()
            //                }
            //            }
            //
            //            //최상단에서 추가된것 제거
            //            let windows = UIApplication.shared.keyWindow!.subviews
            //            for window in windows{
            //                if window.tag == 1002 {
            //                    window.removeFromSuperview()
            //                }
            //            }
            
            self.menuVC.view.isHidden = true;
            
            self.menuBlack.isUserInteractionEnabled = false;
            self.menuVC.view.isUserInteractionEnabled = false;
            
        })
        
        MenuClass.menuBool = true;
        
        //status bar
        let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as! UIView

        UIView.animate(withDuration: 0.2,
                       delay: 0,
                       options: .curveEaseInOut,
                       animations: {


                        statusBar.alpha = 1.0;
        })
    }
    
}
