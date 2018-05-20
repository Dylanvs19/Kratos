//
//  UITabBar+extensions.swift
//  Kratos
//
//  Created by Dylan Straughan on 5/2/18.
//  Copyright © 2018 Dylan Straughan. All rights reserved.
//

import UIKit

extension UITabBar {
    func applyGradient(colors : [UIColor]) {
        backgroundImage = UIImage.gradient(size: self.bounds.size, colors: colors)
    }
}
