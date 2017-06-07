//
//  SplashViewController.swift
//  Kratos
//
//  Created by Dylan Straughan on 5/13/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import Foundation
import UIKit

class SplashViewController: UIViewController {
    
    var onAnimationCompletion: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super .viewDidAppear(animated)
        onAnimationCompletion?()
    }
    
}
