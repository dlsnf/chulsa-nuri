//
//  ViewController.swift
//  menuNuri
//
//  Created by Nu-Ri Lee on 2017. 5. 25..
//  Copyright © 2017년 nuri lee. All rights reserved.
//

import UIKit

class InfoViewController: UIViewController {
    
    
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageView2: UIImageView!
    @IBOutlet weak var label_nuri: UILabel!
    @IBOutlet weak var loadingView: UIActivityIndicatorView!
    
    @IBOutlet weak var labelLike: UILabel!
    
    @IBOutlet weak var labelComment: UILabel!
    
    @IBOutlet weak var labelBody: UILabel!
    @IBOutlet weak var labelDate: UILabel!
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var likeView: UIImageView!
    
    @IBOutlet weak var commentView: UIImageView!
    var animationController : ZoomTransition?;
    
    @IBOutlet var likeLabelConstraint: NSLayoutConstraint!
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
//        
//        let infoViewTap = UITapGestureRecognizer(target: self, action:#selector(self.infoViewTap))
//        infoViewTap.numberOfTapsRequired = 2
//        infoView.addGestureRecognizer(infoViewTap)
//        
    }
    
    func infoViewTap(){
        //print("DD");
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        
        
    }
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

