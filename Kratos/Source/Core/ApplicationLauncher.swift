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
            FIRApp.configure()
            
            var vc: UIViewController
            if let token = token {
                let kratosClient = KratosClient(token: token)
                let client = Client(kratosClient: kratosClient)
//                updateStoredData(with: client)
                if #available(iOS 10.0, *) {
                    // For iOS 10 display notification (sent via APNS)
                    UNUserNotificationCenter.current().delegate = client
                    // For iOS 10 data message (sent via FCM)
                    FIRMessaging.messaging().remoteMessageDelegate = client
                }
                vc = TabBarController(with: client)
            } else {
                let client = Client.default
                if #available(iOS 10.0, *) {
                    // For iOS 10 display notification (sent via APNS)
                    UNUserNotificationCenter.current().delegate = client
                    // For iOS 10 data message (sent via FCM)
                    FIRMessaging.messaging().remoteMessageDelegate = client
                }
                if hasInstalled != nil {
                    let navVC = UINavigationController(rootViewController: LoginController(client: Client.default))
                    vc = navVC
                } else {
                    Store.shelve("true", key: "has_installed")
                    let navVC = UINavigationController(rootViewController: LoginController(client: Client.default, state: .createAccount))
                    vc = navVC
                }
                
            }
            rootTransition(to: vc)
        }
        
        appDelegate.window??.rootViewController = splash
        appDelegate.window??.makeKeyAndVisible()
    }
    
//    static func updateStoredData(with client: Client) {
//        client.fetchAllSubjects()
//            .subscribe(onNext: { subjects in
//                Store.shelve(subjects, key: Subject.identifier)
//            })
//            .dispose()
//    }
    
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
