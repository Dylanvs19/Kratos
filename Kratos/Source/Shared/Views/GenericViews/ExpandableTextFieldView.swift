//
//  ExpandableTextFieldView.swift
//  Kratos
//
//  Created by Dylan Straughan on 6/24/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import RxSwift
import RxCocoa

class ExpandableTextFieldView: UIView {
   // MARK: - Enums -
    enum State {
        case expanded
        case contracted
        
        var chevronPosition: CGFloat {
            switch self {
            case .expanded:
                return .pi/2
            case .contracted:
                return 3 * .pi/2
            }
        }
    }
    // MARK: - Variables -
    
    // Standard
    let viewModel = ExpandableTextFieldViewModel()
    let disposeBag = DisposeBag()
    
    // UIElements
    var titleLabel = UILabel()
    let textView = UITextView()
    var toggleButton = UIButton()
    var chevronImageView = UIImageView(image: #imageLiteral(resourceName: "chevronRedIcon").af_imageScaled(to: CGSize(width: 25, height: 10)))
    
    // Static helpers
    var expandedHeight: CGFloat = 400
    var contractedHeight: CGFloat = 150
    
    var expandedButtonHeight: CGFloat = 30
    var forceCollapseToggleButton: Bool = false
    
    // MARK: - Initialization - 
    convenience init(forceCollapseToggleButton: Bool) {
        self.init(frame: .zero)
        self.forceCollapseToggleButton = forceCollapseToggleButton
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func build() {
        addSubviews()
        constrainViews()
        styleViews()
        bind()
    }
    
    // MARK: - Configuration -
    func set(title: String) {
        viewModel.set(title)
    }
    func update(with text: String) {
        viewModel.update(with: text)
    }
    
    func set(contractedHeight: CGFloat, expandedHeight: CGFloat) {
        self.expandedHeight = expandedHeight
        self.contractedHeight = contractedHeight
    }
    
    // MARK: - Helpers - 
    func collapseTitleLabel() {
        titleLabel.snp.remakeConstraints { make in
            make.top.equalToSuperview().offset(0)
            make.leading.equalToSuperview().offset(10)
            make.height.equalTo(0)
        }
    }
    
    func update(for state: State) {
        let isContracted = state == .contracted
        textView.isScrollEnabled = !isContracted
        let totalHeight = textView.sizeThatFits(CGSize(width: textView.frame.size.width, height: .greatestFiniteMagnitude)).height
        
        let offset = isContracted ? contractedHeight : min(totalHeight, expandedHeight)
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.textView.snp.updateConstraints { make in
                make.height.equalTo(offset)
            }
            //Changing the content offset for the scrollView
            //For smooth animation, must call scrollview LayoutIfNeeded
            // general View Heirarchy is ScrollView -> StackView -> ExpandableTextFieldView
            if let scroll = self.superview?.superview,
                let scrollView = scroll as? UIScrollView {
                scrollView.layoutIfNeeded()
            } else if let scroll = self.superview,
                      let scrollView = scroll as? UIScrollView {
                scrollView.layoutIfNeeded()
            } else {
                self.layoutIfNeeded()
            }
            if !isContracted {
                self.chevronImageView.transform = self.chevronImageView.transform.rotated(by: .pi)
            } else {
                self.chevronImageView.transform = .identity
            }
            self.layoutIfNeeded()
        }, completion: nil)
    }
    
    
    func evaluateButton() {
        let size = CGSize(width: textView.frame.size.width,
                          height: .greatestFiniteMagnitude)
        
        let totalHeight = textView.sizeThatFits(size).height
        toggleButton.clipsToBounds = true
        
        if forceCollapseToggleButton || totalHeight < contractedHeight {
            toggleButton.isEnabled = false
            chevronImageView.isHidden = true
            toggleButton.snp.updateConstraints { make in
                make.height.equalTo(0)
            }
            textView.snp.remakeConstraints { make in
                make.leading.trailing.equalToSuperview().inset(10)
                make.top.equalTo(titleLabel.snp.bottom).offset(5)
                make.bottom.equalTo(toggleButton.snp.top)
                make.height.equalTo(totalHeight)
            }
        } else {
            toggleButton.isEnabled = true
            chevronImageView.isHidden = false
            let buttonHeight = expandedButtonHeight
            toggleButton.snp.updateConstraints { make in
                make.height.equalTo(buttonHeight)
            }
            textView.snp.remakeConstraints { make in
                make.leading.trailing.equalToSuperview().inset(10)
                make.top.equalTo(titleLabel.snp.bottom).offset(5)
                make.bottom.equalTo(toggleButton.snp.top)
                make.height.equalTo(self.contractedHeight)
            }
        }
        layoutIfNeeded()
    }
}

// MARK: - ViewBuilder -
extension ExpandableTextFieldView: ViewBuilder {
    func addSubviews() {
        addSubview(titleLabel)
        addSubview(toggleButton)
        addSubview(textView)
        addSubview(chevronImageView)
    }
    func constrainViews() {
        titleLabel.snp.remakeConstraints { make in
            make.top.equalToSuperview().offset(5)
            make.leading.trailing.equalToSuperview().inset(10)
        }
        toggleButton.snp.remakeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(10)
            make.bottom.equalToSuperview().offset(-5)
            make.height.equalTo(expandedButtonHeight)
        }
        textView.snp.remakeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(10)
            make.top.equalTo(titleLabel.snp.bottom).offset(5)
            make.bottom.equalTo(toggleButton.snp.top)
            make.height.equalTo(self.contractedHeight)
        }
        chevronImageView.snp.remakeConstraints { make in
            make.centerX.centerY.equalTo(toggleButton)
        }
        textView.layoutIfNeeded()
        layoutIfNeeded()
    }

    func styleViews() {
        backgroundColor = .white
        textView.isEditable = false
        titleLabel.style(with: [.font(.subTitle), .titleColor(.lightGray)])
        textView.style(with: .font(.body))
        toggleButton.style(with: [.font(.cellTitle), .titleColor(.kratosRed)])
    }
}

// MARK: - Binds -
extension ExpandableTextFieldView: RxBinder {
    
    func bind() {
        bindTitleLabel()
        bindTextView()
        bindToggleButton()
    }
    
    func bindTitleLabel() {
        viewModel.title.asObservable()
            .bind(to: titleLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.text.asObservable()
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] string in
                if let s = self {
                    if string.isEmpty {
                        s.collapseTitleLabel()
                    }
                }
            })
            .disposed(by: disposeBag)
    }
    
    func bindTextView() {
        viewModel.text.asObservable()
            .bind(to: textView.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.text.asObservable()
            .filter { !$0.isEmpty }
            .subscribe(onNext: { [weak self] string in
                self?.evaluateButton()
            })
            .disposed(by: disposeBag)
        viewModel.state.asObservable()
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] state in
                self?.update(for: state)
            })
            .disposed(by: disposeBag)
    }
    
    func bindToggleButton() {
        toggleButton.rx.tap
            .bind(to: viewModel.toggleButtonPressed)
            .disposed(by: disposeBag)
    }
}
