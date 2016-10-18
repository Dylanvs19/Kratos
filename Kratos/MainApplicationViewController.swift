//
//  ViewController.swift
//  Kratos
//
//  Created by Dylan Straughan on 7/30/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import UIKit

class MainApplicationViewController: UIViewController {
    
    @IBOutlet var mainAppContainerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(handleLoginFlow), name: "toMainVC", object: nil)
        handleLoginFlow()
    }
    
    func hasToken() -> Bool {
        return KeychainManager.fetchToken() == nil ? false : true
    }
    
    func handleLoginFlow() {
        if hasToken() {
            APIClient.fetchUser({ (user) in
                    Datastore.sharedDatastore.user = user
                    Datastore.sharedDatastore.getRepresentatives({ (repSuccess) in
                        if repSuccess {
                            dispatch_async(dispatch_get_main_queue(), {
                                self.embedMainViewController()
                            })
                        } else {
                            debugPrint("could not get representative for User")
                        }
                    })
                    }, failure: { (error) in
                        dispatch_async(dispatch_get_main_queue(), {
                            self.embedLoginViewController()
                        })
                        debugPrint(error)
                })
        } else {
                self.embedLoginViewController()
        }
    }
    
    func embedMainViewController() {
        let navVC = UINavigationController()
        let vc: MainViewController = MainViewController.instantiate()
        navVC.setViewControllers([vc], animated: false)
        embedViewController(navVC)
    }
    
    func embedLoginViewController() {
        let navVC = UINavigationController()
        let vc: LoginViewController = LoginViewController.instantiate()
        navVC.setViewControllers([vc], animated: false)
        embedViewController(navVC)
    }
    
    func embedViewController(controller: UIViewController) {
        
        if childViewControllers.contains(controller) {
            return
        }
        
        for vc in childViewControllers {
            vc.willMoveToParentViewController(nil)
            if vc.isViewLoaded() {
                vc.view.removeFromSuperview()
            }
            vc.removeFromParentViewController()
        }
        
        addChildViewController(controller)
        controller.loadViewIfNeeded()
        mainAppContainerView.addSubview(controller.view)
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        controller.view.topAnchor.constraintEqualToAnchor(view.topAnchor).active = true
        controller.view.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor).active = true
        controller.view.leftAnchor.constraintEqualToAnchor(view.leftAnchor).active = true
        controller.view.rightAnchor.constraintEqualToAnchor(view.rightAnchor).active = true
        controller.didMoveToParentViewController(self)
    }
    
}

