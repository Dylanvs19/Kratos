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

class KratosTextField: UITextField {
    
    enum TextfieldType {
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
        case confirmation
        case search
        
        var keyboardType: UIKeyboardType {
            switch self {
            case .zip, .confirmation:
                return .numberPad
            case .email:
                return .emailAddress
            default:
                return .default
            }
        }
        
        var capitalization: UITextAutocapitalizationType {
            switch self {
            case .first,
                 .last,
                 .address,
                 .city:
                return .words
            default:
                return .none
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
            case .confirmation: return localize(.textFieldConfirmationTitle)
            case .search: return localize(.textFieldSearchTitle)
            }
        }
    }
    
    //MARK: Public UI Elements
    public var placeholderLabel = UILabel()
    public let tap = PublishSubject<Void>()
    
    //MARK: Private UI Elements
    fileprivate var underlineView = UIView()
    
    //MARK: Public Variables
    public var textFieldType: TextfieldType = .address
    
    override var text: String? {
        didSet {
            self.animateTextLabelPosition(shouldSink: (text ?? "").count > 0)
        }
    }
    
    //MARK: Initializers
    convenience init(type: TextfieldType) {
        self.init(frame: .zero)
        self.textFieldType = type
        self.keyboardType = textFieldType.keyboardType
        self.isSecureTextEntry = textFieldType == .password
        self.placeholderLabel.text = textFieldType.placeholderText
        self.autocapitalizationType = textFieldType.capitalization
        self.textAlignment = .center
        delegate = self
        addTarget(self, action: #selector(editingBegan), for: .editingDidBegin)
        addTarget(self, action: #selector(editingEnded), for: .editingDidEnd)
        addSubviews()
        constrainViews()
        styleViews()
    }
    
    // MARK: - Initialization -
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
        alpha = 1
    }
    
    public func animateOut() {
        placeholderLabel.alpha = 0
        alpha = 0
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
    public func textFieldText(_ text: String) {
    }
}

//MARK: ViewBuilder
extension KratosTextField: ViewBuilder {
    func addSubviews() {
        addSubview(underlineView)
        addSubview(placeholderLabel)
    }
    
    func constrainViews() {
        underlineView.snp.makeConstraints { make in
            make.width.centerX.equalToSuperview()
            make.height.equalTo(2)
            make.bottom.equalToSuperview().offset(2)
        }
        placeholderLabel.snp.makeConstraints { make in
            make.bottom.equalTo(underlineView.snp.top).offset(0)
            make.centerX.equalToSuperview()
        }
    }
    
    func styleViews() {
        sendSubview(toBack: placeholderLabel)
        if textFieldType == .confirmation {
            placeholderLabel.style(with: [.font(.cellTitle),
                                          .titleColor(.lightGray)])
            self.style(with: [.font(.header),
                              .titleColor(.black)])
        } else {
            placeholderLabel.style(with: [.font(.cellTitle),
                                          .titleColor(.lightGray)])
            self.style(with: [.font(.cellTitle),
                                   .titleColor(.black)])
        }
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
                return newString.count <= 5
            }
        case .state:
            if string.containsCharacters(in: CharacterSet.englishLetters.inverted) {
                return false
            } else if newString.count <= 2 && !string.isEmpty {
                textField.text = (textField.text ?? "") + string.uppercased()
                return false
            } else if newString.count > 2 {
                return false
            }
            return true
        case .confirmation:
            if string.containsCharacters(in: CharacterSet.decimalDigits.inverted) {
                return false
            } else {
                guard newString.count < 12 else { return false }
                guard string != "" else { return true }
                textField.text = newString + " "
                return false
            }
        default:
            return true
        }
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        switch textFieldType {
        case .dob,
             .party:
            tap.onNext(())
            return false 
        default:
            return true
        }
    }
}

func == (lhs: KratosTextField.TextfieldType, rhs: KratosTextField.TextfieldType) -> Bool {
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
         (.zip, .zip),
         (.confirmation, .confirmation),
         (.search, .search):
        return true
    default:
        return false
    }
}

func != (lhs: KratosTextField.TextfieldType, rhs: KratosTextField.TextfieldType) -> Bool {
    return !(lhs == rhs)
}

struct FieldData {
    let field: KratosTextField
    let fieldType: KratosTextField.TextfieldType
    let viewModelVariable: Variable<String>
    let validation: Variable<Bool>
}
