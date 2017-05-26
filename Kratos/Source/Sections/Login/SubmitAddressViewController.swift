//
//  SubmitAddressViewController.swift
//  Kratos
//
//  Created by Dylan Straughan on 7/30/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import UIKit

class SubmitAddressViewController: UIViewController, KratosTextFieldDelegate, DatePickerViewDelegate, UIScrollViewDelegate, ActivityIndicatorPresenter {
    
    enum DisplayType {
        case editProfile
        case accountDetails
        case registration
    }
    
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
    
    @IBOutlet weak var firstNameTextField: KratosTextField!
    @IBOutlet weak var lastNameTextField: KratosTextField!
    @IBOutlet weak var partyTextField: KratosTextField!
    @IBOutlet weak var dobTextField: KratosTextField!
    @IBOutlet weak var addressTextField: KratosTextField!
    @IBOutlet weak var cityTextField: KratosTextField!
    @IBOutlet weak var stateTextField: KratosTextField!
    @IBOutlet weak var zipcodeTextField: KratosTextField!
    @IBOutlet weak var oldPasswordTextField: KratosTextField!
    @IBOutlet weak var newPasswordTextField: KratosTextField!
    
    var activityIndicator: KratosActivityIndicator? = KratosActivityIndicator()
    var shadeView: UIView = UIView()
    
    public var displayType: DisplayType = .registration {
        didSet {
            switch displayType {
            case .editProfile:
                cancelDoneButton.alpha = 1
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
            return [firstNameTextField, lastNameTextField, partyTextField, dobTextField, addressTextField, cityTextField, stateTextField, zipcodeTextField]
        }
    }
    fileprivate var accountDetailsTextFieldArray: [KratosTextField] {
        get {
            return [firstNameTextField, lastNameTextField, partyTextField, dobTextField, addressTextField, cityTextField, stateTextField, zipcodeTextField]
        }
    }
    fileprivate var editTextFieldArray: [KratosTextField] {
        get {
            return [firstNameTextField, lastNameTextField, partyTextField, dobTextField, addressTextField, cityTextField, stateTextField, zipcodeTextField]
        }
    }
    
    var tapView: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        enableSwipeBack()
        
        newPasswordTextField.isHidden = true
        oldPasswordTextField.isHidden = true
        
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
        let firstName = Datastore.shared.user?.firstName
        let lastName = Datastore.shared.user?.lastName
        let party = Datastore.shared.user?.party?.rawValue
                let address = Datastore.shared.user?.address?.street
        let city = Datastore.shared.user?.address?.city
        let state = Datastore.shared.user?.address?.state
        var dob: String? {
            if let date = Datastore.shared.user?.dob {
                return DateFormatter.presentationDateFormatter.string(from: date)
            } else {
                return nil
            }
        }
        var zip: String? {
            if let zip = Datastore.shared.user?.address?.zipCode {
                return String(zip)
            } else {
                return nil
            }
        }
    }
    
    fileprivate func beginningAnimations() {
        
        let delay: Double = displayType == .accountDetails ? 0 : 0.5
        
        UIView.animate(withDuration: 0.5, delay: delay, options: [], animations: {
            self.kratosImageViewLarge.isActive = false
            self.kratosImageViewSmall.isActive = true
            self.kratosImageViewCentered.isActive = false
            self.kratosImageViewTop.isActive = true
            self.view.layoutIfNeeded()
        }, completion: nil)
        
        UIView.animate(withDuration: 0.5, delay: (delay + 1), options: [], animations: {
            
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
            
                var user = Datastore.shared.user
                var address = Address()
                address.street = addressTextField.text?.localizedCapitalized
                address.city = cityTextField.text?.localizedCapitalized
                address.state = stateTextField.text?.capitalized
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
                if let first = firstNameTextField.text {
                    user?.firstName = first.localizedCapitalized
                }
                if let last = lastNameTextField.text {
                    user?.lastName = last.localizedCapitalized
                }
                user?.address = address
                Datastore.shared.user = user
            
        }
        
        //TODO: - need to talk about how to store this information
        let password = Datastore.shared.user?.password ?? ""
        
        switch displayType {
        case .accountDetails: //switch to Edit Profile
            displayType = .editProfile
        case .editProfile: //save profile & switch to Account Details
            updateUser()
            presentActivityIndicator()
            APIManager.updateUser(success: { [weak self] (success) in
                self?.hideActivityIndicator()
                self?.presentMessageAlert(title: "Update Successful", message: "Your account has been updated.", buttonOneTitle: "O K")
                self?.displayType = .accountDetails
            }, failure: { (error) in
                self.hideActivityIndicator()
                debugPrint("SubmitAddressViewController updateUser unsucessful")
                self.showError(error: error)
            })
        case .registration:
            updateUser()
            var count = 1
            print("\(count) registration button pressed")
            self.presentActivityIndicator()
            APIManager.register(with: password, keyChainSuccess: { (success) in
                self.hideActivityIndicator()
                if success {
                    count += 1
                    debugPrint("\(count)Register API Call w created keychain")
                } else {
                    count += 1
                    debugPrint("\(count)Register API Call w keychain failure")
                }
                if UIApplication.shared.isRegisteredForRemoteNotifications {
                    self.hideActivityIndicator()
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "toMainVC"), object: nil)
                } else {
                    self.hideActivityIndicator()
                    let vc: NotificationsRegistrationViewController = NotificationsRegistrationViewController.instantiate()
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                
            }, failure: { (error) in
                self.hideActivityIndicator()
                debugPrint("SubmitAddressViewController registerWith(\(password)) unsucessful")
                self.showError(error: error)
            })
        }
    }
    
    @IBAction func cancelDoneButtonPressed(_ sender: Any) {
    
        switch displayType {
        case .accountDetails:
            self.dismiss(animated: true, completion: nil)
        default: // reset information and go back to account accountDetails
            displayType = .accountDetails
            
            // pull information from Datastore's User
            let first = Datastore.shared.user?.firstName
            let last = Datastore.shared.user?.lastName
            let party = Datastore.shared.user?.party?.rawValue
            let address = Datastore.shared.user?.address?.street
            let city = Datastore.shared.user?.address?.city
            let state = Datastore.shared.user?.address?.state
            var dob: String? {
                if let date = Datastore.shared.user?.dob {
                    return DateFormatter.presentationDateFormatter.string(from: date)
                } else {
                    return nil
                }
            }
            var zip: String? {
                if let zip = Datastore.shared.user?.address?.zipCode {
                    return String(zip)
                } else {
                    return nil
                }
            }

            // set all textFields back to original values
            firstNameTextField.setText(first ?? "")
            lastNameTextField.setText(last ?? "")
            partyTextField.setText((party ?? ""))
            addressTextField.setText((address ?? ""))
            dobTextField.setText((dob ?? ""))
            cityTextField.setText((city ?? ""))
            zipcodeTextField.setText((zip ?? ""))
            stateTextField.setText((state ?? ""))
            oldPasswordTextField.setText("")
            newPasswordTextField.setText("")
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
        
    }
    
    //MARK: KratosTextFieldDelegate Methods
    func didSelectTextField(textField: KratosTextField) {
        if textField == dobTextField {
            displayDatePickerView()
            view.endEditing(true)
        } else if textField == partyTextField {
            view.endEditing(true)
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
