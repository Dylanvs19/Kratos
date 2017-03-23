//
//  MenuViewController.swift
//  Kratos
//
//  Created by Dylan Straughan on 3/22/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {
    
    var interactor:Interactor? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func accountButtonPressed(_ sender: Any) {
        
        let vc: SubmitAddressViewController = SubmitAddressViewController.instantiate()
        vc.loadViewIfNeeded()
        vc.displayType = .accountDetails
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func feedbackButtonPressed(_ sender: Any) {
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
    
    func handleGesture(sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: view)
        
        let progress = MenuHelper.calculateProgress(translationInView: translation, viewBounds: view.bounds, direction: .Left)
        
        MenuHelper.mapGestureStateToInteractor(
            gestureState: sender.state,
            progress: progress,
            interactor: interactor){
                self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func closeMenu(_ sender: Any) {
        dismiss(animated: true, completion: nil) 
    }
}

