//
//  Styler.swift
//  Kratos
//
//  Created by Dylan Straughan on 7/26/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import Foundation
import UIKit

protocol Stylable {
    func style(with traits: [Trait])
    func style(with trait: Trait)
}

enum Trait {
    case backgroundColor(Color)
    case titleColor(Color)
    case highlightedTitleColor(Color)
    case disabledTitleColor(Color)
    case borderColor(Color)
    case borderWidth(CGFloat)
    case cornerRadius(CGFloat)
    case font(Font)
    case numberOfLines(Int)
    case textAlignment(NSTextAlignment)
}

enum Font {
    case header
    case subheader
    case title
    case subTitle
    case cellTitle
    case cellSubTitle
    case body
    case text
    
    var value: UIFont {
        switch self {
        case .header:
            return .headerFont
        case .subheader:
            return .subHeaderFont
        case .title:
            return .titleFont
        case .subTitle:
            return .subTitleFont
        case .cellTitle:
            return .cellTitleFont
        case .cellSubTitle:
            return .cellSubtitleFont
        case .body:
            return .bodyFont
        case .text:
            return .textFont
        }
    }
}

enum Color {
    case black
    case white
    case slate
    case gray
    case red
    case lightGray
    case kratosRed
    case kratosBlue
    case darkBlue
    case kratosGreen
    
    var value: UIColor {
        switch self {
        case .black:
            return .black
        case .white:
            return .white
        case .slate:
            return .slate
        case .gray:
            return .gray
        case .red:
            return .red
        case .lightGray:
            return .lightGray
        case .kratosRed:
            return .kratosRed
        case .kratosBlue:
            return .kratosBlue
        case .darkBlue:
            return .darkBlue
        case .kratosGreen:
            return .kratosGreen
        }
    }
}

extension UIView: Stylable {
    
    func style(with traits: [Trait]) {
        traits.forEach { trait in
            self.style(with: trait)
        }
    }
    
    func style(with trait: Trait) {
        switch trait {
        case .backgroundColor(let color):
            self.backgroundColor = color.value
        case .titleColor(let color):
            if let button = self as? UIButton {
                button.setTitleColor(color.value, for: .normal)
            }
            if let label = self as? UILabel {
                label.textColor = color.value
            }
            if let field = self as? UITextField {
                field.textColor = color.value
            }
            if let view = self as? UITextView {
                view.textColor = color.value
            }
        case .highlightedTitleColor(let color):
            if let button = self as? UIButton {
                button.setTitleColor(color.value, for: .highlighted)
            }
        case .disabledTitleColor(let color):
            if let button = self as? UIButton {
                button.setTitleColor(color.value, for: .disabled)
            }
        case .borderColor(let color):
            self.layer.borderColor = color.value.cgColor
        case .borderWidth(let width):
            self.layer.borderWidth = width
        case .cornerRadius(let radius):
            self.layer.cornerRadius = radius
        case .font(let font):
            if let button = self as? UIButton {
                button.titleLabel?.font = font.value
            }
            if let label = self as? UILabel {
                label.font = font.value
            }
            if let field = self as? UITextField {
                field.font = font.value
            }
            if let view = self as? UITextView {
                view.font = font.value
            }
        case .numberOfLines(let number):
            if let label = self as? UILabel {
                label.numberOfLines = number
            }
        case .textAlignment(let alignment):
            if let label = self as? UILabel {
                label.textAlignment = alignment
            }
            if let field = self as? UITextField {
                field.textAlignment = alignment
            }
            if let view = self as? UITextView {
                view.textAlignment = alignment
            }
        }
    }
}
