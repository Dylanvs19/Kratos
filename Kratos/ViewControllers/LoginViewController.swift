//
//  LogInViewController.swift
//  Kratos
//
//  Created by Dylan Straughan on 9/13/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import UIKit
import SafariServices
class LoginViewController: UIViewController, ActivityIndicatorPresenter {
    
    @IBOutlet var kratosImageView: UIImageView!
    
    @IBOutlet var kratosImageViewLarge: NSLayoutConstraint!
    @IBOutlet var kratosImageViewSmall: NSLayoutConstraint!
    @IBOutlet var kratosImageViewTop: NSLayoutConstraint!
    @IBOutlet var kratosImageViewCentered: NSLayoutConstraint!
    
    @IBOutlet var kratosLabel: UILabel!
    @IBOutlet var nextButton: UIButton!
    
    @IBOutlet var nextOrSubmitButton: UIButton!
    @IBOutlet var registerOrSignInButton: UIButton!
    
    @IBOutlet weak var emailTextField: KratosTextField!
    @IBOutlet weak var passwordTextField: KratosTextField!
    @IBOutlet weak var passwordConfirmationTextField: KratosTextField!
    
    var activityIndicator: KratosActivityIndicator? = KratosActivityIndicator()
    var shadeView: UIView = UIView()
    
    enum ViewType {
        case login
        case registration
        case forgotPassword
    }
    
    var viewType: ViewType = .login {
        didSet {
            shouldCheckIfTextFieldsValid()

            var submitButtonTitle = "L O G I N"
            var registerButton = "C R E A T E  A C C O U N T"
            switch viewType {
            case .login:
                submitButtonTitle = "L O G I N"
                registerButton = "C R E A T E  A C C O U N T"
            case .registration:
                submitButtonTitle = "C O N T I N U E"
                registerButton = "S I G N  I N"
            case .forgotPassword:
                submitButtonTitle = "S U B M I T"
                registerButton = "S I G N  I N"
            }
            UIView.animate(withDuration: 0.15, animations: {
                self.registerOrSignInButton.setTitle(registerButton, for: UIControlState())
                self.nextOrSubmitButton.setTitle(submitButtonTitle, for: UIControlState())
                self.view.layoutIfNeeded()
            })
        }
    }
    
