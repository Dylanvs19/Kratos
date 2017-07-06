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
            let client = Client(environment: .staging)
            if KeychainManager.token == nil {
                let navVC = UINavigationController(rootViewController: LoginViewController(client: client))
                appDelegate.rootTransition(to: navVC)
            } else {
                appDelegate.rootTransition(to: TabBarController(client: client))
            }
        }
        
        appDelegate.window??.rootViewController = splash
        appDelegate.window??.makeKeyAndVisible()
    }
}
