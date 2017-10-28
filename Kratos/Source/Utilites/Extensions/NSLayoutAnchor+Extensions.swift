//
//  NSLayoutAnchor+Extensions.swift
//  Kratos
//
//  Created by Dylan Straughan on 4/30/17.
//  Copyright © 2017 Kratos, Inc. All rights reserved.
//

import UIKit
import Foundation

extension NSLayoutAnchor {
    
    @discardableResult func constrain(equalTo anchor: NSLayoutAnchor, constant: CGFloat = 0, priority: Float = 1000) -> NSLayoutConstraint {
        let constraint = self.constraint(equalTo: anchor, constant: constant)
        constraint.priority = priority
        constraint.isActive = true
        return constraint
    }
    
    @discardableResult func constrain(lessThanOrEqualTo anchor: NSLayoutAnchor, constant: CGFloat = 0, priority: Float = 1000) -> NSLayoutConstraint{
        let constraint = self.constraint(lessThanOrEqualTo: anchor, constant: constant)
        constraint.priority = priority
        constraint.isActive = true
        return constraint

    }
    
    @discardableResult func constrain(greaterThanOrEqualTo anchor: NSLayoutAnchor, constant: CGFloat = 0, priority: Float = 1000) -> NSLayoutConstraint{
        let constraint = self.constraint(greaterThanOrEqualTo: anchor, constant: constant)
        constraint.priority = priority
        constraint.isActive = true
        return constraint
    }
}

extension NSLayoutDimension {
    @discardableResult func constrain(to dimension: NSLayoutDimension, constant: CGFloat = 0, priority: Float = 1000) -> NSLayoutConstraint{
        let constraint = self.constraint(equalTo: dimension, multiplier: 1, constant: constant)
        constraint.priority = priority
        constraint.isActive = true
        return constraint
    }
    
    @discardableResult func constrain(equalTo constant: CGFloat = 0, priority: Float = 1000) -> NSLayoutConstraint{
        let constraint = self.constraint(equalToConstant: constant)
        constraint.priority = priority
        constraint.isActive = true
        return constraint
    }
    
    @discardableResult func constrain(lessThanOrEqualTo constant: CGFloat = 0, priority: Float = 1000) -> NSLayoutConstraint{
        let constraint = self.constraint(lessThanOrEqualToConstant: constant)
        constraint.priority = priority
        constraint.isActive = true
        return constraint
    }
    
    @discardableResult func constrain(greaterThanOrEqualTo constant: CGFloat = 0, priority: Float = 1000) -> NSLayoutConstraint{
        let constraint = self.constraint(greaterThanOrEqualToConstant: constant)
        constraint.priority = priority
        constraint.isActive = true
        return constraint
    }
}