    fileprivate var textFieldsValid: Bool {
        var valid = true
        var collection: [KratosTextField] {
            switch viewType {
            case .login:
                return [emailTextField, passwordTextField]
            case .registration:
                return [emailTextField, passwordTextField, passwordConfirmationTextField]
            case .forgotPassword:
                return [emailTextField]
            }
        }
        collection.forEach {
            if !$0.isValid {
                valid = false
            }
        }
        return valid
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.nextButton.alpha = 0
        viewType = .login
        setupGestureRecognizer()
        navigationController?.isNavigationBarHidden = true
        navigationController?.navigationBar.tintColor = UIColor.kratosBlue
        // If keyboard is hiding - should validate textFields
        NotificationCenter.default.addObserver(self, selector:#selector(shouldCheckIfTextFieldsValid), name: NSNotification.Name.UIKeyboardDidHide, object: nil)
        // set initial state for textFields
        emailTextField.animateOut()
        passwordTextField.animateOut()
        passwordConfirmationTextField.animateOut()
        //setupActivityIndicator()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let expandedWidth = self.view.frame.width * 0.8
        emailTextField.configureWith(validationFunction: InputValidation.validateEmail, text: nil, textlabelText: "E M A I L", expandedWidth: expandedWidth, secret: false, textFieldType: .email)
        passwordTextField.configureWith(validationFunction: InputValidation.validatePassword, text: nil, textlabelText: "P A S S W O R D", expandedWidth: expandedWidth, secret: true, textFieldType: .password)
        passwordConfirmationTextField.configureWith(validationFunction: validatePasswordConfimation, text: nil, textlabelText: "C O N F I R M A T I O N", expandedWidth: expandedWidth, secret: true, textFieldType: .password)
        beginningAnimations()
    }
    
    fileprivate func beginningAnimations() {
        
        if textFieldsValid {
            self.nextButton.alpha = 1
            self.kratosLabel.alpha = 0
        } else {
            self.nextButton.alpha = 0
            self.kratosLabel.alpha = 1
        }
        UIView.animate(withDuration: 0.5, animations: {
            self.kratosImageViewLarge.isActive = false
            self.kratosImageViewSmall.isActive = true
            self.kratosImageViewCentered.isActive = false
            self.kratosImageViewTop.isActive = true
            self.view.layoutIfNeeded()
        })
        UIView.animate(withDuration: 0.25, delay: 0.5, options: [], animations: {
            self.emailTextField.animateIn()
            self.passwordTextField.animateIn()
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    //MARK: Helper Validation Function
    fileprivate func validatePasswordConfimation(text: String) -> Bool {
        var valid = false
        if let passwordText = passwordTextField.text,
           let confirmationText = passwordConfirmationTextField.text , passwordTextField.isValid {
            valid = passwordText == confirmationText ? true : false
        }
        return valid
    }
    
    @IBAction func registerButtonPressed(_ sender: AnyObject) {
        switch viewType {
        case .login:
            UIView.animate(withDuration: 0.25, animations: {
                self.passwordConfirmationTextField.animateIn()
                self.view.layoutIfNeeded()
            }, completion: { (success) in
                self.viewType = .registration
            })
        case .registration:
            UIView.animate(withDuration: 0.25, animations: { 
                self.passwordConfirmationTextField.animateOut()
                self.view.layoutIfNeeded()
            }, completion: { (success) in
                self.viewType = .login
            })
        case .forgotPassword:
            UIView.animate(withDuration: 0.25, animations: {
                self.passwordTextField.animateIn()
                self.passwordConfirmationTextField.animateOut()
                self.view.layoutIfNeeded()
            }, completion: { (success) in
                self.viewType = .login
            })
            
        }
        shouldCheckIfTextFieldsValid()
    }
    
    @IBAction func nextButtonPressed(_ sender: AnyObject) {
        switch viewType {
        case .login:
            if let email = emailTextField.text,
                let password = passwordTextField.text , textFieldsValid {
                presentActivityIndicator()
                APIManager.login(with: email, and: password, success: { (success) in
                    self.hideActivityIndicator()
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "toMainVC"), object: nil)
                }, failure: { (error) in
                    self.hideActivityIndicator()
                    self.showError(error: error)
                })
            } else {
                let alertVC = UIAlertController(title: "Invalid Input", message: "Your phone and/or password are invalid", preferredStyle: .alert)
                alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                    self.dismiss(animated: false, completion: nil)
                }))
                self.present(alertVC, animated: true, completion: nil)
            }
        case .registration:
            let viewController: SubmitAddressViewController = SubmitAddressViewController.instantiate()
            var user = User()
            guard let email = emailTextField.text else { return }
            user.email = email
            user.password = passwordTextField.text
            Datastore.shared.user = user
            viewController.loadViewIfNeeded()
            viewController.displayType = .registration
            self.navigationController?.pushViewController(viewController, animated: true)
        case .forgotPassword:
            guard let email = emailTextField.text else { self.presentMessageAlert(title: "Error", message: "We couldn't validate your email address.", buttonOneTitle: "O K")
                return
            }
            
            APIManager.forgotPassword(with:email, success: { (success) in
                self.presentMessageAlert(title: "Email Sent", message: "An email was sent to your email address.", buttonOneTitle: "O K")
                
            }, failure: { (error) in
                self.showError(error: error)
            })
        }
    }
    
    @IBAction func forgotPasswordButtonPressed(_ sender: Any) {
        switch viewType {
        case .login:
            UIView.animate(withDuration: 0.25, animations: {
                self.passwordTextField.animateOut()
                self.passwordConfirmationTextField.animateOut()
                self.view.layoutIfNeeded()
            }, completion: { (success) in
                self.viewType = .forgotPassword
            })
        case .registration:
            UIView.animate(withDuration: 0.25, animations: {
                self.passwordTextField.animateOut()
                self.passwordConfirmationTextField.animateOut()
                self.view.layoutIfNeeded()
            }, completion: { (success) in
                self.viewType = .forgotPassword
            })
        case .forgotPassword:
            break
        }
    }
    
    func shouldCheckIfTextFieldsValid() {
        if textFieldsValid {
            UIView.animate(withDuration: 1, animations: {
                self.nextButton.alpha = 1
                self.kratosLabel.alpha = 0
                self.view.layoutIfNeeded()
            })
        } else {
            UIView.animate(withDuration: 1, animations: {
                self.kratosLabel.alpha = 1
                self.nextButton.alpha = 0
                self.view.layoutIfNeeded()
            })
        }
    }
    
    func handleTapOutside(_ recognizer: UITapGestureRecognizer) {
        shouldCheckIfTextFieldsValid()
        view.endEditing(true)
    }
    
    fileprivate func setupGestureRecognizer() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(SubmitAddressViewController.handleTapOutside(_:)))
        view.addGestureRecognizer(tapRecognizer)
    }
}
