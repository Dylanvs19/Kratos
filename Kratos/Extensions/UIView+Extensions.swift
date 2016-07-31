//
//  UIView+Extensions.swift
//  Kratos
//
//  Created by Dylan Straughan on 7/30/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import UIKit

extension UIView {
    
    func pin(contentView:UIView) {
        NSBundle.mainBundle().loadNibNamed(String(self), owner: self, options: nil)
        translatesAutoresizingMaskIntoConstraints = false
        contentView.topAnchor.constraintEqualToAnchor(topAnchor).active = true
        contentView.bottomAnchor.constraintEqualToAnchor(bottomAnchor).active = true
        contentView.leftAnchor.constraintEqualToAnchor(leftAnchor).active = true
        contentView.rightAnchor.constraintEqualToAnchor(rightAnchor).active = true
        layoutIfNeeded()
    }
    
}
 