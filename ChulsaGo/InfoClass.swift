//
//  InfoClass.swift
//  menuNuri
//
//  Created by Nu-Ri Lee on 2017. 5. 31..
//  Copyright © 2017년 nuri lee. All rights reserved.
//

import UIKit

class InfoClass : UIViewController {
    
    
    static var infoBool = true;
    
    static var infoVC : InfoViewController!
    static let infoBlack = UIView();
    
    static let height : CGFloat = 120
    
    static func infoInit(){
        
        // ---- info ----
        
        infoBool = true;
        
        
        //window
        //let window = UIApplication.shared.keyWindow!
        
        //최상단에서 추가된것 제거
        
        let rootView = UIApplication.shared.keyWindow!.rootViewController?.view
        let windows = rootView?.subviews
        for window in windows!{
            if window.tag == 1003 {
                window.removeFromSuperview()
            }
            
        }
        
        
        
        //스토리보드에서 info 뷰 컨트롤러 가져오기
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        infoVC = storyboard.instantiateViewController(withIdentifier: "InfoViewController") as! InfoViewController
        
        infoVC.view.tag = 1003;
        
        //self.addChildViewController(menuVC);
        DispatchQueue.main.async() {
            rootView?.insertSubview(infoVC.view, at: 1)
            
            
            infoVC.view.translatesAutoresizingMaskIntoConstraints = false;
            
            //            infoVC.view.leadingAnchor.constraint(equalTo: (rootView?.layoutMarginsGuide.leadingAnchor)!, constant: 0).isActive = true;
            //            infoVC.view.trailingAnchor.constraint(equalTo: (rootView?.layoutMarginsGuide.trailingAnchor)!, constant: 0).isActive = true;
            //            infoVC.view.bottomAnchor.constraint(equalTo: (rootView?.layoutMarginsGuide.bottomAnchor)!, constant: -16).isActive = true;
            
            
            infoVC.view.leadingAnchor.constraint(equalTo: (rootView?.leadingAnchor)!, constant: 8).isActive = true;
            infoVC.view.trailingAnchor.constraint(equalTo: (rootView?.trailingAnchor)!, constant: -8).isActive = true;
            
            infoVC.view.bottomAnchor.constraint(equalTo: (rootView?.layoutMarginsGuide.bottomAnchor)!, constant: -8).isActive = true;
            
            infoVC.view.heightAnchor.constraint(equalToConstant: height).isActive = true;
            
            infoVC.view.isUserInteractionEnabled = false;
            infoVC.view.isHidden = true;
            infoVC.view.bounds.origin.x = 0;
            infoVC.view.bounds.origin.y = -(height + 16);
            
            
            
            
            //서브뷰
            infoVC.view.subviews.first?.layer.cornerRadius = 10
            infoVC.view.subviews.first?.clipsToBounds = false
            
            //그림자
            infoVC.view.subviews.first?.layer.shadowColor = UIColor.black.cgColor
            infoVC.view.subviews.first?.layer.shadowOpacity = 0.2
            infoVC.view.subviews.first?.layer.shadowOffset = CGSize.zero
            infoVC.view.subviews.first?.layer.shadowRadius = 3
            
        }
        
        
    }
    
    static func showInfo(){
        infoVC.view.isHidden = false;
        
        
        //infoVC.imageView.downloadAndResizeImageFrom("https://www.softwarehow.com/wp-content/uploads/Award_Best_iOS_Blogs.jpg", contentMode: .scaleAspectFit, newWidth: 200)
        
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       usingSpringWithDamping:0.6,
                       initialSpringVelocity:1,
                       options: .curveEaseInOut,
                       animations: {
                        self.infoVC.view.bounds.origin.y = 0;
                        
                        
                        
        }, completion: { (finished) -> Void in
            //print("end");
            
            
            InfoClass.infoBool = false;
            
            self.infoVC.view.isUserInteractionEnabled = true;
            
            
            
            
        })
    }
    
    static func hideInfo(){
        
        
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping:0.8,
                       initialSpringVelocity:0,
                       options: .curveEaseInOut,
                       animations: {
                        self.infoVC.view.bounds.origin.y = -(height + 16);
                        
                        
        }, completion: { (finished) -> Void in
            //print("end");
            
            InfoClass.infoBool = true;
            self.infoVC.view.isHidden = true;
            self.infoVC.view.isUserInteractionEnabled = false;
            
            self.infoVC.imageView.image = UIImage();
            self.infoVC.imageView2.image = UIImage();
            
        })
        
    }
    
}





