//
//  KratosTextField.swift
//  Kratos
//
//  Created by Dylan Straughan on 12/1/16.
//  Copyright © 2017 Kratos, Inc. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

struct TextFieldStyle {
    var height: CGFloat
    var font: Font
    
    func styling(for state: TextField.State) -> TextFieldStateStyle {
        switch state {
        case .disabled:
            return TextFieldStateStyle(textColor: .gray,
                                       placeHolderFontColor: .gray,
                                       underlineColor: .gray)
        case .focusedValid:
            return TextFieldStateStyle(textColor: .black,
                                       placeHolderFontColor: .gray,
                                       underlineColor: .kratosBlue)
        case .focused:
            return TextFieldStateStyle(textColor: .black,
                                       placeHolderFontColor: .gray,
                                       underlineColor: .kratosRed)
        case .invalid:
            return TextFieldStateStyle(textColor: .black,
                                       placeHolderFontColor: .gray,
                                       underlineColor: .kratosRed)
        case .valid:
            return TextFieldStateStyle(textColor: .black,
                                       placeHolderFontColor: .gray,
                                       underlineColor: .kratosBlue)
        case .initial:
            return TextFieldStateStyle(textColor: .black,
                                       placeHolderFontColor: .gray,
                                       underlineColor: .gray)
        }
    }
    
    static let standard = TextFieldStyle(height: Dimension.textfieldHeight, font: .h5)
}

struct TextFieldStateStyle {
    var textColor: Color
    var placeHolderFontColor: Color
    var underlineColor: Color
}

enum TextFieldType {
    case text
    case name
    case email
    case state
    case zipcode
    case password
    case custom
    case confirmation
    
    var validation: ((String) -> Bool) {
        switch self {
        case .email: return { !$0.isEmpty && $0.isValidEmail }
        case .state: return { !$0.isEmpty && $0.isValidState }
        case .zipcode: return { !$0.isEmpty && $0.isValidZipcode }
        case .password: return { !$0.isEmpty && $0.isValidPassword }
        default: return { !$0.isEmpty }
        }
    }
    var replaceCharacters: ((_ textField: UITextField, _ newString: String, _ replacement: String) -> Bool) {
        switch self {
        case .state: return { (textField, newString, string) -> Bool in
            guard !string.containsCharacters(in: CharacterSet.englishLetters.inverted) else { return false }
            textField.text = newString.uppercased()
            return false
            }
        case .zipcode: return { _, newString, string in
            return !string.containsCharacters(in: CharacterSet.decimalDigits.inverted) && newString.count <= 5
            }
        case .confirmation: return { (textField, newString, string) in
            guard !string.containsCharacters(in: CharacterSet.decimalDigits.inverted),
                newString.count < 12 else { return false }
            guard !string.isEmpty else { return true }
            textField.text = newString + " "
            return false
            }
        default: return { _,_,_ in return true }
        }
    }
    var keyboardType: UIKeyboardType {
        switch self {
        case .email: return .emailAddress
        case .zipcode,
             .confirmation: return .numberPad
        default: return .default
        }
    }
    var secureEntry: Bool {
        switch self {
        case .password: return true
        default: return false
        }
    }
    var characterLimit: Int? {
        switch self {
        case .state: return 2
        case .zipcode: return 5
        default: return nil
        }
    }
    var autocorrection: UITextAutocorrectionType {
        switch self {
        case .text: return .yes
        default: return .no
        }
    }
    var autocapitalization: UITextAutocapitalizationType {
        switch self {
        case .name: return .words
        default: return .none
        }
    }
    var customInteraction: Bool {
        switch self {
        case .custom: return true
        default: return false
        }
    }
}

class TextField: UIView {
    
    // MARK: - enums -
    enum State {
        case disabled
        case focusedValid
        case focused
        case invalid
        case valid
        case initial
    }
    
    // MARK: - properties -
    let disposeBag = DisposeBag()
    let viewModel: TextFieldViewModel
    let tap = PublishSubject<Void>()
    let isEnabled = BehaviorSubject<Bool>(value: true)
    let isValid = BehaviorSubject<Bool>(value: false)
    var text: ControlEvent<String?> {
        return ControlEvent<String?>(events: textField.rx.text)
    }
    
    private var textField = UITextField()
    private var placeholderLabel = UILabel()
    private var underlineView = UIView()
    
    private let style: TextFieldStyle
    private let type: TextFieldType
    private let placeholder: String?
    private var state: State = .initial {
        didSet {
            let stateStyle = style.styling(for: state)
            UIView.animate(withDuration: 0.15) {
                self.set(stateStyle: stateStyle)
            }
        }
    }
    
