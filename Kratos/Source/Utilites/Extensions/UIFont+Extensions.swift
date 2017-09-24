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
        return UIFont(name: "Futura", size: 28) ?? .systemFont(ofSize: 24)
    }
    static var titleFont: UIFont {
        return UIFont(name: "Futura", size: 24) ?? .systemFont(ofSize: 20)
    }
    static var subHeaderFont: UIFont {
        return UIFont(name: "Futura", size: 20) ?? .systemFont(ofSize: 17)
    }
    static var subTitleFont: UIFont {
        return UIFont(name: "AvenirNext-Medium", size: 20) ?? .systemFont(ofSize: 17)
    }
    static var cellTitleFont: UIFont {
        return UIFont(name: "Futura", size: 17) ?? .systemFont(ofSize: 17)
    }
    static var tabFont: UIFont {
        return UIFont(name: "AvenirNext-Medium", size: 15) ?? .systemFont(ofSize: 16)
    }
    static var cellSubtitleFont: UIFont {
        return UIFont(name: "AvenirNext-Regular", size: 14) ?? .systemFont(ofSize: 14)
    }
    static var bodyFont: UIFont {
        return UIFont(name: "AvenirNext-Regular", size: 15) ?? .systemFont(ofSize: 15)
    }
    static var textFont: UIFont {
        return UIFont(name: "AvenirNext-Medium", size: 13) ?? .systemFont(ofSize: 13)
    }
    static var monospaced: UIFont {
        return UIFont(name: "ArialMT", size: 20) ?? .systemFont(ofSize: 20)
    }
}
