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
        
        embedSubmitAddressViewController()
    }
    
    func embedSubmitAddressViewController() {
        let vc: SubmitAddressViewController = SubmitAddressViewController.fromStoryBoard("Main")
        embedViewController(vc)
    }
    
    func embedMainViewController() {
        let vc: MainViewController = MainViewController.fromStoryBoard("Main")
        embedViewController(vc)
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
        mainAppContainerView.addSubview(controller.view)
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        controller.view.topAnchor.constraintEqualToAnchor(view.topAnchor).active = true
        controller.view.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor).active = true
        controller.view.leftAnchor.constraintEqualToAnchor(view.leftAnchor).active = true
        controller.view.rightAnchor.constraintEqualToAnchor(view.rightAnchor).active = true
        controller.didMoveToParentViewController(self)
    }
    
}

