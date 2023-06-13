//
//  UIView+Extension.swift
//  Kratos
//
//  Created by Dylan Straughan on 11/6/16.
//  Copyright © 2017 Kratos, Inc. All rights reserved.
//

import UIKit

extension UIView {
    
    func addBlurEffect(front: Bool = true, animate: Bool = true ) {
        
        let blurEffectView = UIVisualEffectView(frame: bounds)
        blurEffectView.effect = UIBlurEffect(style: .dark)
        self.addSubview(blurEffectView)
        if front {
            self.bringSubviewToFront(blurEffectView)
        } else {
            self.sendSubviewToBack(blurEffectView)
        }
        
        UIView.animate(withDuration: 0.4) {
            blurEffectView.layoutIfNeeded()
        }
    }
    
    func removeBlurEffect() {
        for view in self.subviews where view is UIVisualEffectView {
            view.removeFromSuperview()
        }
    }
    
    var shadow: Bool {
        get {
            return layer.shadowOpacity > 0.0
        }
        set {
            if newValue == true {
                self.addShadow()
            }
        }
    }
    
    var cornerRadius: CGFloat {
        get {
            return self.layer.cornerRadius
        }
        set {
            self.layer.cornerRadius = newValue
            
            // Don't touch the masksToBound property if a shadow is needed in addition to the cornerRadius
            if shadow == false {
                self.layer.masksToBounds = true
            }
        }
    }
    
    
    func addShadow(shadowColor: UIColor = UIColor.black,
                   shadowOffset: CGSize = CGSize(width: 0, height: 1),
                   shadowOpacity: Float = 0.4,
                   shadowRadius: CGFloat = 1) {
        
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowColor = shadowColor.cgColor
        layer.shadowRadius = shadowRadius
        layer.shadowOpacity = shadowOpacity
        
        clipsToBounds = false
        
        let shadowFrame: CGRect = layer.bounds
        let shadowPath: CGPath = UIBezierPath(rect: shadowFrame).cgPath
        layer.shadowPath = shadowPath
    }
    
    /// Removes all subviews from View
    func clear() {
        self.subviews.forEach { (view) in
            view.removeFromSuperview()
        }
    }
    
    func snapshot() -> UIImage {
        defer { UIGraphicsEndImageContext() }
        
        UIGraphicsBeginImageContextWithOptions(bounds.size, isOpaque, 0.0)
        guard let context = UIGraphicsGetCurrentContext() else { return UIImage() }
        self.layer.render(in: context)
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else { return UIImage() }
        return image
    }
    
    func addVerticalGradient(from topColor: Color,
                             bottomColor: Color,
                             startPoint: CGPoint = CGPoint(x: 0.5, y: 0),
                             endPoint: CGPoint = CGPoint(x: 0.5, y: 1)) {
        let gradient = CAGradientLayer()
        gradient.frame = bounds
        gradient.colors = [topColor.value.cgColor, bottomColor.value.cgColor]
        gradient.startPoint = startPoint
        gradient.endPoint = endPoint
        layer.insertSublayer(gradient, at: 0)
    }
}
