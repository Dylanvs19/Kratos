//
//  UIApplicationDelegate+Extensions.swift
//  Kratos
//
//  Created by Dylan Straughan on 5/13/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import Foundation
import UIKit

extension UIApplicationDelegate {
    
    func rootTransition(to viewController: UIViewController,
                        duration: TimeInterval = 1.0,
                        animationOptions: UIViewAnimationOptions = .transitionCrossDissolve,
                        completion: ((Bool) -> Void)? = nil) {
        guard case .some(.some(let window)) = window else {
            fatalError("Could not unwrap application window")
        }
        
        UIView.transition(with: window,
                          duration: duration,
                          options: animationOptions,
                          animations: {
                            window.addSubview(viewController.view)
                            window.rootViewController = viewController
                            },
                          completion: completion)
    }
}
