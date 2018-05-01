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
                let client = Client(kratosClient: kratosClient)
                if #available(iOS 10.0, *) {
                    // For iOS 10 display notification (sent via APNS)
                    UNUserNotificationCenter.current().delegate = client
                    // For iOS 10 data message (sent via FCM)
                    Messaging.messaging().delegate = client
                }
                vc = TabBarController(with: client)
            } else {
                let client = Client.default
                if #available(iOS 10.0, *) {
                    // For iOS 10 display notification (sent via APNS)
                    UNUserNotificationCenter.current().delegate = client
                    // For iOS 10 data message (sent via FCM)
                    Messaging.messaging().delegate = client
                }
//                if hasInstalled != nil {
//                    vc = UINavigationController(rootViewController: LoginController(client: Client.default))
//                } else {
                    Store.shelve("true", key: "has_installed")
                    let viewController = WelcomeController(with: Client.default)
                    viewController.setDefaultNavVC()
                    vc = UINavigationController(rootViewController: viewController)
//                }
                
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
