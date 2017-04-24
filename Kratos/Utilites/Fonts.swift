//
//  KratosFonts.swift
//  Kratos
//
//  Created by Dylan Straughan on 2/6/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import UIKit

enum Font {
    case futuraStandard
    case futura(size: CGFloat)
    case futuraBold(size: CGFloat)
    case avenirNextStandard
    case avenirNext(size: CGFloat)
    case avenirNextMedium(size: CGFloat)
    case avenirNextDemiBold(size: CGFloat)
    
    var font: UIFont {
        switch self {
        case .futuraStandard:
            return UIFont(name: "Futura", size: 15)!
        case .futura(let size):
            return UIFont(name: "Futura", size: size)!
        case .futuraBold(let size):
            return UIFont(name: "Futura-Bold", size: size)!
        case .avenirNextStandard:
            return UIFont(name: "AvenirNext-Regular", size: 15)!
        case .avenirNext(let size):
            return UIFont(name: "AvenirNext-Regular", size: size)!
        case .avenirNextMedium(let size):
            return UIFont(name: "AvenirNext-Medium", size: size)!
        case .avenirNextDemiBold(let size):
            return UIFont(name: "AvenirNext-DemiBold", size: size)!
        }
    }
    
    static var title: UIFont {
        return UIFont(name: "Futura-Bold", size: 17)!
    }
    var subTitle: UIFont {
        return UIFont(name: "Futura-Bold", size: 15)!
    }
    var text: UIFont {
        return UIFont(name: "AvenirNext-Regular", size: 14)!
    }
}
