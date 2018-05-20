//
//  Button.swift
//  Kratos
//
//  Created by Dylan Straughan on 4/17/18.
//  Copyright © 2018 Dylan Straughan. All rights reserved.
//

import UIKit
import RxSwift

class Button: UIButton {
    private let style: ButtonStyle
    
    // MARK: - initialization -
    init(style buttonStyle: ButtonStyle) {
        self.style = buttonStyle
        super.init(frame: .zero)
        
        styleViews()
        addSubviews()
    }
    
    override var isEnabled: Bool {
        didSet {
            animate(isEnabled)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func animate(_ isEnabled: Bool) {
        UIView.animate(withDuration: 0.1) {
            let color = isEnabled ? self.style.textColor.value : self.style.disabledTextColor.value
            self.titleLabel?.textColor = color
        }
    }
}

// MARK: - ViewBuilder -
extension Button: ViewBuilder {
    func addSubviews() {}
    
    func styleViews() {
        backgroundColor = .clear
        if let highlighted = style.highlightedBackgroundColor?.value {
            setBackgroundImage(UIImage.from(color: highlighted), for: .highlighted)
        }
        if let disabled = style.disabledBackgroundColor?.value {
            setBackgroundImage(UIImage.from(color: disabled), for: .disabled)
        }
        setBackgroundImage(UIImage.from(color: style.backgroundColor.value), for: .normal)
        setTitleColor(style.textColor.value, for: .normal)
        setTitleColor(style.highlightedTextColor.value, for: .highlighted)
        setTitleColor(style.disabledTextColor.value, for: .disabled)
        titleLabel?.font = style.font.value
        
        if let radius = style.cornerRadius {
            layer.cornerRadius = radius
        }
        clipsToBounds = true 
    }
}
