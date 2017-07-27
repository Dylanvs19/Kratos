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
    
    enum State {
        case expanded
        case contracted
    }

    var titleLabel = UILabel()
    let textView = UITextView()
    var toggleButton = UIButton()
    
    var expandedHeight: CGFloat = 400
    var contractedHeight: CGFloat = 150
    
    var expandedButtonHeight: CGFloat = 30
    var forceCollapseButton: Bool = false
    
    var viewModel: ExpandableTextFieldViewModel? {
        didSet {
           if viewModel != nil {
                bind()
            }
        }
    }
    let disposeBag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        addSubviews()
        constrainViews()
        style()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with title: String?,
                   text: String,
                   expandedButtonTitle: String?,
                   contractedButtonTitle: String?) {
        
        self.viewModel = ExpandableTextFieldViewModel(with: title, text: text, expandedTitle: expandedButtonTitle, contractedTitle: contractedButtonTitle)
        
        if expandedButtonTitle == nil && contractedButtonTitle == nil {
            forceCollapseButton = true
            evaluateButton(forceCollaplse: forceCollapseButton)
        }
    }
    
    func set(contractedHeight: CGFloat, expandedHeight: CGFloat) {
        self.expandedHeight = expandedHeight
        self.contractedHeight = contractedHeight
    }
}

extension ExpandableTextFieldView: ViewBuilder {
    func addSubviews() {
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(titleLabel)
        addSubview(toggleButton)
        addSubview(textView)
    }
    func constrainViews() {
        titleLabel.snp.remakeConstraints { make in
            make.top.equalToSuperview().offset(5)
            make.leading.equalToSuperview().offset(10)
        }
        toggleButton.snp.remakeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.bottom.equalToSuperview().offset(-5)
            make.height.equalTo(30)
        }
        textView.snp.remakeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.top.equalTo(titleLabel.snp.bottom).offset(5)
            make.bottom.equalTo(toggleButton.snp.top)
            make.height.equalTo(self.contractedHeight)
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
            } else {
                self.layoutIfNeeded()
            }
        }, completion: nil)
    }
    
    func evaluateButton(forceCollaplse: Bool) {
        let totalHeight = textView.sizeThatFits(CGSize(width: textView.frame.size.width, height: .greatestFiniteMagnitude)).height
        toggleButton.clipsToBounds = true
        
        if forceCollaplse || totalHeight < contractedHeight {
            toggleButton.isEnabled = false
            toggleButton.snp.updateConstraints { make in
                make.height.equalTo(0)
            }
            textView.snp.updateConstraints { make in
                make.height.equalTo(totalHeight)
            }
        } else {
            toggleButton.isEnabled = true
            let buttonHeight = expandedButtonHeight
            toggleButton.snp.updateConstraints { make in
                make.height.equalTo(buttonHeight)
            }
            textView.snp.updateConstraints { make in
                make.height.equalTo(self.contractedHeight)
            }
        }
    }
    
    func collapseTitleLabel() {
        titleLabel.snp.remakeConstraints { make in
            make.top.equalToSuperview().offset(0)
            make.leading.equalToSuperview().offset(10)
            make.height.equalTo(0)
        }
    }

    func style() {
        backgroundColor = .white
        textView.isEditable = false
        titleLabel.style(with: [.font(.subTitle), .titleColor(.lightGray)])
        textView.style(with: .font(.body))
        toggleButton.style(with: [.font(.body), .titleColor(.kratosRed)])
    }
}

extension ExpandableTextFieldView: RxBinder {
    
    func bind() {
        bindTitleLabel()
        bindTextView()
        bindToggleButton()
    }
    
    func bindTitleLabel() {
        guard let viewModel = viewModel else { return }
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
        guard let viewModel = viewModel else { return }
        viewModel.text.asObservable()
            .bind(to: textView.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.text.asObservable()
            .filter { !$0.isEmpty }
            .subscribe(onNext: { [weak self] string in
                if let s = self,
                    !string.isEmpty {
                    s.evaluateButton(forceCollaplse: s.forceCollapseButton)
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.state.asObservable()
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] state in
                guard let s = self else { fatalError("self deallocated before it was accessed") }
                s.update(for: state)
            })
            .disposed(by: disposeBag)
    }
    
    func bindToggleButton() {
        guard let viewModel = viewModel else { return }
        toggleButton.rx.controlEvent(.touchUpInside).asObservable()
            .withLatestFrom(viewModel.state.asObservable())
            .map { $0 == .expanded ? .contracted : .expanded }
            .bind(to: viewModel.state)
            .disposed(by: disposeBag)
        
        viewModel.buttonTitle.asObservable()
            .bind(to: toggleButton.rx.title(for: .normal))
            .disposed(by: disposeBag)
    }
}



