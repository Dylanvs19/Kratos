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
        return UIScreen.main.bounds.size.height == 812
    }
}
