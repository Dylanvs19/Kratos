//
//  SubmitAddressViewController.swift
//  Kratos
//
//  Created by Dylan Straughan on 7/30/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import UIKit

class SubmitAddressViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var kratosImageViewTop: NSLayoutConstraint!
    @IBOutlet var kratosImageViewCentered: NSLayoutConstraint!
    @IBOutlet var kratosImageViewSmall: NSLayoutConstraint!
    @IBOutlet var kratosImageViewLarge: NSLayoutConstraint!
    
    @IBOutlet var addressTextFieldNoWidth: NSLayoutConstraint!
    @IBOutlet var addressTextFieldFullWidth: NSLayoutConstraint!
    
    @IBOutlet var cityTextFieldNoWidth: NSLayoutConstraint!
    @IBOutlet var cityTextFieldLeadingStateTextField: NSLayoutConstraint!
    @IBOutlet var cityXAxisLeft: NSLayoutConstraint!
    @IBOutlet var cityTextFieldLeadingAddressTextField: NSLayoutConstraint!
    
    @IBOutlet var stateTextFieldFullWidth: NSLayoutConstraint!
    @IBOutlet var stateTextFieldNoWidth: NSLayoutConstraint!
    
    @IBOutlet var zipCodeTextFieldNoWidth: NSLayoutConstraint!
    @IBOutlet var zipCodeXAxisRight: NSLayoutConstraint!
    @IBOutlet var zipCodeTextFieldTrailingStateTextField: NSLayoutConstraint!
    @IBOutlet var zipCodeTextFieldTrailingAddressTextField: NSLayoutConstraint!
    
    @IBOutlet var enterOnScreen: NSLayoutConstraint!
    @IBOutlet var enterOffScreen: NSLayoutConstraint!
    
    @IBOutlet var kratosOnScreen: NSLayoutConstraint!
    @IBOutlet var kratosOffScreen: NSLayoutConstraint!
    
    @IBOutlet var addressTextField: UITextField!
    @IBOutlet var cityTextField: UITextField!
    @IBOutlet var zipCodeTextField: UITextField!
    @IBOutlet var stateTextField: UITextField!
    @IBOutlet var kratosLabel: UILabel!
    
    @IBOutlet var stateUnderlineView: UIView!
    @IBOutlet var cityUnderlineView: UIView!
    @IBOutlet var zipcodeUnderlineView: UIView!
    @IBOutlet var addressUnderlineView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        beginningAnimations()
        setupGestureRecognizer()
    }
    
    private func beginningAnimations() {
        UIView.animateWithDuration(1, delay: 1, options: [], animations: {
            self.kratosImageViewLarge.active = false
            self.kratosImageViewSmall.active = true
            self.kratosImageViewCentered.active = false
            self.kratosImageViewTop.active = true
            self.view.layoutIfNeeded()
        }, completion: nil)
        
        UIView.animateWithDuration(1, delay: 3, options: [], animations: {
            
            self.addressTextFieldNoWidth.active = false
            self.addressTextFieldFullWidth.active = true
            self.stateTextFieldNoWidth.active = false
            self.stateTextFieldFullWidth.active = true
            
            self.cityTextFieldNoWidth.active = false
            self.cityXAxisLeft.active = false
            self.cityTextFieldLeadingStateTextField.active = true
            self.cityTextFieldLeadingAddressTextField.active = true
            
            self.zipCodeTextFieldNoWidth.active = false
            self.zipCodeXAxisRight.active = false
            self.zipCodeTextFieldTrailingStateTextField.active = true
            self.zipCodeTextFieldTrailingAddressTextField.active = true
            self.view.layoutIfNeeded()
            
            }, completion: nil)
    }
    
    func handleTapOutside(recognizer: UITapGestureRecognizer) {
        view.endEditing(true)
        if textFieldsValid() {
            UIView.animateWithDuration(2, animations: {
                self.enterOffScreen.active = false
                self.kratosLabel.alpha = 0
                self.enterOnScreen.active = true
                self.view.layoutIfNeeded()
            })
        }
    }
    
    private func setupGestureRecognizer() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(SubmitAddressViewController.handleTapOutside(_:)))
        view.addGestureRecognizer(tapRecognizer)
    }
    
    @IBAction func enterButtonPressed(sender: AnyObject) {
        
    }
    
    func textFieldsValid() -> Bool {
        
        if InputValidation.validateAddress(addressTextField.text) == false {
            UIView.animateWithDuration(1, delay: 0, usingSpringWithDamping: 2, initialSpringVelocity: 0, options: [.CurveEaseInOut, .Autoreverse], animations: {
                    self.addressTextFieldFullWidth.constant += 5
                    self.addressUnderlineView.backgroundColor = UIColor.kratosRed
                    self.view.layoutIfNeeded()
                }, completion: nil)
            return false
        } else {
            UIView.animateWithDuration(1, delay: 0, usingSpringWithDamping: 2, initialSpringVelocity: 0, options: [.CurveEaseInOut, .Autoreverse], animations: {
                self.addressTextFieldFullWidth.constant -= 5
                self.addressUnderlineView.backgroundColor = UIColor.kratosBlue
                self.view.layoutIfNeeded()
                }, completion: nil)
        }
            
        if InputValidation.validateCity(cityTextField.text) == false {
            UIView.animateWithDuration(1, delay: 0, usingSpringWithDamping: 2, initialSpringVelocity: 0, options: [.CurveEaseInOut, .Autoreverse], animations: {
                self.cityTextFieldNoWidth.constant += 5
                self.addressUnderlineView.backgroundColor = UIColor.redColor()
                }, completion: nil)
            return false
        }
        return false

    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
}
