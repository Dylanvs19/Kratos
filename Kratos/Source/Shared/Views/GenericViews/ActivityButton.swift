//
//  ActivityButton.swift
//  Kratos
//
//  Created by Dylan Straughan on 4/17/18.
//  Copyright © 2018 Dylan Straughan. All rights reserved.
//

import UIKit
import RxSwift

class ActivityButton: UIButton {
    // MARK: - properties -
    private let disposeBag = DisposeBag()
    let active = BehaviorSubject(value: false)
    private let spinner = UIActivityIndicatorView(activityIndicatorStyle: .white)
    private let style: ButtonStyle
    
    // MARK: - initialization -
    init(style: ButtonStyle) {
        self.style = style
        super.init(frame: .zero)
        
        styleViews()
        addSubviews()
        
        bind()
    }
    
    override var isEnabled: Bool {
        didSet {
            animate(isEnabled)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - internal -
    private func animate(for isActive: Bool) {
        if isActive { spinner.startAnimating() }
        
        UIView.animate(withDuration: 0.1, animations: {
            self.spinner.alpha = isActive ? 1 : 0
            self.titleLabel?.alpha = isActive ? 0 : 1
        }) { [unowned self] _ in
            if !isActive {
                self.spinner.stopAnimating()
            }
        }
    }
    
    private func animate(_ isEnabled: Bool) {
        UIView.animate(withDuration: 0.1) {
            let color = isEnabled ? self.style.textColor.value : self.style.disabledTextColor.value
            self.titleLabel?.textColor = color
        }
    }
}

// MARK: - ViewBuilder -
extension ActivityButton: ViewBuilder {
    func styleViews() {
        backgroundColor = .clear
        if let highlighted = style.highlightedBackgroundColor?.value {
            setBackgroundImage(UIImage.from(color: highlighted), for: .highlighted)
        }
        if let disabled = style.disabledBackgroundColor?.value {
            setBackgroundImage(UIImage.from(color: disabled), for: .disabled)
        }
        setBackgroundImage(UIImage.from(color: style.backgroundColor.value), for: .normal)
        titleLabel?.font = style.font.value
        setTitleColor(style.textColor.value, for: .normal)
        setTitleColor(style.highlightedTextColor.value, for: .highlighted)
        setTitleColor(style.disabledTextColor.value, for: .disabled)

        if let radius = style.cornerRadius {
            layer.cornerRadius = radius
        }
        clipsToBounds = true
    }
    
    func addSubviews() {
        addSpinner()
    }
    
    private func addSpinner() {
        addSubview(spinner)
        
        spinner.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.top.bottom.equalToSuperview().inset(5)
            make.width.equalTo(spinner.snp.height)
        }
    }
}

// MARK: - RxBinder -
extension ActivityButton: RxBinder {
    func bind() {
        active
            .subscribe(onNext: { [unowned self] in self.animate(for: $0)})
            .disposed(by: disposeBag)
        
        active
            .map { !$0 }
            .bind(to: rx.isEnabled)
            .disposed(by: disposeBag)
    }
}
