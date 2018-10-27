//
//  UIScreen+Size.swift
//  Kratos
//
//  Created by Dylan Straughan on 4/30/18.
//  Copyright © 2018 Dylan Straughan. All rights reserved.
//

import UIKit

extension UIScreen {
    
    static var isIPhoneX: Bool {
        return UIDevice.current.userInterfaceIdiom == .phone && UIScreen.main.bounds.size.height == 812
    }
    
    static var isIPhoneXSMax: Bool {
        return UIDevice.current.userInterfaceIdiom == .phone && UIScreen.main.bounds.size.height == 896
    }
    
    static var shouldElevateBottomMargin: Bool {
        return isIPhoneX || isIPhoneXSMax
    }
}
