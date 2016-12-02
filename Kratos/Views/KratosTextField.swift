//
//  KratosTextField.swift
//  Kratos
//
//  Created by Dylan Straughan on 12/1/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import UIKit

@IBDesignable class KratosTextField: UIView, UITextFieldDelegate {
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var textLabelToTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var textLabelToBottomConstraint: NSLayoutConstraint!
    
    var validationFunction: ((String) -> Bool)?
    var isValid = false
    
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
        Bundle.main.loadNibNamed("KratosTextField", owner: self, options: nil)
        translatesAutoresizingMaskIntoConstraints = false
        contentView.frame = bounds
        autoresizingMask = [.flexibleHeight, .flexibleWidth]
        addSubview(contentView)
        textField.delegate = self

    }
    
    func configureWith(validationFunction: ((String) -> Bool)? = nil, text: String? = nil, textlabelText: String) {
        self.validationFunction = validationFunction
        textLabel.text = textlabelText
    }
    
    fileprivate func shouldAnimateTextLabelDown(animateDown: Bool) {
        UIView.animate(withDuration: 0.25, animations: {
            self.textLabelToTopConstraint.isActive = !animateDown
            self.textLabelToBottomConstraint.isActive = animateDown
            self.textLabel.font = animateDown ? self.textLabel.font.withSize(10.0) : self.textLabel.font.withSize(15.0)
            self.layoutIfNeeded()
            self.layoutSubviews()
        })
    }
    
    //MARK: Textfield delegates
    func textFieldDidBeginEditing(_ textField: UITextField) {
        shouldAnimateTextLabelDown(animateDown: true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        
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
        
        // bring text label back up if empty or nil
        if textField.text?.isEmpty ?? true {
            shouldAnimateTextLabelDown(animateDown: false)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        resignFirstResponder()
        textField.endEditing(true)
        return true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = bounds
    }
}
