//
//  MenuViewController.swift
//  Kratos
//
//  Created by Dylan Straughan on 11/15/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 3, height: 0)
        view.layer.shadowOpacity = 0.3
        view.layer.shadowRadius = 1
    }
    
    @IBAction func accountButtonPressed(_ sender: Any) {
        let vc: SubmitAddressViewController = SubmitAddressViewController.instantiate()
        vc.loadViewIfNeeded()
        vc.displayType = .accountDetails
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func votesButtonPressed(_ sender: Any) {
        let navVC = UINavigationController()
        let vc: YourVotesViewController = YourVotesViewController.instantiate()
        navVC.setViewControllers([vc], animated: false)
        vc.loadViewIfNeeded()
        self.present(navVC, animated: true, completion: nil)
    }
    
    @IBAction func infoButtonPressed(_ sender: Any) {
        let vc: FeedbackViewController = FeedbackViewController.instantiate()
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func signOutButtonPressed(_ sender: Any) {
        KeychainManager.delete { (success) in
            if success {
                NotificationCenter.default.post(name: Notification.Name(rawValue: "toMainVC"), object: nil)
            } else {
                let alertVC = UIAlertController(title: "Error", message: "There was an issue loging out of Kratos", preferredStyle: .alert)
                alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                present(alertVC, animated: true, completion: nil)
            }
        }
    }
}