    // MARK: - initialization -
    init(style: TextFieldStyle, type: TextFieldType, placeholder: String?) {
        self.viewModel = TextFieldViewModel(type: type)
        self.style = style
        self.type = type
        self.placeholder = placeholder
        super.init(frame: .zero)
        
        styleViews()
        addSubviews()
        
        bind()
        configureTextField()
        configurePlaceholder()
        set(stateStyle: style.styling(for: .initial))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - animations -
    private func animateTextLabelPosition(shouldSink: Bool) {
        UIView.animate(withDuration: 0.2, animations: {
            self.placeholderLabel.transform = !shouldSink ? CGAffineTransform.identity : CGAffineTransform(scaleX: 0.66, y: 0.66).translatedBy(x: 0, y: 35)
            self.layoutIfNeeded()
        })
    }
    
    func set(text: String) {
        viewModel.input.value = text
        textField.text = text
    }
    
    private func set(stateStyle: TextFieldStateStyle) {
        textField.textColor = stateStyle.textColor.value
        placeholderLabel.textColor = stateStyle.placeHolderFontColor.value
        underlineView.backgroundColor = stateStyle.underlineColor.value
    }
    
    private func configureTextField() {
        bringSubview(toFront: textField)
        textField.delegate = self
        textField.font = style.font.value
        textField.keyboardType = type.keyboardType
        textField.isSecureTextEntry = type.secureEntry
        textField.autocorrectionType = type.autocorrection
        textField.autocapitalizationType = type.autocapitalization
        textField.textAlignment = .center
    }
    
    private func configurePlaceholder() {
        sendSubview(toBack: placeholderLabel)
        placeholderLabel.font = style.font.value
        placeholderLabel.text = placeholder
        placeholderLabel.textAlignment = .center
    }
}

//MARK: ViewBuilder
extension TextField: ViewBuilder {
    func styleViews() {
        backgroundColor = .clear
        isUserInteractionEnabled = true 
        
        snp.makeConstraints { make in
            make.height.equalTo(style.height)
        }
    }
    
    func addSubviews() {
        addPlaceholderLabel()
        addTextField()
        addUnderline()
    }
    
    private func addPlaceholderLabel() {
        addSubview(placeholderLabel)
        
        placeholderLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
        }
    }
    
    private func addTextField() {
        addSubview(textField)
        textField.backgroundColor = .clear
        textField.isUserInteractionEnabled = true
        
        textField.snp.makeConstraints { make in
            make.leading.top.trailing.equalToSuperview().inset(1)
        }
    }
    
    private func addUnderline() {
        addSubview(underlineView)
        underlineView.backgroundColor = style.styling(for: .initial).underlineColor.value
        
        underlineView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(2)
            make.top.equalTo(placeholderLabel.snp.bottom)
            make.top.equalTo(textField.snp.bottom)
        }
    }
}

extension TextField: RxBinder {
    func bind() {
        viewModel.isValid
            .bind(to: isValid)
            .disposed(by: disposeBag)
        
        isEnabled
            .bind(to: textField.rx.isEnabled)
            .disposed(by: disposeBag)
        
        Observable.combineLatest(isValid,
                                 textField.rx.isEditing.startWith(false),
                                 isEnabled) { (isValid, isEditing, isEnabled) -> State in
                                    guard isEnabled else { return .disabled }
                                    guard !isEditing else {
                                        if isValid { return .focusedValid }
                                        return .focused
                                    }
                                    return isValid ? .valid : .invalid
            }
            .subscribe(onNext: { [unowned self] in self.state = $0 })
            .disposed(by: disposeBag)
        
        Observable.combineLatest(textField.rx.isEditing.startWith(false),
                                 viewModel.input.asObservable()) { $0 || !$1.isEmpty }
            .subscribe(onNext: { [unowned self] in self.animateTextLabelPosition(shouldSink: $0) })
            .disposed(by: disposeBag)
        
        textField.rx.text
            .map { $0 ?? "" }
            .bind(to: viewModel.input)
            .disposed(by: disposeBag)
    }
}

//MARK: TextField Delegates
extension TextField: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        resignFirstResponder()
        textField.endEditing(true)
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newString = ((textField.text ?? "") as NSString).replacingCharacters(in: range, with: string)
        return type.replaceCharacters(textField, newString, string)
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        tap.onNext(())
        if type.customInteraction {
            resignFirstResponder()
        }
        return !type.customInteraction
    }
}
