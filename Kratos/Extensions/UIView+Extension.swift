//
//  UIView+Extension.swift
//  Kratos
//
//  Created by Dylan Straughan on 11/6/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import UIKit

protocol Tappable: class {
    var selector: Selector { get }
    func addTap()
}

extension Tappable where Self: UIView {
    
    func addTap() {
        let tap = UITapGestureRecognizer(target: self, action: selector)
        self.addGestureRecognizer(tap)
    }
}

extension UIView {
    
    func addBlurEffect() {
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(blurEffectView)
    }
    
    func removeBlurEffect() {
        for view in self.subviews where view is UIVisualEffectView {
            view.removeFromSuperview()
        }
    }
}
