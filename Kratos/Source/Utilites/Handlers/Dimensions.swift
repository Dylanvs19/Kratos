//
//  Dimensions.swift
//  Kratos
//
//  Created by Dylan Straughan on 11/30/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import Foundation
import UIKit

struct Dimension {
    /// 8pt
    static let smallMargin: CGFloat = 8
    /// 16pt
    static let defaultMargin: CGFloat = 16
    /// if iphonex 0px, else 24px
    static var iPhoneXMargin: CGFloat {
        return UIScreen.isIPhoneX ? 0 : mediumMargin
    }
    /// 24pt
    static let mediumMargin: CGFloat = 24
    /// 32pt
    static let largeMargin: CGFloat = 32
    /// 55pt
    static let largeButtonHeight: CGFloat = 50
    /// 45pt
    static let tabButtonHeight: CGFloat = 45
    /// 40pt
    static let textfieldHeight: CGFloat = 40
    /// 90px
    static let smallImageViewHeight: CGFloat = 90
    /// 200px
    static let largeImageViewHeight: CGFloat = 200
    /// 64px, 84 if iPhoneX
    static var topMargin: CGFloat {
        return UIScreen.isIPhoneX ? 84 : 64
    }
    static var topTitlePosition: CGFloat {
        return UIScreen.isIPhoneX ? 54 : 34
    }
}
