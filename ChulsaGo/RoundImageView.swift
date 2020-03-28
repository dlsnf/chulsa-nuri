//
//  design.swift
//  PassCode
//
//  Created by Nu-Ri Lee on 2017. 5. 2..
//  Copyright © 2017년 nuri lee. All rights reserved.
//

import UIKit

@IBDesignable
class RoundImageView:UIImageView{
    
    
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
    
    public override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        setupView()
        setupActions()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        
        setupActions()
    }
    
    override var intrinsicContentSize : CGSize {
        
        return CGSize(width: 60, height: 60)
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
    
    fileprivate func setupActions() {
        
        //버튼 타겟 추가
        //addTarget(self, action: #selector(PassCodeButton.handleTouchDown), for: .touchDown)
        //addTarget(self, action: #selector(PassCodeButton.handleTouchUp), for: [.touchUpInside, .touchDragOutside, .touchCancel])
        
    }
    
    func handleTouchDown() {
        animateTitleColor(UIColor.white)
        animateBackgroundColor(highlightBackgroundColor)
    }
    
    func handleTouchUp() {
        animateTitleColor(UIColor(red: 117/255.0, green: 154/255.0, blue: 228/255.0, alpha: 1.0))
        animateBackgroundColor(defaultBackgroundColor)
    }
    
    fileprivate func animateBackgroundColor(_ color: UIColor) {
        
        UIView.animate(
            withDuration: 0.3,
            delay: 0.0,
            usingSpringWithDamping: 1,
            initialSpringVelocity: 0.0,
            options: [.allowUserInteraction, .beginFromCurrentState],
            animations: {
                
                self.backgroundColor = color
        },
            completion: nil
        )
    }
    
    fileprivate func animateTitleColor(_ color: UIColor) {
        
        UIView.animate(
            withDuration: 0.3,
            delay: 0.0,
            usingSpringWithDamping: 1,
            initialSpringVelocity: 0.0,
            options: [.allowUserInteraction, .beginFromCurrentState],
            animations: {
                
                //self.setTitleColor(color, for: .normal)
                //self.setTitleShadowColor(UIColor.black, for: .normal)
        },
            completion: nil
        )
    }
    
}
