//
//  SubmitAddressViewController.swift
//  Kratos
//
//  Created by Dylan Straughan on 7/30/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import UIKit

class SubmitAddressViewController: UIViewController, KratosTextFieldDelegate, DatePickerViewDelegate, UIScrollViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var kratosLabel: UILabel!
    @IBOutlet weak var saveEditRegisterButtonButton: UIButton!
    @IBOutlet weak var datePicker: DatePickerView!
    @IBOutlet weak var cancelDoneButton: UIButton!
    
    @IBOutlet weak var datePickerYConstraint: NSLayoutConstraint!
    
    @IBOutlet var kratosImageViewTop: NSLayoutConstraint!
    @IBOutlet var kratosImageViewCentered: NSLayoutConstraint!
    @IBOutlet var kratosImageViewSmall: NSLayoutConstraint!
    @IBOutlet var kratosImageViewLarge: NSLayoutConstraint!
    
    @IBOutlet weak var partyTextField: KratosTextField!
    @IBOutlet weak var dobTextField: KratosTextField!
    @IBOutlet weak var addressTextField: KratosTextField!
    @IBOutlet weak var cityTextField: KratosTextField!
    @IBOutlet weak var stateTextField: KratosTextField!
    @IBOutlet weak var zipcodeTextField: KratosTextField!
    @IBOutlet weak var phoneNumberTextField: KratosTextField!
    @IBOutlet weak var oldPasswordTextField: KratosTextField!
    @IBOutlet weak var newPasswordTextField: KratosTextField!
    
    public var displayType: DisplayType = .registration {
        didSet {
            switch displayType {
            case .editProfile:
                cancelDoneButton.alpha = 1
                newPasswordTextField.animateIn()
                oldPasswordTextField.animateIn()
                UIView.animate(withDuration: 0.25, animations: {
                    self.saveEditRegisterButtonButton.setTitle("S A V E", for: .normal)
                    self.cancelDoneButton.setTitle("C A N C E L", for: .normal)
                    self.view.layoutIfNeeded()

                })
                editTextFieldArray.forEach({
                    $0.isEditable = true
                })
            case .accountDetails:
                cancelDoneButton.alpha = 1
                newPasswordTextField.animateOut()
                oldPasswordTextField.animateOut()
                UIView.animate(withDuration: 0.25, animations: {
                    self.saveEditRegisterButtonButton.setTitle("E D I T", for: .normal)
                    self.cancelDoneButton.setTitle("D O N E", for: .normal)
                    self.view.layoutIfNeeded()
                })
                
                editTextFieldArray.forEach({
                    $0.isEditable = false
                })
            case .registration:
                cancelDoneButton.alpha = 0
                self.saveEditRegisterButtonButton.setTitle("R E G I S T E R", for: .normal)
                registrationTextFieldArray.forEach({
                    $0.isEditable = true
                })
                self.view.layoutIfNeeded()
            }
        }
    }
    fileprivate var registrationTextFieldArray: [KratosTextField] {
        get {
            return [partyTextField, dobTextField, addressTextField, cityTextField, stateTextField, zipcodeTextField]
        }
    }
    fileprivate var accountDetailsTextFieldArray: [KratosTextField] {
        get {
            return [partyTextField, dobTextField, addressTextField, cityTextField, stateTextField, zipcodeTextField, phoneNumberTextField]
        }
    }
    fileprivate var editTextFieldArray: [KratosTextField] {
        get {
            return [partyTextField, dobTextField, addressTextField, cityTextField, stateTextField, zipcodeTextField, phoneNumberTextField, oldPasswordTextField, newPasswordTextField]
        }
    }
    fileprivate var textFieldsValid: Bool {
        var valid = true
        var collection: [KratosTextField] {
            switch displayType {
            case .editProfile:
                return editTextFieldArray
            case .accountDetails:
                return accountDetailsTextFieldArray
            case .registration:
                return registrationTextFieldArray
            }
        }
        collection.forEach({
            if !$0.isValid {
                valid = false
            }
        })
        return valid
    }
    
    enum DisplayType {
        case editProfile
        case accountDetails
        case registration
    }
    
    var tapView: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        enableSwipeBack()
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidHide(sender:)), name: NSNotification.Name.UIKeyboardDidHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow(sender:)),name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        // set initial state for textFields
        editTextFieldArray.forEach {
            $0.animateOut()
        }
        
        self.saveEditRegisterButtonButton.alpha = 0
        dobTextField.delegate = self
        partyTextField.delegate = self
        datePicker.delegate = self
        scrollView.delegate = self

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        configureTextFields()
        beginningAnimations()
        setupGestureRecognizer()
    }
    
    func configureTextFields() {
        // pulling information from sharedDataStore if available
        let party = Datastore.sharedDatastore.user?.party?.rawValue
                let address = Datastore.sharedDatastore.user?.streetAddress?.street
        let city = Datastore.sharedDatastore.user?.streetAddress?.city
        let state = Datastore.sharedDatastore.user?.streetAddress?.state
        var dob: String? {
            if let date = Datastore.sharedDatastore.user?.dob {
                return DateFormatter.presentationDateFormatter.string(from: date)
            } else {
                return nil
            }
        }
        var zip: String? {
            if let zip = Datastore.sharedDatastore.user?.streetAddress?.zipCode {
                return String(zip)
            } else {
                return nil
            }
        }
        var phone: String? {
            if let phone = Datastore.sharedDatastore.user?.phoneNumber {
                return String(phone)
            } else {
                return nil
            }
        }
        
        partyTextField.configureWith(validationFunction: InputValidation.validateAddress, text: party, textlabelText: "P A R T Y", expandedWidth: (view.frame.width * 0.3), secret: false, shouldPresentKeyboard: false)
        dobTextField.configureWith(validationFunction: InputValidation.validateAddress, text: dob, textlabelText: "B I R T H  D A T E", expandedWidth: (view.frame.width * 0.3), secret: false, shouldPresentKeyboard: false)
        addressTextField.configureWith(validationFunction: InputValidation.validateAddress, text: address, textlabelText: "A D D R E S S", expandedWidth: (view.frame.width * 0.8), secret: false)
        cityTextField.configureWith(validationFunction: InputValidation.validateCity, text: city, textlabelText: "C I T Y", expandedWidth: (view.frame.width * 0.3), secret: false)
        stateTextField.configureWith(validationFunction: InputValidation.validateState, text: state, textlabelText: "S T A T E", expandedWidth: (view.frame.width * 0.16), secret: false)
        zipcodeTextField.configureWith(validationFunction: InputValidation.validateZipCode, text: zip, textlabelText: "Z I P", expandedWidth: (view.frame.width * 0.3), secret: false)
        phoneNumberTextField.configureWith(validationFunction: InputValidation.validatePhoneNumber, text: phone, textlabelText: "P H O N E", expandedWidth: (view.frame.width * 0.8), secret: false)
        oldPasswordTextField.configureWith(validationFunction: InputValidation.validatePassword, text: nil, textlabelText: "O L D  P A S S W O R D", expandedWidth: (view.frame.width * 0.8), secret: true)
        newPasswordTextField.configureWith(validationFunction: InputValidation.validatePassword, text: nil, textlabelText: "N E W  P A S S W O R D", expandedWidth: (view.frame.width * 0.8), secret: true)
    }
    
    fileprivate func beginningAnimations() {
        
        let delay: Double = displayType == .accountDetails ? 0 : 1
        
        UIView.animate(withDuration: 1, delay: delay, options: [], animations: {
            self.kratosImageViewLarge.isActive = false
            self.kratosImageViewSmall.isActive = true
            self.kratosImageViewCentered.isActive = false
            self.kratosImageViewTop.isActive = true
            self.view.layoutIfNeeded()
        }, completion: nil)
        
        UIView.animate(withDuration: 1, delay: (delay + 1), options: [], animations: {
            
            switch self.displayType {
            case .registration:
                self.registrationTextFieldArray.forEach({
                    $0.animateIn()
                })
            case .accountDetails:
                self.accountDetailsTextFieldArray.forEach({
                    $0.animateIn()
                })
                self.kratosLabel.alpha = 0
                self.saveEditRegisterButtonButton.alpha = 1
            case .editProfile:
                self.editTextFieldArray.forEach({
                    $0.animateIn()
                })
                self.kratosLabel.alpha = 0
                self.saveEditRegisterButtonButton.alpha = 1
            }
            self.view.layoutIfNeeded()
        }, completion: nil)
        
    }
    
    fileprivate func setupGestureRecognizer() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(SubmitAddressViewController.handleTapOutside(_:)))
        view.addGestureRecognizer(tapRecognizer)
    }
    
    func handleTapOutside(_ recognizer: UITapGestureRecognizer) {
        // Resign First Responder
        // This will trigger UIKeyboardDidHide which will trigger validation process
        view.endEditing(true)
    }
    
    @IBAction func saveEditRegisterButtonPressed(_ sender: Any) {
        // Updates user in the Datastore
        func updateUser() {
            if textFieldsValid {
                var user = Datastore.sharedDatastore.user
                var address = StreetAddress()
                address.street = addressTextField.text
                address.city = cityTextField.text
                address.state = stateTextField.text
                if let stringZip = zipcodeTextField.text,
                    let zip = Int(stringZip) {
                    address.zipCode = zip
                }
                if let party = partyTextField.text {
                    user?.party = Party(rawValue: party)
                }

                if let dob = dobTextField.text {
                    user?.dob = DateFormatter.presentationDateFormatter.date(from: dob)
                }
                user?.streetAddress = address
                Datastore.sharedDatastore.user = user
            }
        }
        
        //TODO: - need to talk about how to store this information
        let password = Datastore.sharedDatastore.user?.password ?? ""
        
        switch displayType {
        case .accountDetails: //switch to Edit Profile
            displayType = .editProfile
        case .editProfile: //save profile & switch to Account Details
            displayType = .accountDetails
            updateUser()
            APIManager.register(with: password) { (success) in
                if success {
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "toMainVC"), object: nil)
                } else {
                    print("SubmitAddressViewController registerWith(\(password)) unsucessful")
                }
            }
        case .registration:
            updateUser()
            APIManager.register(with: password) { (success) in
                if success {
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "toMainVC"), object: nil)
                } else {
                    print("SubmitAddressViewController registerWith(\(password)) unsucessful")
                }
            }
        }
    }
    
    @IBAction func cancelDoneButtonPressed(_ sender: Any) {
    
        switch displayType {
        case .accountDetails:
            self.dismiss(animated: true, completion: nil)
        default: // reset information and go back to account accountDetails
            displayType = .accountDetails
            
            // pull information from Datastore's User
            let party = Datastore.sharedDatastore.user?.party?.rawValue
            let address = Datastore.sharedDatastore.user?.streetAddress?.street
            let city = Datastore.sharedDatastore.user?.streetAddress?.city
            let state = Datastore.sharedDatastore.user?.streetAddress?.state
            var dob: String? {
                if let date = Datastore.sharedDatastore.user?.dob {
                    return DateFormatter.presentationDateFormatter.string(from: date)
                } else {
                    return nil
                }
            }
            var zip: String? {
                if let zip = Datastore.sharedDatastore.user?.streetAddress?.zipCode {
                    return String(zip)
                } else {
                    return nil
                }
            }
            var phone: String? {
                if let phone = Datastore.sharedDatastore.user?.phoneNumber {
                    return String(phone)
                } else {
                    return nil
                }
            }
            // set all textFields back to original values
            partyTextField.setText((party ?? ""))
            addressTextField.setText((address ?? ""))
            dobTextField.setText((dob ?? ""))
            cityTextField.setText((city ?? ""))
            zipcodeTextField.setText((zip ?? ""))
            stateTextField.setText((state ?? ""))
            phoneNumberTextField.setText((phone ?? ""))
            oldPasswordTextField.setText("")
            newPasswordTextField.setText("")
        }
    }
    
    func shouldCheckIfTextFieldsValid() {
        if (displayType == .registration) && textFieldsValid {
            UIView.animate(withDuration: 1, animations: {
                self.saveEditRegisterButtonButton.alpha = 1
                self.kratosLabel.alpha = 0
                self.view.layoutIfNeeded()
            })
        } else {
            UIView.animate(withDuration: 1, animations: {
                self.kratosLabel.alpha = 1
                self.saveEditRegisterButtonButton.alpha = 0
                self.view.layoutIfNeeded()
            })
        }
    }
    
    //MARK: Keyboard Notification Handling
    func handleKeyboardWillShow(sender: NSNotification) {
        let userInfo = sender.userInfo
        let keyboardRect = userInfo?[UIKeyboardFrameBeginUserInfoKey]  as! CGRect
        let size = keyboardRect.size
        let contentInsets = UIEdgeInsetsMake(self.view.frame.origin.x, self.view.frame.origin.x, size.height, 0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
    
    func handleKeyboardDidHide(sender: NSNotification) {
        UIView.animate(withDuration: 0.2, animations: {
            self.scrollView.contentInset = UIEdgeInsets.zero
            self.scrollView.scrollIndicatorInsets = UIEdgeInsets.zero
            self.view.layoutIfNeeded()
        })
        
        shouldCheckIfTextFieldsValid()
    }
    
    //MARK: KratosTextFieldDelegate Methods
    func didSelectTextField(textField: KratosTextField) {
        if textField == dobTextField {
            displayDatePickerView()
        } else if textField == partyTextField {
            let alertVC = UIAlertController.init(title: "P A R T Y", message: "Choose your party affiliation", preferredStyle: .actionSheet)
            alertVC.addAction(UIAlertAction(title: "D E M O C R A T", style: .destructive, handler: { (action) in
                self.partyTextField.setText("Democrat")
            }))
            alertVC.addAction(UIAlertAction(title: "R E P U B L I C A N", style: .destructive, handler: { (action) in
                self.partyTextField.setText("Republican")
            }))
            alertVC.addAction(UIAlertAction(title: "I N D E P E N D E N T", style: .destructive, handler: { (action) in
                self.partyTextField.setText("Independent")
            }))
            present(alertVC, animated: true, completion: nil)
        }
    }
    
    //MARK: DatePickerView Delegate Method
    func selectedDate(date: Date) {
        dobTextField.setText(DateFormatter.presentationDateFormatter.string(from: date))
        dismissDatePickerView()
    }
    
    //MARK: DatePicker UI Methods
    func displayDatePickerView() {
        tapView = UIView(frame: view.frame)
        view.addSubview(tapView ?? UIView())
        view.bringSubview(toFront: tapView!)
        view.bringSubview(toFront: datePicker)
        tapView?.backgroundColor = UIColor.black
        tapView?.alpha = 0
        
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseInOut, animations: {
            self.tapView?.alpha = 0.4
            self.datePickerYConstraint.constant = 250
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    func dismissDatePickerView() {
        
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseInOut, animations: {
            self.datePickerYConstraint.constant = -3
            self.tapView?.alpha = 0
            self.view.layoutIfNeeded()
        }, completion: { _ in
            self.tapView?.removeFromSuperview()
            self.tapView = nil
        })
    }
}
