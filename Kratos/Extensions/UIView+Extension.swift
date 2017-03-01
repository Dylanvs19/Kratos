//
//  UIView+Extension.swift
//  Kratos
//
//  Created by Dylan Straughan on 11/6/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import UIKit

/// Tappable Protocol enables a UITapGestureRecognizer on any View that adheres to it's protocol. 
/// - addTap(): must be called on a view, and adds a UITapGestureRecognizer
/// - selector: a selector must be implemented with the method that will be called on the tap action. Example - var selector: Selector = #selector(methodName)
protocol Tappable: class {
    func addTap()
    var selector: Selector { get set } 
}

extension Tappable where Self: UIView {

    func addTap() {
        let tap = UITapGestureRecognizer(target: self, action: selector)
        self.addGestureRecognizer(tap)
    }
}

/// Loadable protocol & extension handle the basic setup of custom view via the Files Owner.
/// 1. Loads nib from the main Bundle (nib must be named conforming class name) i.e. The Files owner of the ButtonView.xib nib must be called ButtonView for the protocol to perform properly. 
/// 2. Adds nib content View to Loadable conforming class (UIView.Type) as a subview
/// 3. Translates AutoresizingMaskIntoConstraints to false
/// 4. Pins content view to Loadable conforming class (UIView.Type) edges. 
/// - contentView: - the top view in the .xib heirarchy. This must be added to Loadable conforming class as an IBOutlet
/// - customInit: - function that must be called in init(frame) and init(coder) to ensure proper initialization.
protocol Loadable: class {
    func customInit()
}

extension Loadable where Self: UIView {
    func customInit() {
        guard let contentView = Bundle.main.loadNibNamed(String(describing: Self.self), owner: self, options: nil)?.first as? UIView else {
            fatalError("could not load Nib \(String(describing: Self.self))")
        }
        addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        contentView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }
}

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
    
    
    func addShadow(shadowColor: CGColor = UIColor.black.cgColor,
                   shadowOffset: CGSize = CGSize(width: 1.0, height: 1.0),
                   shadowOpacity: Float = 0.4,
                   shadowRadius: CGFloat = 0) {
        
        layer.masksToBounds = false
        layer.shadowColor = shadowColor
        layer.shadowOffset = shadowOffset
        layer.shadowOpacity = shadowOpacity
        layer.shadowRadius = shadowRadius
        layer.shouldRasterize = true 
    }
    
    /// Adds view to a superview, disables translates autoresizing masks into constraints, and pins the view to the edges of the superview.
    func pin(to superView: UIView) {
        superView.addSubview(self)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.topAnchor.constraint(equalTo: superView.topAnchor).isActive = true
        self.bottomAnchor.constraint(equalTo: superView.bottomAnchor).isActive = true
        self.leadingAnchor.constraint(equalTo: superView.leadingAnchor).isActive = true
        self.trailingAnchor.constraint(equalTo: superView.trailingAnchor).isActive = true
        self.layoutSubviews()
        self.layoutIfNeeded()
    }
    
    
    /// Removes all subviews from View
    func clear() {
        self.subviews.forEach { (view) in
            view.removeFromSuperview()
        }
    }
}
