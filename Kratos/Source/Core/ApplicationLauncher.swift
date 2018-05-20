//
//  ApplicationLauncher.swift
//  Kratos
//
//  Created by Dylan Straughan on 5/13/17.
//  Copyright © 2017 Kratos, Inc. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseMessaging
import UserNotifications

struct ApplicationLauncher {
    
    static func launch(from appDelegate: UIApplicationDelegate) {
        
        let splash = SplashViewController()
        splash.onAnimationCompletion = {
            let hasInstalled: String? = Store.fetch("has_installed")
            let token: String? = Store.fetch("token")
            
            // Override point for customization after application launch.
            FirebaseApp.configure()
            
            var vc: UIViewController
            if let token = token {
                let kratosClient = KratosClient(token: token)
                Client.launch(with: kratosClient)
                if #available(iOS 10.0, *) {
                    Client.setupMessaging()
                }
                vc = TabBarController(with: Client.provider())
            } else {
                Client.launch(with: KratosClient(token: nil))
                if #available(iOS 10.0, *) {
                    Client.setupMessaging()
                }
                if hasInstalled != nil {
                    vc = UINavigationController(rootViewController: LoginController(client: Client.provider()))
                } else {
                    Store.shelve("true", key: "has_installed")
                    let viewController = WelcomeController()
                    viewController.setDefaultNavVC()
                    vc = UINavigationController(rootViewController: viewController)
                }
                
            }
            rootTransition(to: vc)
        }
        
        appDelegate.window??.rootViewController = splash
        appDelegate.window??.makeKeyAndVisible()
    }
    
    static func rootTransition(to viewController: UIViewController,
                               duration: TimeInterval = 1.0,
                               animationOptions: UIViewAnimationOptions = .transitionCrossDissolve,
                               completion: ((Bool) -> Void)? = nil) {
        guard case .some(.some(let window)) = UIApplication.shared.delegate?.window else {
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
