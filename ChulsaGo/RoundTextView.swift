//
//  design.swift
//  PassCode
//
//  Created by Nu-Ri Lee on 2017. 5. 2..
//  Copyright © 2017년 nuri lee. All rights reserved.
//

import UIKit

@IBDesignable
class RoundTextView:UITextView{
    
    
    override var backgroundColor: UIColor? {
        didSet {
        }
    }
    
    
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        //backgroundColor = UIColor.gray
        
    }
    
    override func draw(_ rect: CGRect)
    {
        
        
        
    }
    
    @IBInspectable var passcodeSign: String = "1"
    
    @IBInspectable var borderColor: UIColor = UIColor.white {
        didSet {
            setupView()
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 1 {
        didSet {
            setupView()
        }
    }
    
    @IBInspectable var borderRadius: CGFloat = 35 {
        didSet {
            setupView()
        }
    }
    
    @IBInspectable var highlightBackgroundColor: UIColor = UIColor.clear {
        didSet {
            setupView()
        }
    }
    
    
    fileprivate var defaultBackgroundColor = UIColor.clear
    
    fileprivate func setupView() {
        
        layer.borderWidth = borderWidth
        layer.cornerRadius = borderRadius
        layer.borderColor = borderColor.cgColor
        layer.masksToBounds = true
        
        
        
        
        
        
        if let backgroundColor = backgroundColor {
            
            defaultBackgroundColor = backgroundColor
        }
    }
    
    
}
