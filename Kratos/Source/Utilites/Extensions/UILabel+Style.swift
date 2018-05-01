//
//  UILabel+Style.swift
//  Kratos
//
//  Created by Dylan Straughan on 4/19/18.
//  Copyright © 2018 Dylan Straughan. All rights reserved.
//

import UIKit

extension UILabel {
    convenience init(style: LabelStyle) {
        self.init(frame: .zero)
        font = style.font.value
        textColor = style.textColor.value
    }
}
