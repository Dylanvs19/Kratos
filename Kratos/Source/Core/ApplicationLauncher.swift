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
                appDelegate.rootTransition(to: TabBarController(client: client))
            } else {
                let navVC = UINavigationController(rootViewController: LoginViewController(client: Client.default))
                appDelegate.rootTransition(to: navVC)
            }
        }
        
        appDelegate.window??.rootViewController = splash
        appDelegate.window??.makeKeyAndVisible()
    }
}
