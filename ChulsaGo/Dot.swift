//
//  design.swift
//  PassCode
//
//  Created by Nu-Ri Lee on 2017. 5. 2..
//  Copyright © 2017년 nuri lee. All rights reserved.
//

import UIKit

@IBDesignable
class Dot:UIView{

    
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
    
    @IBInspectable var round: CGFloat = 8.0 {
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
        
        layer.cornerRadius = round
        layer.borderWidth = 0.4
        layer.borderColor = activeColor.cgColor
        layer.masksToBounds = true
        self.backgroundColor = inactiveColor

        
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

