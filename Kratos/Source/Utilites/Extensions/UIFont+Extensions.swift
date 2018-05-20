//
//  UIFont+Extensions.swift
//  Kratos
//
//  Created by Dylan Straughan on 7/25/17.
//  Copyright © 2017 Kratos, Inc. All rights reserved.
//

import Foundation
import UIKit

extension UIFont {
    
    static var h1: UIFont {
        return UIFont(name: "Futura", size: 28) ?? .systemFont(ofSize: 28)
    }
    static var h2: UIFont {
        return UIFont(name: "Futura", size: 24) ?? .systemFont(ofSize: 24)
    }
    static var h3: UIFont {
        return UIFont(name: "Futura", size: 20) ?? .systemFont(ofSize: 20)
    }
    static var h4: UIFont {
        return UIFont(name: "AvenirNext-Medium", size: 20) ?? .systemFont(ofSize: 20)
    }
    static var h5: UIFont {
        return UIFont(name: "Futura", size: 17) ?? .systemFont(ofSize: 17)
    }
    static var monospaced: UIFont {
        return UIFont(name: "ArialMT", size: 20) ?? .systemFont(ofSize: 20)
    }
    static var tabFont: UIFont {
        return UIFont(name: "AvenirNext-Medium", size: 15) ?? .systemFont(ofSize: 15)
    }
    static var bodyFont: UIFont {
        return UIFont(name: "AvenirNext-Regular", size: 14) ?? .systemFont(ofSize: 14)
    }
}
