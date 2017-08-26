//
//  ApplicationLauncher.swift
//  Kratos
//
//  Created by Dylan Straughan on 5/13/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import Foundation
import UIKit


struct ApplicationLauncher {
    
    static func launch(from appDelegate: UIApplicationDelegate) {
        
        let splash = SplashViewController()
        splash.onAnimationCompletion = {
            
            let token: String? = Store.fetch("token")
            
            if let token = token {
                let kratosClient = KratosClient(token: token)
                let client = Client(kratosClient: kratosClient)
                updateStoredData(with: client)
                rootTransition(to: TabBarController(with: client))
            } else {
                let navVC = UINavigationController(rootViewController: LoginController(client: Client.default))
                rootTransition(to: navVC)
            }
        }
        
        appDelegate.window??.rootViewController = splash
        appDelegate.window??.makeKeyAndVisible()
    }
    
    static func updateStoredData(with client: Client) {
        client.fetchAllSubjects()
            .subscribe(onNext: { subjects in
                Store.shelve(subjects, key: Subject.identifier)
            })
            .dispose()
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
