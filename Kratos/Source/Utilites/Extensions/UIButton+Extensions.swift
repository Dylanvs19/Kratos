//
//  UIButton+Extensions.swift
//  Kratos
//
//  Created by Dylan Straughan on 5/22/17.
//  Copyright © 2017 Kratos, Inc. All rights reserved.
//

import Foundation
import UIKit

extension UIButton {
    
    func animateTitleChange(to title: String) {
        UIView.animate(withDuration: 0.1) {
            self.setTitle(title, for: .normal)
            self.layoutIfNeeded()
        }
    }
}
