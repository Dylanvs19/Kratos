//
//  Styles.swift
//  Kratos
//
//  Created by Dylan Straughan on 4/17/18.
//  Copyright © 2018 Dylan Straughan. All rights reserved.
//

import UIKit

struct ButtonStyle {
    let backgroundColor: Color
    let disabledBackgroundColor: Color?
    let highlightedBackgroundColor: Color?
    let font: Font
    let textColor: Color
    let highlightedTextColor: Color
    let disabledTextColor: Color
    let cornerRadius: CGFloat?
    let borderColor: Color?
    let borderWidth: CGFloat?
    let height: CGFloat
}

extension ButtonStyle {
    static let cta = ButtonStyle(backgroundColor: .kratosRed,
                                 disabledBackgroundColor: .gray,
                                 highlightedBackgroundColor: .red,
                                 font: .header,
                                 textColor: .white,
                                 highlightedTextColor: .white,
                                 disabledTextColor: .white,
                                 cornerRadius: Dimension.largeButtonHeight/2,
                                 borderColor: nil,
                                 borderWidth: nil,
                                 height: Dimension.largeButtonHeight)
    static let b1 = ButtonStyle(backgroundColor: .white,
                                 disabledBackgroundColor: .white,
                                 highlightedBackgroundColor: .white,
                                 font: .title,
                                 textColor: .gray,
                                 highlightedTextColor: .lightGray,
                                 disabledTextColor: .lightGray,
                                 cornerRadius: 0,
                                 borderColor: nil,
                                 borderWidth: nil,
                                 height: Dimension.textfieldHeight)
}
