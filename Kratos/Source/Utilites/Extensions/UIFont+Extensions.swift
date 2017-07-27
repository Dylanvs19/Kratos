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
    
    static var headerFont: UIFont {
        return UIFont(name: "Futura", size: 24)!
    }
    static var titleFont: UIFont {
        return UIFont(name: "Futura", size: 17)!
    }
    static var subHeaderFont: UIFont {
        return UIFont(name: "Futura", size: 15)!
    }
    static var subTitleFont: UIFont {
        return UIFont(name: "AvenirNext-Medium", size: 15)!
    }
    static var cellTitleFont: UIFont {
        return UIFont(name: "Futura", size: 14)!
    }
    static var cellSubtitleFont: UIFont {
        return UIFont(name: "AvenirNext-Regular", size: 13)!
    }
    static var bodyFont: UIFont {
        return UIFont(name: "AvenirNext-Regular", size: 14)!
    }
    static var textFont: UIFont {
        return UIFont(name: "AvenirNext-Medium", size: 12)!
    }
}
