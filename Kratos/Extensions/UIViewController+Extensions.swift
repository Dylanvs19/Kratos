//
//  UIViewController+Extensions.swift
//  Kratos
//
//  Created by Dylan Straughan on 7/31/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import UIKit
import SafariServices

extension UIViewController {

    static func instantiate <ViewController: UIViewController> () -> ViewController {
        if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: String(describing: ViewController.self)) as? ViewController {
            return viewController
        }
        fatalError("\(String(describing: ViewController.self)) was not able to load")
    }
    
    func enableSwipeBack() {
        let swipeGR = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeRight(_:)))
        swipeGR.direction = .right
        view.addGestureRecognizer(swipeGR)
        view.removeRepInfoView()
        view.removeBlurEffect()
    }
    
    func handleSwipeRight(_ gestureRecognizer: UIGestureRecognizer) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    func presentTwitter(with person: Person) {
        guard let handle = person.twitter else {
            let alertVC = UIAlertController(title: "Error", message: "Representative does not have a twitter account", preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "O K ", style: .destructive, handler: nil))
            present(alertVC, animated: true, completion: nil)
            return
        }
        
        if let url = URL(string: "twitter://user?screen_name=\(handle)"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            if let url = URL(string: "https://twitter.com/\(handle)") {
                let vc = SFSafariViewController(url: url)
                self.present(vc, animated: true, completion: nil)
            }
        }
    }
    
    func presentHomeAddress(with person: Person) {
        var address = "Could not find an office address for this representative"
        if let addy = person.roles?.first?.officeAddress {
            address = addy
        }
        let alertVC = UIAlertController(title: "A D D R E S S", message: address, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "O K ", style: .destructive, handler: nil))
        present(alertVC, animated: true, completion: nil)
    }
}


