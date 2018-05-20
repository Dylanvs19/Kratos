//
//  Styler.swift
//  Kratos
//
//  Created by Dylan Straughan on 7/26/17.
//  Copyright © 2017 Kratos, Inc. All rights reserved.
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
    /// Futura 28px
    case h1
    /// Futura 24px
    case h2
    /// Futura 20px
    case h3
    /// AvenirNext-Medium 20px
    case h4
    /// ArialMT 20px
    case monospaced
    /// Futura 17px
    case h5
    /// AvenirNext-Medium 15px
    case tab
    /// AvenirNext-Regular 14px
    case body
    
    
    var value: UIFont {
        switch self {
        case .h1:
            return .h1
        case .h2:
            return .h2
        case .h3:
            return .h3
        case .h4:
            return .h4
        case .h5:
            return .h5
        case .monospaced:
            return .monospaced
        case .tab:
            return .tabFont
        case .body:
            return .bodyFont
        }
    }
}

enum Color {
    /// r: 0, g: 0, b: 0 a: 1
    case black
    /// r: 255, g: 255, b: 255 a: 1
    case white
    /// r: 243, g: 243, b: 243 a: 1
    case slate
    /// 0.5 white
    case gray
    /// r: 255, g: 0, b: 0 a: 1
    case red
    /// 0.667 white
    case lightGray
    /// r: 207, g: 0, b: 0 a: 1
    case kratosRed
    /// r: 0, g: 0, b: 100 a: 1
    case kratosBlue
    /// r: 25, g: 25, b: 112 a: 1
    case darkBlue
    /// r: 126, g: 211, b: 33 a: 1
    case kratosGreen
    /// a: 0
    case clear
    /// r: 255, g: 255, b: 255 a: 0.01
    case clearWhite
    
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
        case .clear:
            return .clear
        case .clearWhite:
            return UIColor.white.withAlphaComponent(0.01)
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
