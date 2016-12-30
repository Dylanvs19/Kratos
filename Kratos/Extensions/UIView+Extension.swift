//
//  UIView+Extension.swift
//  Kratos
//
//  Created by Dylan Straughan on 11/6/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import UIKit

/// Tappable Protocol enables a UITapGestureRecognizer on any View that adheres to it's protocol. 
/// - parameter - addTap() must be called on a view, and adds a UITapGestureRecognizer
/// - selector - a selector must be implemented with the method that will be called on the tap action. Example - var selector: Selector = #selector(methodName)
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
/// - parameter - contentView - the top view in the .xib heirarchy. This must be added to Loadable conforming class as an IBOutlet
/// - parameter - customInit - function that must be called in init(frame) and init(coder) to ensure proper initialization.
/// Any other setup such as adding custom autoresizingMasks can be done in other helper methods and placed in awakeFromNib()
protocol Loadable: class {
    var contentView: UIView! { get set }
    func customInit()
}

extension Loadable where Self: UIView {
    func customInit() {
        Bundle.main.loadNibNamed(String(describing: Self.self), owner: self, options: nil)
        addSubview(contentView)
        translatesAutoresizingMaskIntoConstraints = false
        contentView.frame = bounds
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
