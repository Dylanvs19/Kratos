//
//  UIViewController+Extensions.swift
//  Kratos
//
//  Created by Dylan Straughan on 7/31/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import UIKit

extension UIViewController {

    static func instantiate <ViewController: UIViewController> () -> ViewController {
        if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: String(describing: ViewController.self)) as? ViewController {
            return viewController
        }
        fatalError("\(String(describing: ViewController.self)) was not able to load")
    }
    
    func setUpSwipe() {
        let swipeGR = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeRight(_:)))
        swipeGR.direction = .right
        view.addGestureRecognizer(swipeGR)
    }
    
    func handleSwipeRight(_ gestureRecognizer: UIGestureRecognizer) {
        _ = navigationController?.popViewController(animated: true)
        
    }
}
