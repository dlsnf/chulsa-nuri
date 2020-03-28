//
//  design.swift
//  PassCode
//
//  Created by Nu-Ri Lee on 2017. 5. 2..
//  Copyright © 2017년 nuri lee. All rights reserved.
//

import UIKit

@IBDesignable
class ShadowRoundView:UIView{
    
    
    public enum State {
        case inactive
        case active
        case error
    }
    
    @IBInspectable var inactiveColor: UIColor = UIColor.white {
        didSet {
            setupView()
        }
    }
    
    @IBInspectable var activeColor: UIColor = UIColor.gray {
        didSet {
            setupView()
        }
    }
    
    @IBInspectable var errorColor: UIColor = UIColor.red {
        didSet {
            setupView()
        }
    }
    
    
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
    
    
    
    public override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        setupView()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        setupView()
    }
    
    override var intrinsicContentSize : CGSize {
        
        return CGSize(width: 16, height: 16)
    }
    
    
    
    override var backgroundColor: UIColor? {
        didSet {
        }
    }
    
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        //backgroundColor = UIColor.gray
        
    }
    
    fileprivate func setupView() {
        
        
//        layer.borderWidth = borderWidth
//        layer.cornerRadius = borderRadius
//        layer.borderColor = borderColor.cgColor
//        layer.masksToBounds = true
        
        
        self.backgroundColor = UIColor.clear
        
        
        let shadowView = UIView(frame: CGRect(x: 0, y: 0, width: 52, height: 52))
        shadowView.backgroundColor = UIColor.clear
        shadowView.layer.shadowColor = UIColor.gray.cgColor
        shadowView.layer.shadowOffset = CGSize.zero
        shadowView.layer.shadowOpacity = 0.3
        shadowView.layer.shadowRadius = 2
        
        let view = UIView(frame: CGRect(x: 0, y: 0,width: 52, height: 52))
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = borderRadius
        //view.layer.borderColor = UIColor.gray.cgColor
        //view.layer.borderWidth = 0.5
        view.clipsToBounds = true
        
        shadowView.addSubview(view)
        self.addSubview(shadowView)
                
        
        
    }
    
    override func draw(_ rect: CGRect)
    {
        
        
        
    }
    
    fileprivate func colorsForState(_ state: State) -> (backgroundColor: UIColor, borderColor: UIColor) {
        
        switch state {
        case .inactive: return (inactiveColor, activeColor)
        case .active: return (activeColor, activeColor)
        case .error: return (errorColor, errorColor)
        }
    }
    
    func animateState(_ state: State) {
        
        let colors = colorsForState(state)
        
        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            usingSpringWithDamping: 1,
            initialSpringVelocity: 0,
            options: [],
            animations: {
                
                self.backgroundColor = colors.backgroundColor
                self.layer.borderColor = colors.borderColor.cgColor
                
        },
            completion: nil
        )
    }
}

