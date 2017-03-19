//
//  ViewController.swift
//  Kratos
//
//  Created by Dylan Straughan on 7/30/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import UIKit

class MainApplicationViewController: UIViewController, ActivityIndicatorPresentable {
    
    @IBOutlet var mainAppContainerView: UIView!
    
    @IBOutlet weak var containerViewCenterXConstraint: NSLayoutConstraint!
    @IBOutlet var containerViewHeightConstraint: NSLayoutConstraint!
    
    var activityIndicator: KratosActivityIndicator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNotificationObservers()
        handleLoginFlow()
    }
    
    func setupNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleLoginFlow), name: NSNotification.Name(rawValue: "toMainVC"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showMenu), name: NSNotification.Name(rawValue: "show_menu"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideMenu), name: NSNotification.Name(rawValue: "hide_menu"), object: nil)
    }
    
    func hasToken() -> Bool {
        return KeychainManager.fetchToken() == nil ? false : true
    }
    
    func handleLoginFlow() {
        if hasToken() {
            presentActivityIndicator()
            APIManager.getUser({ (success) in
                self.hideActivityIndicator()
                self.embedMainViewController()
            }, failure: { (error) in
                self.hideActivityIndicator()
                DispatchQueue.main.async(execute: {
                    self.embedLoginViewController()
                })
                debugPrint(error as Any)
            })
        } else {
            self.embedLoginViewController()
        }
    }
    
    func showMenu() {
        UIView.animate(withDuration: 10, delay: 0, options: [], animations: {
            self.containerViewHeightConstraint.constant = -30
            self.containerViewCenterXConstraint.constant = self.view.frame.width / 2
            self.mainAppContainerView.layoutIfNeeded()
        }) { (success) in
            
        }
    }
    
    func hideMenu() {
        UIView.animate(withDuration: 0.3) {
            self.containerViewHeightConstraint.constant = 0
            self.containerViewCenterXConstraint.constant = 0
            self.mainAppContainerView.layoutIfNeeded()
            self.view.layoutIfNeeded()
        }
    }
    
    func embedMainViewController(with reps: [Person]? = nil) {
        let tabVC = UITabBarController()
        let navVC = UINavigationController()
        let vc: MainViewController = MainViewController.instantiate()
        navVC.setViewControllers([vc], animated: false)
        tabVC.setViewControllers([navVC], animated: false)
        embedViewController(tabVC)
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

