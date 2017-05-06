//
//  UIImageView+Extensions.swift
//  Kratos
//
//  Created by Dylan Straughan on 1/7/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import UIKit

extension UIImageView {
    
    func addRepImageViewBorder() {
        layer.borderColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.2).cgColor
        layer.borderWidth = 2.0
        layer.cornerRadius = 2.0
    }
} 
