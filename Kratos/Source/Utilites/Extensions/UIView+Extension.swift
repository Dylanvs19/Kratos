//
//  UIView+Extension.swift
//  Kratos
//
//  Created by Dylan Straughan on 11/6/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import UIKit

extension UIView {
    
    func addBlurEffect(front: Bool = true, animate: Bool = true ) {
        
        let blurEffectView = UIVisualEffectView(frame: bounds)
        blurEffectView.effect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        self.addSubview(blurEffectView)
        if front {
            self.bringSubview(toFront: blurEffectView)
        } else {
            self.sendSubview(toBack: blurEffectView)
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
    
    func snapshot() -> UIImageView {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale)
        guard let context = UIGraphicsGetCurrentContext() else { return UIImageView() }
        self.layer.render(in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return UIImageView(image: image)
    }
}
