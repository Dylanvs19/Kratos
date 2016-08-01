//
//  UIViewController+Extensions.swift
//  Kratos
//
//  Created by Dylan Straughan on 7/31/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import UIKit

extension UIViewController {

    static func fromStoryBoard <ViewController where ViewController: UIViewController> (storyBoard: String) -> ViewController {
        if let viewController = UIStoryboard(name: storyBoard, bundle: nil).instantiateViewControllerWithIdentifier(String(ViewController)) as? ViewController {
            return viewController
        }
        fatalError("\(String(ViewController)) was not able to load")
    }
}