class InfoClass2 : UIViewController {
    
    
    static var infoBool = true;
    
    static var infoVC : InfoViewController2!
    static let infoBlack = UIView();
    
    static let height : CGFloat = 120
    
    static func infoInit(uiView : UIView){
        
        // ---- info ----
        
        infoBool = true;
        
        
        //window
        //let window = UIApplication.shared.keyWindow!
        
        //최상단에서 추가된것 제거
//
//        let rootView = UIApplication.shared.keyWindow!.rootViewController?.view
//        let windows = rootView?.subviews
//        for window in windows!{
//            if window.tag == 1008 {
//                window.removeFromSuperview()
//            }
//
//        }
        
        
        
        //스토리보드에서 info 뷰 컨트롤러 가져오기
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        infoVC = storyboard.instantiateViewController(withIdentifier: "InfoViewController2") as! InfoViewController2
        
        infoVC.view.tag = 1008;
        
        //self.addChildViewController(menuVC);
        DispatchQueue.main.async() {
            uiView.insertSubview(infoVC.view, at: 1)
            
            
            infoVC.view.translatesAutoresizingMaskIntoConstraints = false;
            
            //            infoVC.view.leadingAnchor.constraint(equalTo: (rootView?.layoutMarginsGuide.leadingAnchor)!, constant: 0).isActive = true;
            //            infoVC.view.trailingAnchor.constraint(equalTo: (rootView?.layoutMarginsGuide.trailingAnchor)!, constant: 0).isActive = true;
            //            infoVC.view.bottomAnchor.constraint(equalTo: (rootView?.layoutMarginsGuide.bottomAnchor)!, constant: -16).isActive = true;
            
            
            infoVC.view.leadingAnchor.constraint(equalTo: (uiView.leadingAnchor), constant: 8).isActive = true;
            infoVC.view.trailingAnchor.constraint(equalTo: (uiView.trailingAnchor), constant: -8).isActive = true;
            
            infoVC.view.bottomAnchor.constraint(equalTo: (uiView.layoutMarginsGuide.bottomAnchor), constant: -8).isActive = true;
            
            infoVC.view.heightAnchor.constraint(equalToConstant: height).isActive = true;
            
            infoVC.view.isUserInteractionEnabled = false;
            infoVC.view.isHidden = true;
            infoVC.view.bounds.origin.x = 0;
            infoVC.view.bounds.origin.y = -(height + 16);
            
            
            
            
            //서브뷰
            infoVC.view.subviews.first?.layer.cornerRadius = 10
            infoVC.view.subviews.first?.clipsToBounds = false
            
            //그림자
            infoVC.view.subviews.first?.layer.shadowColor = UIColor.black.cgColor
            infoVC.view.subviews.first?.layer.shadowOpacity = 0.2
            infoVC.view.subviews.first?.layer.shadowOffset = CGSize.zero
            infoVC.view.subviews.first?.layer.shadowRadius = 3
            
        }
        
        
    }
    
    static func showInfo(){
        infoVC.view.isHidden = false;
        
        
        //infoVC.imageView.downloadAndResizeImageFrom("https://www.softwarehow.com/wp-content/uploads/Award_Best_iOS_Blogs.jpg", contentMode: .scaleAspectFit, newWidth: 200)
        
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       usingSpringWithDamping:0.6,
                       initialSpringVelocity:1,
                       options: .curveEaseInOut,
                       animations: {
                        self.infoVC.view.bounds.origin.y = 0;
                        
                        
                        
        }, completion: { (finished) -> Void in
            //print("end");
            
            
            InfoClass.infoBool = false;
            
            self.infoVC.view.isUserInteractionEnabled = true;
            
            
            
            
        })
    }
    
    static func hideInfo(){
        
        
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping:0.8,
                       initialSpringVelocity:0,
                       options: .curveEaseInOut,
                       animations: {
                        self.infoVC.view.bounds.origin.y = -(height + 16);
                        
                        
        }, completion: { (finished) -> Void in
            //print("end");
            
            InfoClass.infoBool = true;
            self.infoVC.view.isHidden = true;
            self.infoVC.view.isUserInteractionEnabled = false;
            
            self.infoVC.imageView.image = UIImage();
            self.infoVC.imageView2.image = UIImage();
            
        })
        
    }
    
}
