//
//  KratosFonts.swift
//  Kratos
//
//  Created by Dylan Straughan on 2/6/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import UIKit

enum KratosFont {
    
    case futuraRegular(size: CGFloat)
    case AvenirNextRegular(size: CGFloat)
    case AvenirNextMedium(size: CGFloat)
    case AvenirNextDemiBold(size: CGFloat)
    
    var font: UIFont {
        switch self {
        case .futuraRegular(let size):
            return UIFont(name: "Futura-Regular", size: size)!
        case .AvenirNextRegular(let size):
            return UIFont(name: "AvenirNext-Regular", size: size)!
        case .AvenirNextMedium(let size):
            return UIFont(name: "AvenirNext-Medium", size: size)!
        case .AvenirNextDemiBold(let size):
            return UIFont(name: "AvenirNext-DemiBold", size: size)!
        }
    }
}
