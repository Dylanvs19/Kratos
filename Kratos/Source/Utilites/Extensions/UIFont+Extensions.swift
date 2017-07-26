//
//  UIFont+Extensions.swift
//  Kratos
//
//  Created by Dylan Straughan on 7/25/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import Foundation
import UIKit

extension UIFont {
    
    static var header: UIFont {
        return UIFont(name: "Futura", size: 24)!
    }
    static var title: UIFont {
        return UIFont(name: "Futura", size: 17)!
    }
    static var subTitle: UIFont {
        return UIFont(name: "Futura", size: 15)!
    }
    
    static var cellTitle: UIFont {
        return UIFont(name: "Futura", size: 15)!
    }
    static var cellSubtitle: UIFont {
        return UIFont(name: "AvenirNext-Regular", size: 13)!
    }
    
    static var body: UIFont {
        return UIFont(name: "AvenirNext-Regular", size: 14)!
    }
    static var text: UIFont {
        return UIFont(name: "AvenirNext-Medium", size: 12)!
    }
    
    //UIButton Fonts
    
    /// For larger, standAlone buttons
    static var largeButton: UIFont {
        return UIFont(name: "Futura", size: 24)!
    }
    /// For medium buttons 
    /// - Note: bioInfoView, repInfoView, etc.
    static var mediumButton: UIFont {
        return UIFont(name: "Futura", size: 14)!
    }
}
