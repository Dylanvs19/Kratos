//
//  KratosTextField.swift
//  Kratos
//
//  Created by Dylan Straughan on 12/1/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import UIKit

@objc protocol KratosTextFieldDelegate: class {
    @objc optional func didSelectTextField(textField: KratosTextField)
}

@IBDesignable class KratosTextField: UIView, UITextFieldDelegate {
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var textLabelToTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var textLabelToBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var textFieldWidthConstraint: NSLayoutConstraint!
    
    private var validationFunction: ((String) -> Bool)?
    private var expandedWidth: CGFloat = 0
    
    weak var delegate: KratosTextFieldDelegate?
    var isValid = false
    var shouldPresentKeyboard = true
    var isEditable = true {
        didSet {
            textField.isEnabled = isEditable
        }
    }
    
    var text: String? {
        get {
            return textField.text
        }
    }
    
    @IBOutlet weak var underlineView: UIView!
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        customInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        customInit()
    }
    
    fileprivate func customInit() {
        let view = UINib(nibName: "KratosTextField", bundle: Bundle(for: type(of: self))).instantiate(withOwner: self, options: nil).first as! UIView
        //Bundle.main.loadNibNamed("KratosTextField", owner: self, options: nil)
        translatesAutoresizingMaskIntoConstraints = false
        view.frame = bounds
        autoresizingMask = [.flexibleHeight, .flexibleWidth]
        addSubview(view)
        textField.delegate = self
    }
    
    /// Configuration for TextFieldView - must be put in ViewDidAppear()
    /// To reset View - use Animate out in ViewDidLoad() 
    public func configureWith(validationFunction: ((String) -> Bool)? = nil, text: String? = nil, textlabelText: String, expandedWidth: CGFloat, secret: Bool?, shouldPresentKeyboard: Bool = true) {
        self.expandedWidth = expandedWidth
        self.validationFunction = validationFunction
        self.textLabel.text = textlabelText
        if let text = text {
            textField.text = text
            self.textLabelToTopConstraint.isActive = false
            self.textLabelToBottomConstraint.isActive = true
            self.textLabel.transform = CGAffineTransform(scaleX: 0.66, y: 0.66)
            self.layoutIfNeeded()
        }
        if let secret = secret {
            textField.isSecureTextEntry = secret ? true : false 
        }
        self.shouldPresentKeyboard = shouldPresentKeyboard
    }
    
    fileprivate func shouldAnimateTextLabelDown() {
        UIView.animate(withDuration: 0.25, animations: {
            self.textLabelToTopConstraint.isActive = false
            self.textLabelToBottomConstraint.isActive = true
            self.textLabel.transform = CGAffineTransform(scaleX: 0.66, y: 0.66)
            self.layoutSubviews()
            self.layoutIfNeeded()
        })
    }
    
    fileprivate func shouldAnimateTextLabelUp() {
        UIView.animate(withDuration: 0.5, animations: {
            self.textLabelToBottomConstraint.isActive = false
            self.textLabelToTopConstraint.isActive = true
            self.textLabel.transform = CGAffineTransform(scaleX: 1, y: 1)
            self.layoutSubviews()
            self.layoutIfNeeded()
        })
    }
    
    //MARK: Textfield delegates
//    func textFieldDidBeginEditing(_ textField: UITextField) {
//        shouldAnimateTextLabelDown()
//    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        //NOTE: this delegate is not consuming the textField
        // it is consuming the entire class
        delegate?.didSelectTextField?(textField: self)
        
        shouldAnimateTextLabelDown()
        // Do not present Keyboard if should not be able to edit.
        return shouldPresentKeyboard
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        validate()
    }
    
    func validate() {
        // check to see if text should be validated
        if let validationFunction = validationFunction {
            var color = UIColor.kratosRed
            isValid = false
            if let text = textField.text , validationFunction(text) {
                color = UIColor.kratosBlue
                isValid = true
            }
            underlineView.backgroundColor = color
        }
        
        // bring text label back up if textField.text is empty or nil
        if textField.text?.isEmpty ?? true {
            shouldAnimateTextLabelUp()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        resignFirstResponder()
        textField.endEditing(true)
        return true
    }
    
    public func animateIn() {
        textLabel.alpha = 1
        textField.alpha = 1
        textFieldWidthConstraint.constant = expandedWidth
    }
    
    public func animateOut() {
        textLabel.alpha = 0
        textField.alpha = 0
        textFieldWidthConstraint.constant = 0
    }
    
    public func setText(_ text: String) {
        self.textField.alpha = 0
        self.textField.text = text
        UIView.animate(withDuration: 0.25, animations: {
            self.textField.alpha = 1
            self.layoutIfNeeded()
        })
        validate()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = bounds
    }
}
