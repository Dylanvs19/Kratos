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
    
    @IBOutlet var partyTextFieldNoWidth: NSLayoutConstraint!
    @IBOutlet var partyTextFieldFullWidth: NSLayoutConstraint!
    
    @IBOutlet var dobTextFieldNoWidth: NSLayoutConstraint!
    @IBOutlet var dobTextFieldFullWidth: NSLayoutConstraint!
    
    @IBOutlet var enterOnScreen: NSLayoutConstraint!
    @IBOutlet var enterOffScreen: NSLayoutConstraint!
    
    @IBOutlet var kratosOnScreen: NSLayoutConstraint!
    @IBOutlet var kratosOffScreen: NSLayoutConstraint!
    
    @IBOutlet var partyTextField: UITextField!
    @IBOutlet var dobTextField: UITextField!
    @IBOutlet var addressTextField: UITextField!
    @IBOutlet var cityTextField: UITextField!
    @IBOutlet var zipCodeTextField: UITextField!
    @IBOutlet var stateTextField: UITextField!
    @IBOutlet var kratosLabel: UILabel!
    
    @IBOutlet var partyUnderlineView: UIView!
    @IBOutlet var dobUnderlineView: UIView!
    @IBOutlet var stateUnderlineView: UIView!
    @IBOutlet var cityUnderlineView: UIView!
    @IBOutlet var zipcodeUnderlineView: UIView!
    @IBOutlet var addressUnderlineView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        beginningAnimations()
        setupGestureRecognizer()
        partyTextField.delegate = self
        dobTextField.delegate = self
        addressTextField.delegate = self
        cityTextField.delegate = self
        zipCodeTextField.delegate = self
        stateTextField.delegate = self
        testData()  
    }
    
    fileprivate func testData() {
        addressTextField.text = "331 Keap Street"
        cityTextField.text = "Brooklyn"
        stateTextField.text = "NY"
        zipCodeTextField.text = "11211"
    }
    
    fileprivate func beginningAnimations() {
        
        partyTextField.alpha = 0.01
        dobTextField.alpha = 0.01
        addressTextField.alpha = 0.01
        cityTextField.alpha = 0.01
        stateTextField.alpha = 0.01
        zipCodeTextField.alpha = 0.01
        
        UIView.animate(withDuration: 1, delay: 1, options: [], animations: {
            self.kratosImageViewLarge.isActive = false
            self.kratosImageViewSmall.isActive = true
            self.kratosImageViewCentered.isActive = false
            self.kratosImageViewTop.isActive = true
            self.view.layoutIfNeeded()
        }, completion: nil)
        
        UIView.animate(withDuration: 1, delay: 3, options: [], animations: {
            
            self.partyTextFieldNoWidth.isActive = false
            self.partyTextFieldFullWidth.isActive = true
            
            self.dobTextFieldNoWidth.isActive = false
            self.dobTextFieldFullWidth.isActive = true
            
            self.addressTextFieldNoWidth.isActive = false
            self.addressTextFieldFullWidth.isActive = true
            
            self.stateTextFieldNoWidth.isActive = false
            self.stateTextFieldFullWidth.isActive = true
            
            self.cityTextFieldNoWidth.isActive = false
            self.cityXAxisLeft.isActive = false
            self.cityTextFieldLeadingStateTextField.isActive = true
            self.cityTextFieldLeadingAddressTextField.isActive = true
            
            self.zipCodeTextFieldNoWidth.isActive = false
            self.zipCodeXAxisRight.isActive = false
            self.zipCodeTextFieldTrailingStateTextField.isActive = true
            self.zipCodeTextFieldTrailingAddressTextField.isActive = true
            self.view.layoutIfNeeded()
            
            }, completion: nil)
        
        UIView.animate(withDuration: 0.5, delay: 4, options: [UIViewAnimationOptions.transitionCrossDissolve], animations: {
            self.partyTextField.alpha = 1
            self.dobTextField.alpha = 1
            self.addressTextField.alpha = 1
            self.cityTextField.alpha = 1
            self.stateTextField.alpha = 1
            self.zipCodeTextField.alpha = 1
            self.view.layoutIfNeeded()
            }, completion: nil)
    }
    
    func handleTapOutside(_ recognizer: UITapGestureRecognizer) {
        view.endEditing(true)
        if textFieldsValid() {
            UIView.animate(withDuration: 1, animations: {
                self.enterOffScreen.isActive = false
                self.kratosLabel.alpha = 0
                self.enterOnScreen.isActive = true
                self.view.layoutIfNeeded()
            })
        } else {
            UIView.animate(withDuration: 1, animations: {
                self.kratosLabel.alpha = 1
                self.enterOnScreen.isActive = false
                self.enterOffScreen.isActive = true
                self.view.layoutIfNeeded()
            })
        }
    }
    
    fileprivate func setupGestureRecognizer() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(SubmitAddressViewController.handleTapOutside(_:)))
        view.addGestureRecognizer(tapRecognizer)
    }
    
    @IBAction func enterButtonPressed(_ sender: AnyObject) {

        if textFieldsValid() {
            var address = StreetAddress()
            address.street = addressTextField.text
            address.city = cityTextField.text
            address.state = stateTextField.text
            if let stringZip = zipCodeTextField.text,
                let zip = Int(stringZip) {
                address.zipCode = zip
            }
            if let repParty = partyTextField.text {
            switch repParty {
            case "Republican":
                Datastore.sharedDatastore.user?.party = .republican
            case "Democrat":
                Datastore.sharedDatastore.user?.party = .democrat
            case "Independent":
                Datastore.sharedDatastore.user?.party = .independent
            default:
                break
            }
            }
            if let dob = dobTextField.text {
                Datastore.sharedDatastore.user?.dob = DateFormatter.presentationDateFormatter.date(from: dob)
            }
            Datastore.sharedDatastore.user?.streetAddress = address
        }
        guard let password = Datastore.sharedDatastore.user?.password else { return }
        Datastore.sharedDatastore.register(with: password) { (success) in
            if success {
                NotificationCenter.default.post(name: Notification.Name(rawValue: "toMainVC"), object: nil)
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
            (InputValidation.validateAddress, partyTextField.text, partyUnderlineView),
            (InputValidation.validateAddress, dobTextField.text, dobUnderlineView)
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
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.layoutIfNeeded()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true 
    }
    
    func animate(_ underlineView: UIView, with validation: Bool) {
        UIView.animate(withDuration: 1, animations: {
            underlineView.backgroundColor = validation ? UIColor.kratosBlue : UIColor.kratosRed
            underlineView.layoutIfNeeded()
        })
    }
}
