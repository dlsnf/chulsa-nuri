//
//  HamburgerButton.swift
//  HamburgerButton
//
//  Created by Arkadiusz on 14-07-14.
//  Copyright (c) 2014 Arkadiusz Holko. All rights reserved.
//

import CoreGraphics
import QuartzCore
import UIKit

open class HamburgerButton: UIButton {

    open var color: UIColor = UIColor(red: 28.0 / 255, green: 27.0 / 255, blue: 32.0 / 255, alpha: 1) {
    didSet {
        for shapeLayer in shapeLayers {
            shapeLayer.strokeColor = color.cgColor
        }
    }
    }

    fileprivate let top: CAShapeLayer = CAShapeLayer()
    fileprivate let middle: CAShapeLayer = CAShapeLayer()
    fileprivate let bottom: CAShapeLayer = CAShapeLayer()
    fileprivate let width: CGFloat = 18
    fileprivate let height: CGFloat = 16
    fileprivate let topYPosition: CGFloat = 2-0.3
    fileprivate let middleYPosition: CGFloat = 7
    fileprivate let bottomYPosition: CGFloat = 12+0.3

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    fileprivate func commonInit() {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: width, y: 0))

        for shapeLayer in shapeLayers {
            shapeLayer.path = path.cgPath
            shapeLayer.lineWidth = 1.2
            shapeLayer.strokeColor = color.cgColor

            // Disables implicit animations.
            shapeLayer.actions = [
                "transform": NSNull(),
                "position": NSNull()
            ]

            let strokingPath = CGPath(__byStroking: shapeLayer.path!, transform: nil, lineWidth: shapeLayer.lineWidth, lineCap: CGLineCap.butt, lineJoin: CGLineJoin.miter, miterLimit: shapeLayer.miterLimit)
            // Otherwise bounds will be equal to CGRectZero.
            shapeLayer.bounds = (strokingPath?.boundingBoxOfPath)!

            layer.addSublayer(shapeLayer)
        }

        let widthMiddle = width / 2
        top.position = CGPoint(x: widthMiddle, y: topYPosition)
        middle.position = CGPoint(x: widthMiddle, y: middleYPosition)
        bottom.position = CGPoint(x: widthMiddle, y: bottomYPosition)
    }

    override open var intrinsicContentSize : CGSize {
        return CGSize(width: width, height: height)
    }

    open var showsMenu: Bool = true {
        didSet {
            // There's many animations so it's easier to set up duration and timing function at once.
            CATransaction.begin()
            CATransaction.setAnimationDuration(0.4)
            CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(controlPoints: 0.4, 0.0, 0.2, 1.0))

            let strokeStartNewValue: CGFloat = showsMenu ? 0.0 : 0.3
            let positionPathControlPointY = bottomYPosition / 2
            let verticalOffsetInRotatedState: CGFloat = 0.75


            let topRotation = CAKeyframeAnimation(keyPath: "transform")
            topRotation.values = rotationValuesFromTransform(top.transform,
                endValue: showsMenu ? CGFloat(-Double.pi - Double.pi/4) : CGFloat(Double.pi + Double.pi/4))
            // Kind of a workaround. Used because it was hard to animate positions of segments' such that their ends form the arrow's tip and don't cross each other.
            topRotation.calculationMode = kCAAnimationCubic
            topRotation.keyTimes = [0.0, 0.33, 0.73, 1.0]
            top.ahk_applyKeyframeValuesAnimation(topRotation)

            let topPosition = CAKeyframeAnimation(keyPath: "position")
            let topPositionEndPoint = CGPoint(x: width / 2, y: showsMenu ? topYPosition : bottomYPosition + verticalOffsetInRotatedState)
            topPosition.path = quadBezierCurveFromPoint(top.position,
                toPoint: topPositionEndPoint,
                controlPoint: CGPoint(x: width, y: positionPathControlPointY)).cgPath
            top.ahk_applyKeyframePathAnimation(topPosition, endValue: NSValue(cgPoint: topPositionEndPoint))

            top.strokeStart = strokeStartNewValue


            let middleRotation = CAKeyframeAnimation(keyPath: "transform")
            middleRotation.values = rotationValuesFromTransform(middle.transform,
                endValue: showsMenu ? CGFloat(-Double.pi) : CGFloat(Double.pi))
            middle.ahk_applyKeyframeValuesAnimation(middleRotation)

            middle.strokeEnd = showsMenu ? 1.0 : 0.85


            let bottomRotation = CAKeyframeAnimation(keyPath: "transform")
            bottomRotation.values = rotationValuesFromTransform(bottom.transform,
                endValue: showsMenu ? CGFloat(-Double.pi/2 - Double.pi/4) : CGFloat(Double.pi/2 + Double.pi/4))
            bottomRotation.calculationMode = kCAAnimationCubic
            bottomRotation.keyTimes = [0.0, 0.33, 0.63, 1.0]
            bottom.ahk_applyKeyframeValuesAnimation(bottomRotation)

            let bottomPosition = CAKeyframeAnimation(keyPath: "position")
            let bottomPositionEndPoint = CGPoint(x: width / 2, y: showsMenu ? bottomYPosition : topYPosition - verticalOffsetInRotatedState)
            bottomPosition.path = quadBezierCurveFromPoint(bottom.position,
                toPoint: bottomPositionEndPoint,
                controlPoint: CGPoint(x: 0, y: positionPathControlPointY)).cgPath
            bottom.ahk_applyKeyframePathAnimation(bottomPosition, endValue: NSValue(cgPoint: bottomPositionEndPoint))

            bottom.strokeStart = strokeStartNewValue


            CATransaction.commit()
        }
    }

    fileprivate var shapeLayers: [CAShapeLayer] {
        return [top, middle, bottom]
    }
}

extension CALayer {
    func ahk_applyKeyframeValuesAnimation(_ animation: CAKeyframeAnimation) {
        guard let copy = animation.copy() as? CAKeyframeAnimation,
              let values = copy.values, !values.isEmpty,
              let keyPath = copy.keyPath else { return }

        self.add(copy, forKey: keyPath)
        self.setValue(values[values.count - 1], forKeyPath:keyPath)
    }

    // Mark: TODO: endValue could be removed from the definition, because it's possible to get it from the path (see: CGPathApply).
    func ahk_applyKeyframePathAnimation(_ animation: CAKeyframeAnimation, endValue: NSValue) {
        let copy = animation.copy() as! CAKeyframeAnimation

        self.add(copy, forKey: copy.keyPath)
        self.setValue(endValue, forKeyPath:copy.keyPath!)
    }
}

func rotationValuesFromTransform(_ transform: CATransform3D, endValue: CGFloat) -> [NSValue] {
    let frames = 4

    // values at 0, 1/3, 2/3 and 1
    return (0..<frames).map { num in
        NSValue(caTransform3D: CATransform3DRotate(transform, endValue / CGFloat(frames - 1) * CGFloat(num), 0, 0, 1))
    }
}

func quadBezierCurveFromPoint(_ startPoint: CGPoint, toPoint: CGPoint, controlPoint: CGPoint) -> UIBezierPath {
    let quadPath = UIBezierPath()
    quadPath.move(to: startPoint)
    quadPath.addQuadCurve(to: toPoint, controlPoint: controlPoint)
    return quadPath
}
