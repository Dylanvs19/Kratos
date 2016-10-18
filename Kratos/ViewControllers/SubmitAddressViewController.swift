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
    
    @IBOutlet var firstNameTextFieldNoWidth: NSLayoutConstraint!
    @IBOutlet var firstNameTextFieldFullWidth: NSLayoutConstraint!
    
    @IBOutlet var lastNameTextFieldNoWidth: NSLayoutConstraint!
    @IBOutlet var lastNameTextFieldFullWidth: NSLayoutConstraint!
    
    @IBOutlet var enterOnScreen: NSLayoutConstraint!
    @IBOutlet var enterOffScreen: NSLayoutConstraint!
    
    @IBOutlet var kratosOnScreen: NSLayoutConstraint!
    @IBOutlet var kratosOffScreen: NSLayoutConstraint!
    
    @IBOutlet var firstNameTextField: UITextField!
    @IBOutlet var lastNameTextField: UITextField!
    @IBOutlet var addressTextField: UITextField!
    @IBOutlet var cityTextField: UITextField!
    @IBOutlet var zipCodeTextField: UITextField!
    @IBOutlet var stateTextField: UITextField!
    @IBOutlet var kratosLabel: UILabel!
    
    @IBOutlet var firstNameUnderlineView: UIView!
    @IBOutlet var lastNameUnderlineView: UIView!
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
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
        addressTextField.delegate = self
        cityTextField.delegate = self
        zipCodeTextField.delegate = self
        stateTextField.delegate = self
        testData()  
    }
    
    private func testData() {
        addressTextField.text = "331 Keap Street"
        cityTextField.text = "Brooklyn"
        stateTextField.text = "NY"
        zipCodeTextField.text = "11211"
    }
    
    private func beginningAnimations() {
        
        firstNameTextField.alpha = 0.01
        lastNameTextField.alpha = 0.01
        addressTextField.alpha = 0.01
        cityTextField.alpha = 0.01
        stateTextField.alpha = 0.01
        zipCodeTextField.alpha = 0.01
        
        UIView.animateWithDuration(1, delay: 1, options: [], animations: {
            self.kratosImageViewLarge.active = false
            self.kratosImageViewSmall.active = true
            self.kratosImageViewCentered.active = false
            self.kratosImageViewTop.active = true
            self.view.layoutIfNeeded()
        }, completion: nil)
        
        UIView.animateWithDuration(1, delay: 3, options: [], animations: {
            
            self.firstNameTextFieldNoWidth.active = false
            self.firstNameTextFieldFullWidth.active = true
            
            self.lastNameTextFieldNoWidth.active = false
            self.lastNameTextFieldFullWidth.active = true
            
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
        
        UIView.animateWithDuration(0.5, delay: 4, options: [UIViewAnimationOptions.TransitionCrossDissolve], animations: {
            self.firstNameTextField.alpha = 1
            self.lastNameTextField.alpha = 1
            self.addressTextField.alpha = 1
            self.cityTextField.alpha = 1
            self.stateTextField.alpha = 1
            self.zipCodeTextField.alpha = 1
            self.view.layoutIfNeeded()
            }, completion: nil)
    }
    
    func handleTapOutside(recognizer: UITapGestureRecognizer) {
        view.endEditing(true)
        if textFieldsValid() {
            UIView.animateWithDuration(1, animations: {
                self.enterOffScreen.active = false
                self.kratosLabel.alpha = 0
                self.enterOnScreen.active = true
                self.view.layoutIfNeeded()
            })
        } else {
            UIView.animateWithDuration(1, animations: {
                self.kratosLabel.alpha = 1
                self.enterOnScreen.active = false
                self.enterOffScreen.active = true
                self.view.layoutIfNeeded()
            })
        }
    }
    
    private func setupGestureRecognizer() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(SubmitAddressViewController.handleTapOutside(_:)))
        view.addGestureRecognizer(tapRecognizer)
    }
    
    @IBAction func enterButtonPressed(sender: AnyObject) {

        if textFieldsValid() {
            var address = StreetAddress()
            address.street = addressTextField.text
            address.city = cityTextField.text
            address.state = stateTextField.text
            if let stringZip = zipCodeTextField.text,
                let zip = Int(stringZip) {
                address.zipCode = zip
            }
            Datastore.sharedDatastore.user?.firstName = firstNameTextField.text
            Datastore.sharedDatastore.user?.lastName = lastNameTextField.text
            Datastore.sharedDatastore.user?.streetAddress = address
        }
        guard let password = Datastore.sharedDatastore.user?.password else { return }
        Datastore.sharedDatastore.registerWith(password) { (success) in
            if success {
                NSNotificationCenter.defaultCenter().postNotificationName("toMainVC", object: nil)
            } else {
                print("SubmitAddressViewController registerWith(password) unsucessful")
            }
        }
    }
    
    func textFieldsValid() -> Bool {
        var valid = true
        let collection = [
            (InputValidation.validateAddress, addressTextField.text, addressUnderlineView),
            (InputValidation.validateCity, cityTextField.text, cityUnderlineView),
            (InputValidation.validateState, stateTextField.text, stateUnderlineView),
            (InputValidation.validateZipCode, zipCodeTextField.text, zipcodeUnderlineView),
            (InputValidation.validateAddress, firstNameTextField.text, firstNameUnderlineView),
            (InputValidation.validateAddress, lastNameTextField.text, lastNameUnderlineView)
        ]
        
        collection.forEach({ validation, textField, view in
            let isValid = validation(textField)
            animate(view, with: isValid)
            if !isValid {
                valid = false
            }
        })
        return valid
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        textField.layoutIfNeeded()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true 
    }
    
    func animate(underlineView: UIView, with validation: Bool) {
        UIView.animateWithDuration(1, animations: {
            underlineView.backgroundColor = validation ? UIColor.kratosBlue : UIColor.kratosRed
            underlineView.layoutIfNeeded()
        })
    }
}
