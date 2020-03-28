//
//  design.swift
//  PassCode
//
//  Created by Nu-Ri Lee on 2017. 5. 2..
//  Copyright © 2017년 nuri lee. All rights reserved.
//

import UIKit

@IBDesignable
class ProfileView:UIView{
    
    
    
    @IBInspectable var borderRaius: CGFloat = 8.0 {
        didSet {
            setupView()
        }
    }
    
    
    
    public override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        setupView()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        setupView()
    }
//    
//    override var intrinsicContentSize : CGSize {
//        
//        return CGSize(width: 16, height: 16)
//    }
    
    
    
    override var backgroundColor: UIColor? {
        didSet {
        }
    }
    
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        //backgroundColor = UIColor.gray
        
    }
    
    fileprivate func setupView() {
        
        layer.cornerRadius = borderRaius
        layer.borderWidth = 0.4
        layer.masksToBounds = true
        
        
        
        
    }
    
    override func draw(_ rect: CGRect)
    {
        
        
        
    }
    
}
