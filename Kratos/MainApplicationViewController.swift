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
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleLoginFlow), name: NSNotification.Name(rawValue: "toMainVC"), object: nil)
        handleLoginFlow()
    }
    
    func hasToken() -> Bool {
        return KeychainManager.fetchToken() == nil ? false : true
    }
    
    func handleLoginFlow() {
        if hasToken() {
            APIService.fetchUser({ (user) in
                    Datastore.sharedDatastore.user = user
                    APIManager.getRepresentatives({ (repSuccess) in
                        if repSuccess {
                            DispatchQueue.main.async(execute: {
                                self.embedMainViewController()
                            })
                        } else {
                            debugPrint("could not get representative for User")
                        }
                    })
                    }, failure: { (error) in
                        DispatchQueue.main.async(execute: {
                            self.embedLoginViewController()
                        })
                        debugPrint(error as Any)
                })
        } else {
                self.embedLoginViewController()
        }
    }
    
    func embedMainViewController(with reps: [Person]? = nil) {
        let navVC = UINavigationController()
        let vc: MainViewController = MainViewController.instantiate()
        vc.representatives = reps
        navVC.setViewControllers([vc], animated: false)
        embedViewController(navVC)
    }
    
    func embedLoginViewController() {
        let navVC = UINavigationController()
        let vc: LoginViewController = LoginViewController.instantiate()
        navVC.setViewControllers([vc], animated: false)
        embedViewController(navVC)
    }
    
    func embedViewController(_ controller: UIViewController) {
        
        if childViewControllers.contains(controller) {
            return
        }
        
        for vc in childViewControllers {
            vc.willMove(toParentViewController: nil)
            if vc.isViewLoaded {
                vc.view.removeFromSuperview()
            }
            vc.removeFromParentViewController()
        }
        
        addChildViewController(controller)
        controller.loadViewIfNeeded()
        mainAppContainerView.addSubview(controller.view)
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        controller.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        controller.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        controller.view.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        controller.view.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        controller.didMove(toParentViewController: self)
    }
    
}

