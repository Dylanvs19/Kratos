//
//  LabelStyle.swift
//  Kratos
//
//  Created by Dylan Straughan on 4/19/18.
//  Copyright © 2018 Dylan Straughan. All rights reserved.
//

import UIKit

struct LabelStyle {
    let font: Font
    let textColor: Color
    
    static let h1 = LabelStyle(font: .h1, textColor: .gray)
    static let h3 = LabelStyle(font: .h3, textColor: .black)
    static let h3gray = LabelStyle(font: .h3, textColor: .gray)
    static let h3white = LabelStyle(font: .h3, textColor: .white)
    static let h5lightGrey = LabelStyle(font: .h5, textColor: .lightGray)
    static let h5white = LabelStyle(font: .h5, textColor: .white)
    static let tab = LabelStyle(font: .tab, textColor: .kratosRed)
    static let bodyGray = LabelStyle(font: .body, textColor: .gray)
}
