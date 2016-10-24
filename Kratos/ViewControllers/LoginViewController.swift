//
//  LogInViewController.swift
//  Kratos
//
//  Created by Dylan Straughan on 9/13/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var kratosImageView: UIImageView!
    @IBOutlet var kratosImageViewLarge: NSLayoutConstraint!
    @IBOutlet var kratosImageViewSmall: NSLayoutConstraint!
    @IBOutlet var kratosImageViewTop: NSLayoutConstraint!
    @IBOutlet var kratosImageViewCentered: NSLayoutConstraint!
    
    @IBOutlet var kratosLabel: UILabel!
    @IBOutlet var nextButton: UIButton!
    
    @IBOutlet var phoneNumberTextField: UITextField!
    @IBOutlet var phoneNumberUnderlineView: UIView!
    
    @IBOutlet var phoneNumberFullWidthConstraint: NSLayoutConstraint!
    @IBOutlet var phoneNumberNoWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var passwordUnderlineView: UIView!
    
    @IBOutlet var passwordFullWidthConstraint: NSLayoutConstraint!
    @IBOutlet var passwordNoWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet var passwordConfirmationTextField: UITextField!
    @IBOutlet var passwordConfirmationUnderlineView: UIView!
    
    @IBOutlet var passwordConfirmationFullWIdthConstraint: NSLayoutConstraint!
    @IBOutlet var passwordConfirmationNoWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet var nextOrSubmitButton: UIButton!
    @IBOutlet var registerOrSignInButton: UIButton!
    
    var isLogin = true {
        didSet {
            UIView.animate(withDuration: 0.15, animations: {
                let registerOrSignIn = self.isLogin ? "REGISTER" : "SIGN IN"
                let nextOrSubmit = self.isLogin ? "LOG IN" : "NEXT"
                self.registerOrSignInButton.setTitle(registerOrSignIn, for: UIControlState())
                self.nextOrSubmitButton.setTitle(nextOrSubmit, for: UIControlState())
                self.view.layoutIfNeeded()
            }) 
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGestureRecognizer()
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.tintColor = UIColor.kratosBlue
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        phoneNumberTextField.delegate = self
        passwordTextField.delegate = self
        passwordConfirmationTextField.delegate = self
        beginningAnimations()
    }
    
    func beginningAnimations() {
        nextButton.alpha = 0
        UIView.animate(withDuration: 1, delay: 0, options: [], animations: {
            self.kratosImageViewLarge.isActive = false
            self.kratosImageViewSmall.isActive = true
            self.kratosImageViewCentered.isActive = false
            self.kratosImageViewTop.isActive = true
            self.view.layoutIfNeeded()
            }, completion: nil)
        
        phoneNumberTextField.alpha = 0.01
        passwordTextField.alpha = 0.01
        
        UIView.animate(withDuration: 1, delay: 1, options: [], animations: {
            self.phoneNumberNoWidthConstraint.isActive = false
            self.phoneNumberFullWidthConstraint.isActive = true
            
            self.passwordNoWidthConstraint.isActive = false
            self.passwordFullWidthConstraint.isActive = true

            self.view.layoutIfNeeded()
        }, completion: nil)
        
        UIView.animate(withDuration: 0.5, delay: 1.5, options: [UIViewAnimationOptions.transitionCrossDissolve], animations: {
            self.phoneNumberTextField.alpha = 1
            self.passwordTextField.alpha = 1
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    func textFieldsValid() -> Bool {
        var valid = true
        var collection: [(Bool, UIView)] = []
        if isLogin {
            collection = [
                (InputValidation.validatePhoneNumber(phoneNumberTextField.text), phoneNumberUnderlineView),
                (InputValidation.validatePassword(passwordTextField.text), passwordUnderlineView),
            ]
        } else {
            collection = [
                (InputValidation.validatePhoneNumber(phoneNumberTextField.text), phoneNumberUnderlineView),
                (InputValidation.validatePassword(passwordTextField.text), passwordUnderlineView),
                (InputValidation.validatePasswordConfirmation(passwordTextField.text, passwordConfirmation: passwordConfirmationTextField.text), passwordConfirmationUnderlineView)
            ]
        }
        
        for (isValid, view) in collection {
            animate(view, with: isValid)
            if !isValid {
                valid = false
            }
        }
        return valid
    }
    
    @IBAction func registerButtonPressed(_ sender: AnyObject) {
        isLogin = !isLogin
        if isLogin {
            passwordConfirmationTextField.alpha = 1
            UIView.animate(withDuration: 0.5, delay: 0, options: [UIViewAnimationOptions.transitionCrossDissolve], animations: {
                self.passwordConfirmationTextField.alpha = 0.01
                self.view.layoutIfNeeded()
                }, completion: nil)
            
            UIView.animate(withDuration: 0.5, delay: 0.5, options: [], animations: {
                self.passwordConfirmationFullWIdthConstraint.isActive = false
                self.passwordConfirmationNoWidthConstraint.isActive = true
                self.view.layoutIfNeeded()
                }, completion: nil)
        } else {
            passwordConfirmationTextField.alpha = 0.01
            UIView.animate(withDuration: 1, delay: 0, options: [], animations: {
                self.passwordConfirmationNoWidthConstraint.isActive = false
                self.passwordConfirmationFullWIdthConstraint.isActive = true
                self.view.layoutIfNeeded()
                }, completion: nil)
            
            UIView.animate(withDuration: 0.5, delay: 1, options: [UIViewAnimationOptions.transitionCrossDissolve], animations: {
                self.passwordConfirmationTextField.alpha = 1
                self.view.layoutIfNeeded()
                }, completion: nil)
        }
        
    }
    
    @IBAction func nextButtonPressed(_ sender: AnyObject) {
        if isLogin {
            if let phone = phoneNumberTextField.text,
                let phoneInt = Int(phone),
                let password = passwordTextField.text , textFieldsValid() {
                Datastore.sharedDatastore.loginWith(phoneInt, and: password, onCompletion: { (success) in
                    if success {
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "toMainVC"), object: nil)
                    } else {
                        let alertVC = UIAlertController(title: "Invalid Credentials", message: "Your phone number and password combination do not match our records", preferredStyle: .alert)
                        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                            self.dismiss(animated: false, completion: nil)
                        }))
                        self.present(alertVC, animated: true, completion: nil)
                    }
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
            guard let phoneNumber = phoneNumberTextField.text else { return }
            user.phoneNumber = Int(phoneNumber)
            user.password = passwordTextField.text
            Datastore.sharedDatastore.user = user
            self.navigationController?.pushViewController(viewController, animated: true)
        }
        
    }
    
    func animate(_ underlineView: UIView, with validation: Bool) {
        UIView.animate(withDuration: 0.5, animations: {
            underlineView.backgroundColor = validation ? UIColor.kratosBlue : UIColor.kratosRed
            underlineView.layoutIfNeeded()
        })
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.layoutIfNeeded()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func handleTapOutside(_ recognizer: UITapGestureRecognizer) {
        view.endEditing(true)
        if textFieldsValid() {
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
    
    fileprivate func setupGestureRecognizer() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(SubmitAddressViewController.handleTapOutside(_:)))
        view.addGestureRecognizer(tapRecognizer)
    }
}
