//
//  LogInViewController.swift
//  Kratos
//
//  Created by Dylan Straughan on 9/13/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
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
    
    fileprivate var isLogin = true {
        didSet {
            UIView.animate(withDuration: 0.15, animations: {
                let registerOrSignIn = self.isLogin ? "R E G I S T E R" : "S I G N  I N"
                let nextOrSubmit = self.isLogin ? "L O G I N" : "N E X T"
                self.registerOrSignInButton.setTitle(registerOrSignIn, for: UIControlState())
                self.nextOrSubmitButton.setTitle(nextOrSubmit, for: UIControlState())
                self.view.layoutIfNeeded()
            }) 
        }
    }
    
    fileprivate var textFieldsValid: Bool {
        var valid = true
        var collection: [KratosTextField] {
            if isLogin {
                return [emailTextField, passwordTextField]
            } else {
                return [emailTextField, passwordTextField, passwordConfirmationTextField]
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
        isLogin = true 
        setupGestureRecognizer()
        navigationController?.isNavigationBarHidden = true
        navigationController?.navigationBar.tintColor = UIColor.kratosBlue
        // If keyboard is hiding - should validate textFields
        NotificationCenter.default.addObserver(self, selector:#selector(shouldCheckIfTextFieldsValid), name: NSNotification.Name.UIKeyboardDidHide, object: nil)
        // set initial state for textFields
        emailTextField.animateOut()
        passwordTextField.animateOut()
        passwordConfirmationTextField.animateOut()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let expandedWidth = self.view.frame.width * 0.8
        emailTextField.configureWith(validationFunction: InputValidation.validateEmail, text: nil, textlabelText: "E M A I L", expandedWidth: expandedWidth, secret: false)
        passwordTextField.configureWith(validationFunction: InputValidation.validatePassword, text: nil, textlabelText: "P A S S W O R D", expandedWidth: expandedWidth, secret: true)
        passwordConfirmationTextField.configureWith(validationFunction: validatePasswordConfimation, text: nil, textlabelText: "C O N F I R M A T I O N", expandedWidth: expandedWidth, secret: true)
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
        isLogin = !isLogin
        if isLogin {
            UIView.animate(withDuration: 0.25, animations: {
                self.passwordConfirmationTextField.animateOut()
                self.view.layoutIfNeeded()
            })
        } else {
            UIView.animate(withDuration: 0.25, animations: {
                self.passwordConfirmationTextField.animateIn()
                self.view.layoutIfNeeded()
            })
        }
        shouldCheckIfTextFieldsValid()
    }
    
    @IBAction func nextButtonPressed(_ sender: AnyObject) {
        if isLogin {
            if let email = emailTextField.text,
                let password = passwordTextField.text , textFieldsValid {
                APIManager.login(with: email, and: password, success: { (success) in
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "toMainVC"), object: nil)
                }, failure: { (error) in
                    self.showError(error: error)
                })
            } else {
                let alertVC = UIAlertController(title: "Invalid Input", message: "Your phone and/or password are invalid", preferredStyle: .alert)
                alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                    self.dismiss(animated: false, completion: nil)
                }))
                self.present(alertVC, animated: true, completion: nil)
            }
        } else {
            let viewController: SubmitAddressViewController = SubmitAddressViewController.instantiate()
            var user = User()
            guard let email = emailTextField.text else { return }
            user.email = email
            user.password = passwordTextField.text
            Datastore.shared.user = user
            viewController.loadViewIfNeeded()
            viewController.displayType = .registration
            self.navigationController?.pushViewController(viewController, animated: true)
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
        view.endEditing(true)
    }
    
    fileprivate func setupGestureRecognizer() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(SubmitAddressViewController.handleTapOutside(_:)))
        view.addGestureRecognizer(tapRecognizer)
    }
}
