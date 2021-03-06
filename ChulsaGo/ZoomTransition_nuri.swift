//
//  ZoomTransition.swift
//  Transitions
//
//  Created by Tristan Himmelman on 2014-09-30.
//  Copyright (c) 2014 him. All rights reserved.
//

import Foundation
import UIKit

@objc public protocol ZoomTransitionProtocol {
    func viewForTransition() -> UIView
}

open class ZoomTransition: UIPercentDrivenInteractiveTransition, UIViewControllerAnimatedTransitioning, UINavigationControllerDelegate, UIGestureRecognizerDelegate {
    
    fileprivate var navigationController: UINavigationController
    fileprivate var fromView: UIView?
    fileprivate var toView: UIView?
    fileprivate var fromFrame: CGRect?
    fileprivate var toFrame: CGRect?
    fileprivate var transitionView: UIView?
    fileprivate var transitionContext: UIViewControllerContextTransitioning?
    fileprivate var fromViewController: UIViewController?
    fileprivate var toViewController: UIViewController?
    fileprivate var isPresenting: Bool = true
    fileprivate var shouldCompleteTransition: Bool = false
    fileprivate let completionThreshold: CGFloat = 0.7
    fileprivate var interactive: Bool = false
    
    var allowsInteractiveGesture = true
    
    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        
    }
    
    // MARK: - UIViewControllerAnimatedTransition Protocol
    
    open func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        if interactive {
            return 0.5
        }
        
        return 0.5
    }
    
    open func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        self.transitionContext = transitionContext
        fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from);
        
        toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to);
        
        if let viewController = toViewController as? ZoomTransitionProtocol {
            toView = viewController.viewForTransition()
        }
        if let viewController = fromViewController as? ZoomTransitionProtocol {
            fromView = viewController.viewForTransition()
        }
        
        // make sure toViewController is layed out
        toViewController?.view.frame = transitionContext.finalFrame(for: toViewController!)
        toViewController?.updateViewConstraints()

        assert(fromView != nil && toView != nil, "fromView and toView need to be set")
        
        let container = self.transitionContext!.containerView;
        
        // add toViewController to Transition Container
        if let view = toViewController?.view {
            if (isPresenting){
                container.addSubview(view)
            } else {
                container.insertSubview(view, belowSubview: fromViewController!.view)
            }
        }
        toViewController?.view.layoutIfNeeded()
        
        // Calculate animation frames within container view
        fromFrame = container.convert(fromView!.bounds, from: fromView)
        toFrame = container.convert(toView!.bounds, from: toView)
        
        // Create a copy of the fromView and add it to the Transition Container
        if let imageView = fromView as? UIImageView {
            transitionView = UIImageView(image: imageView.image)
        } else {
            transitionView = fromView?.snapshotView(afterScreenUpdates: false);
        }
        
        if let view = transitionView {
            view.clipsToBounds = true
            view.frame = fromFrame!
            view.contentMode = fromView!.contentMode
            container.addSubview(view)
        }
        
        if (isPresenting){
            animateZoomInTransition()
        } else {
            animateZoomOutTransition()
        }
    }
    
    // MARK: - Zoom animations
    
    func animateZoomInTransition(){
        if allowsInteractiveGesture {
            // add pinch gesture to new viewcontroller
//            let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(ZoomTransition.handlePinchGesture(_:)))
//            pinchGesture.delegate = self
//            toViewController?.view.addGestureRecognizer(pinchGesture)
//            
//            // add rotation gesture to new viewcontroller
//            let rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(ZoomTransition.handleRotationGesture(_:)))
//            rotationGesture.delegate = self
//            toViewController?.view.addGestureRecognizer(rotationGesture)
//            
//            // add pan gesture to new viewcontroller
//            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(ZoomTransition.handlePanGesture(_:)))
//            panGesture.delegate = self
//            toViewController?.view.addGestureRecognizer(panGesture)
        }
        
        toViewController?.view.alpha = 0
        toView?.isHidden = true
        fromView?.alpha = 0;
        
        
        
        let duration = transitionDuration(using: transitionContext!)
        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: UIViewAnimationOptions.curveLinear, animations: { () -> Void in

            self.toViewController?.view.alpha = 1
            
            InfoClass.infoVC.view.alpha = 0;
            
            
            
            if (self.interactive == false){
                self.transitionView?.frame = self.toFrame!
            }
    
        }) { (finished) -> Void in
            self.transitionView?.removeFromSuperview()
            self.fromViewController?.view.alpha = 1
            self.toView?.isHidden = false
            self.fromView?.alpha = 1
            
            InfoClass.infoVC.view.isHidden = true;
            
            if (self.transitionContext!.transitionWasCancelled){
                self.toViewController?.view.removeFromSuperview()
                self.isPresenting = true
                self.transitionContext!.completeTransition(false)
            } else {
                self.isPresenting = false
                self.transitionContext!.completeTransition(true)
            }
        }
    }
    
    func animateZoomOutTransition(){
        transitionView?.contentMode = toView!.contentMode
        
        toViewController?.view.alpha = 1
        
        InfoClass.infoVC.view.isHidden = false;
        

        toView?.isHidden = true
        fromView?.alpha = 0;
        let duration = transitionDuration(using: transitionContext!) - 0.1
        
        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [], animations: { () -> Void in
            self.fromViewController?.view.alpha = 0
            
            InfoClass.infoVC.view.alpha = 1;
            
            //nuri custom
            self.transitionView?.alpha = 0;
            
            
            if (self.interactive == false){
                self.transitionView?.frame = self.toFrame!
            }
        }) { (finished) -> Void in
            if self.interactive == false {
                self.zoomOutTransitionComplete()
            }
        }
    }
    
    func zoomOutTransitionComplete(){
        if (self.transitionView?.superview == nil){
            return
        }
        self.fromViewController?.view.alpha = 1
        self.toView?.isHidden = false
        self.fromView?.alpha = 1
        self.transitionView?.removeFromSuperview()
        
        if (self.transitionContext!.transitionWasCancelled){
            self.toViewController?.view.removeFromSuperview()
            self.isPresenting = false
            self.transitionContext!.completeTransition(false)
        } else {
            self.isPresenting = true
            self.transitionContext!.completeTransition(true)
        }
    }
    
    // MARK: - Gesture Recognizer Handlers
    
    func handlePinchGesture(_ gesture: UIPinchGestureRecognizer){
        if pinchNuri{
        switch (gesture.state) {
        case .began:
            nuri = false;
            interactive = true;
            
            // begin transition
            self.navigationController.popViewController(animated: true)
            break;
        case .changed:

            self.transitionView?.transform = self.transitionView!.transform.scaledBy(x: gesture.scale, y: gesture.scale)
            gesture.scale = 1
            
            // calculate current scale of transitionView
            let scale = self.transitionView!.frame.size.width / self.fromFrame!.size.width
            
            // Check if we should complete or restore transition when gesture is ended
            self.shouldCompleteTransition = (scale < completionThreshold);
            //println("scale\(1-scale)")
            update(1-scale)
            
            break;
        case .ended, .cancelled:
            
            
            var animationFrame = toFrame
            let cancelAnimation = (self.shouldCompleteTransition == false && gesture.velocity >= 0) || gesture.state == UIGestureRecognizerState.cancelled
            
            if (cancelAnimation){
                animationFrame = fromFrame
                cancel()
            } else {
                finish()
            }
            
            // calculate current scale of transitionView
            let finalScale = animationFrame!.width / self.fromFrame!.size.width
            let currentScale = (transitionView!.frame.size.width / self.fromFrame!.size.width)
            let delta = finalScale - currentScale
            var normalizedVelocity = gesture.velocity / delta

            // add upper and lower bound on normalized velocity
            normalizedVelocity = normalizedVelocity > 20 ? 20 : normalizedVelocity
            normalizedVelocity = normalizedVelocity < -20 ? -20 : normalizedVelocity
            
//            print("---\nvelocity \(gesture.velocity)")
//            print("normal \(delta)")
//            print("velocity normal \(normalizedVelocity)")

            // no need to normalize the velocity for low velocities
            if gesture.velocity < 3 && gesture.velocity > -3 {
                normalizedVelocity = gesture.velocity
            }
            
            let duration = transitionDuration(using: transitionContext!)
            
            UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: normalizedVelocity, options: UIViewAnimationOptions(), animations: { () -> Void in
                
                // set a new transform to reset the rotation to 0 but maintain the current scale
                self.transitionView?.transform = CGAffineTransform(scaleX: currentScale, y: currentScale)
                
                if let frame = animationFrame {
                    self.transitionView?.frame = frame
                }
                self.transitionView?.contentMode = self.toView!.contentMode
                
            }, completion: { (finished) -> Void in
                self.zoomOutTransitionComplete()
                self.interactive = false
                self.nuri = true;
            })

            break;
        default:
            break;
        }
        }
    }
    
    func handleRotationGesture(_ gesture: UIRotationGestureRecognizer){
        if interactive {
            if gesture.state == UIGestureRecognizerState.changed {
                transitionView!.transform = transitionView!.transform.rotated(by: gesture.rotation)
                gesture.rotation = 0
            }
        }
    }
    
    
    var start : CGFloat = 0.0;
    var change : CGFloat = 0.0;
    var end : CGFloat = 0.0;
    
    var nuri : Bool = true;
    var pinchNuri : Bool = true;
    
    func handlePanGesture(_ gesture: UIPanGestureRecognizer){

        
        let view = gesture.view!
        
        let point = gesture.location(in: view);
        
        if interactive && pinchNuri {
            if gesture.state == UIGestureRecognizerState.changed {
                let translation = gesture.translation(in: view)
                transitionView?.center = CGPoint(x:transitionView!.center.x + translation.x, y:transitionView!.center.y + translation.y)
                gesture.setTranslation(CGPoint.zero, in: view)
            }
        }
        if nuri {
        switch (gesture.state) {
        case .began:
            start = point.y;
            pinchNuri = false;
            interactive = true;
            // begin transition
            self.navigationController.popViewController(animated: true)
            break;
        case .changed:
            
            
            //화면 어둡게 하기
            let center = start;
            let cancel = center + (UIScreen.main.bounds.height/2);
            let bak = (cancel - center) / 100;
            let bak2 = (point.y - center) / bak;
            
            if abs(bak2/100) <= 1{
                update(abs(bak2/100)/5)
            }
            
            
            let translation = gesture.translation(in: view)
            transitionView?.center = CGPoint(x:transitionView!.center.x + translation.x, y:transitionView!.center.y + translation.y)
            gesture.setTranslation(CGPoint.zero, in: view)
            
            
            break;
        case .ended, .cancelled:
            
            end = point.y;
            //종료 시점
//            print("--");
//            print(point.y);
            
            let center = start;
            let topCancel = center - 50;
            let bottomCancel = center + 70;
            
            var cancelAnimation = true;
            if point.y <= topCancel || point.y >= bottomCancel {
                cancelAnimation = false;
            }else{
                cancelAnimation = true;
            }
            
            
            var animationFrame2 = toFrame
            
            if (cancelAnimation){
                animationFrame2 = fromFrame
                cancel()//취소
            } else {
                finish()//종료
            }
            
            let currentScale = (transitionView!.frame.size.width / self.fromFrame!.size.width)
                       let duration = transitionDuration(using: transitionContext!)
            
            UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: UIViewAnimationOptions(), animations: { () -> Void in
                
                // set a new transform to reset the rotation to 0 but maintain the current scale
                self.transitionView?.transform = CGAffineTransform(scaleX: currentScale, y: currentScale)
                
                if let frame = animationFrame2 {
                    self.transitionView?.frame = frame
                }
                self.transitionView?.contentMode = self.toView!.contentMode
                
            }, completion: { (finished) -> Void in
                self.zoomOutTransitionComplete()
                self.interactive = false
                self.pinchNuri = true;
            })
            
            break;
        default:
            break;
        }
        
        }
        
        
    }
    
    // MARK: - UINavigationControllerDelegate
    
    open func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        if (fromVC.conforms(to: ZoomTransitionProtocol.self) && toVC.conforms(to: ZoomTransitionProtocol.self)){
            return self
        }
        
        return nil;
    }

    open func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        
        if (self.interactive){
            return self
        }
        
        return nil
    }
    
    // MARK: - UIGestureRecognizerDelegate
    
    open func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
