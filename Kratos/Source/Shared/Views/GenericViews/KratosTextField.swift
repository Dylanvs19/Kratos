//
//  KratosTextField.swift
//  Kratos
//
//  Created by Dylan Straughan on 12/1/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

class KratosTextField: UIView {
    
    enum TextFieldType {
        case zip
        case state
        case address
        case city
        case first
        case last
        case email
        case password
        case dob
        case party
        
        var keyboardType: UIKeyboardType {
            switch self {
            case .zip:
                return .numberPad
            case .email:
                return .emailAddress
            default:
                return .default
            }
        }
        var shouldPresentKeyboard: Bool {
            switch self {
            case .dob, .party:
                return false
            default:
                return true
            }
        }
        var placeholderText: String {
            switch self {
            case .email: return localize(.textFieldEmailTitle)
            case .password: return localize(.textFieldPasswordTitle)
            case .first: return localize(.textFieldFirstTitle)
            case .last: return localize(.textFieldLastTitle)
            case .dob: return localize(.textFieldBirthdayTitle)
            case .party: return localize(.textFieldPartyTitle)
            case .address: return localize(.textFieldAddressTitle)
            case .city: return localize(.textFieldCityTitle)
            case .state: return localize(.textFieldStateTitle)
            case .zip: return localize(.textFieldZipcodeTitle)
            }
        }
        
        var expandedWidthMultiplier: CGFloat {
            switch self {
            case .first, .last, .email, .password, .address, .city: return 0.8
            case .party, .dob, .zip, .state: return 0.35
            }
        }
        
        var centerXPosition: CGFloat {
            switch self {
            case .first, .last, .email, .password, .address, .city: return 1
            case .party, .state: return 0.55
            case .dob, .zip: return 1.45
            }
        }
        
        var offsetYPosition: CGFloat {
            switch self {
            case .email: return 50
            case .password: return 100
            case .first: return 25
            case .last: return 80
            case .dob, .party: return 135
            case .address: return 190
            case .city: return 245
            case .state, .zip: return 300
            }
        }
    }
    
    //MARK: Public UI Elements
    public var textField = UITextField()
    public var placeholderLabel = UILabel()
    
    //MARK: Private UI Elements
    fileprivate var underlineView = UIView()
    
    //MARK: Public Variables
    public var textFieldType: TextFieldType = .address
    
    //MARK: Private Variables
    fileprivate var shouldPresentKeyboard = true
    fileprivate var text: String? {
        return textField.text
    }
    
    //MARK: Initializers
    convenience init(type: TextFieldType) {
        self.init(frame: .zero)
        self.textFieldType = type
        self.textField.keyboardType = textFieldType.keyboardType
        self.textField.isSecureTextEntry = textFieldType == .password
        self.placeholderLabel.text = textFieldType.placeholderText
        self.textField.textAlignment = .center
        textField.delegate = self
        textField.addTarget(self, action: #selector(editingBegan), for: .editingDidBegin)
        textField.addTarget(self, action: #selector(editingEnded), for: .editingDidEnd)
        addSubviews()
        constrainViews()
        styleViews()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Public Animations
    public func animateTextLabelPosition(shouldSink: Bool) {
        UIView.animate(withDuration: 0.2, animations: {
            self.placeholderLabel.transform = !shouldSink ? CGAffineTransform.identity : CGAffineTransform(scaleX: 0.66, y: 0.66).translatedBy(x: 0, y: 35)
            self.layoutIfNeeded()
        })
    }
    
    public func animateIn() {
        placeholderLabel.alpha = 1
        textField.alpha = 1
    }
    
    public func animateOut() {
        placeholderLabel.alpha = 0
        textField.alpha = 0
    }
    
    public func changeColor(for isValid: Bool) {
        UIView.animate(withDuration: 0.2) {
            self.underlineView.backgroundColor = isValid ? UIColor.kratosBlue : UIColor.kratosRed
        }
    }
    
    @objc private func editingBegan() {
        animateTextLabelPosition(shouldSink: true)
    }
    
    @objc private func editingEnded() {
        if let text = text {
            animateTextLabelPosition(shouldSink: !text.isEmpty)
        } else {
            animateTextLabelPosition(shouldSink: false)
        }
    }
    
    //MARK: Public Setter
    public func setText(_ text: String) {
        self.textField.text = text
        self.animateTextLabelPosition(shouldSink: text.characters.count > 0)
    }
}

//MARK: ViewBuilder
extension KratosTextField: ViewBuilder {
    func addSubviews() {
        addSubview(textField)
        addSubview(underlineView)
        addSubview(placeholderLabel)
    }
    
    func constrainViews() {
        textField.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(self)
            make.bottom.equalTo(self).inset(4)
        }
        underlineView.snp.makeConstraints { make in
            make.width.centerX.equalTo(self)
            make.height.equalTo(2)
            make.top.equalTo(textField.snp.bottom).offset(2)
        }
        placeholderLabel.snp.makeConstraints { make in
            make.bottom.equalTo(underlineView.snp.top).offset(0)
            make.centerX.equalTo(self)
        }
    }
    
    func styleViews() {
        sendSubview(toBack: placeholderLabel)
        
        placeholderLabel.style(with: [.font(.cellTitle), .titleColor(.lightGray)])
        textField.style(with: [.font(.cellTitle), .titleColor(.black)])
        
        underlineView.style(with: [.backgroundColor(.kratosBlue),
                                   .cornerRadius(1)])
    }
}

//MARK: TextField Delegates
extension KratosTextField: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        resignFirstResponder()
        textField.endEditing(true)
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newString = ((textField.text ?? "") as NSString).replacingCharacters(in: range, with: string)
        switch textFieldType {
        case .zip:
            if string.containsCharacters(in: CharacterSet.decimalDigits.inverted) {
                return false
            } else {
                return newString.characters.count <= 5
            }
        case .state:
            if string.containsCharacters(in: CharacterSet.englishLetters.inverted) {
                return false
            } else if newString.characters.count <= 2 && !string.isEmpty {
                textField.text = (textField.text ?? "") + string.uppercased()
                return false
            } else if newString.characters.count > 2 {
                return false
            }
            return true
        case .email, .password:
            return true 
        default:
            if textField.text?.characters.count == 0 {
                textField.text = (textField.text ?? "") + string.uppercased()
                return false
            }
            return true
        }
    }
}

//MARK: Reactive Extension
extension Reactive where Base: KratosTextField {
    var isEnabled: UIBindingObserver<Base, Bool> {
        return UIBindingObserver<Base, Bool>(UIElement: base, binding: { (view, isEnabled) in
                view.textField.isEnabled = isEnabled
            }
        )
    }
}

func == (lhs: KratosTextField.TextFieldType, rhs: KratosTextField.TextFieldType) -> Bool {
    switch (lhs, rhs) {
    case (.email, .email),
         (.password, .password),
         (.first, .first),
         (.last, .last),
         (.party, .party),
         (.dob, .dob),
         (.address, .address),
         (.city, .city),
         (.state, .state),
         (.zip, .zip):
        return true
    default:
        return false
    }
}

func != (lhs: KratosTextField.TextFieldType, rhs: KratosTextField.TextFieldType) -> Bool {
    return !(lhs == rhs)
}

struct FieldData {
    let field: KratosTextField
    let fieldType: KratosTextField.TextFieldType
    let viewModelVariable: Variable<String>
    let validation: Variable<Bool>
}
