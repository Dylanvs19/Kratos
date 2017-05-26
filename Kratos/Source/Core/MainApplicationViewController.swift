//
//  ViewController.swift
//  Kratos
//
//  Created by Dylan Straughan on 7/30/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import UIKit
import RxSwift
import SnapKit

class MainApplicationViewController: UIViewController, ViewBuilder, ActivityIndicatorPresenter {
    
    lazy var mainAppContainerView = UIView()
    var activityIndicator: KratosActivityIndicator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNotificationObservers()
        handleLoginFlow()
    }
    
    func style() {}
    
    func buildViews() {
        self.view.addSubview(mainAppContainerView)
        mainAppContainerView.snp.makeConstraints { make in
            make.edges.equalTo(self.view)
        }
    }
    
    func setupNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleLoginFlow), name: NSNotification.Name(rawValue: "toMainVC"), object: nil)
    }
    
    func hasToken() -> Bool {
        return KeychainManager.token == nil ? false : true
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
    
    func embedMainViewController(with reps: [Person]? = nil) {
        let tabVC:TabBarController = TabBarController.instantiate()
        tabVC.configure()
        embedViewController(tabVC)
    }
    
    func embedLoginViewController() {
        let navVC = UINavigationController()
        let vc: LoginViewController = LoginViewController.instantiate()
        navVC.setViewControllers([vc], animated: false)
        embedViewController(navVC)
    }
    
    func embedViewController(_ controller: UIViewController) {
        
        guard !childViewControllers.contains(controller) else { return }
        
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

