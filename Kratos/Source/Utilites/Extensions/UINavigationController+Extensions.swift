//
//  UINavigationController+Extensions.swift
//  Kratos
//
//  Created by Dylan Straughan on 2/25/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import UIKit

extension UINavigationController {
    
    ///Pushes a viewController onto the navigation stack. 
    /// - Important: Only allows one type of each viewController to exist simultaneously. If a viewController of a type that already exists on the stack is passed in as a parameter, exclusivePush will pop to already existing viewController, and push the new viewController onto the stack.
    /// - parameter - viewController: viewController to be pushed onto the stack.
    func exclusivePush<ViewController: UIViewController>(viewController: ViewController) {
        for vc in self.viewControllers {
            if vc.isKind(of: ViewController.self) {
                self.popToViewController(vc, animated: false)
                self.popViewController(animated: false)
            }
        }
        self.pushViewController(viewController, animated: true)
    }
}

