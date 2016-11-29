//
//  MenuViewController.swift
//  Kratos
//
//  Created by Dylan Straughan on 11/15/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {
    
    
    @IBOutlet var accountTrailingConstraint: NSLayoutConstraint!
    @IBOutlet var votesTrailingConstraint: NSLayoutConstraint!
    @IBOutlet var infoTrailingConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func animateIn() {
       let array = [accountTrailingConstraint, votesTrailingConstraint, infoTrailingConstraint]
        var count = 0.2
        array.forEach { (constraint) in
            UIView.animate(withDuration: 0.2, delay: count, usingSpringWithDamping: 0.8, initialSpringVelocity: 2.0, options: .curveEaseInOut, animations: {
                constraint?.constant = 0
                self.view.layoutIfNeeded()
            }, completion: nil)
            count += 0.02
        }
    }
    
    func animateOut() {
        let array = [accountTrailingConstraint, votesTrailingConstraint, infoTrailingConstraint]
        var count = 0.2
        array.forEach { (constraint) in
            UIView.animate(withDuration: 0.2, delay: count, options: .curveEaseInOut, animations: {
                constraint?.constant = 100
                self.view.layoutIfNeeded()
            }, completion: nil)
            count += 0.1
        }
    }
    
    @IBAction func accountButtonPressed(_ sender: Any) {
        // to edit account vc
    }
    
    @IBAction func votesButtonPressed(_ sender: Any) {
        // to myVotes vc
    }
    
    @IBAction func infoButtonPressed(_ sender: Any) {
        // to info vc
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
