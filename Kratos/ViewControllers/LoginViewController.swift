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
            UIView.animateWithDuration(0.15) {
                let registerOrSignIn = self.isLogin ? "REGISTER" : "SIGN IN"
                let nextOrSubmit = self.isLogin ? "LOG IN" : "NEXT"
                self.registerOrSignInButton.setTitle(registerOrSignIn, forState: .Normal)
                self.nextOrSubmitButton.setTitle(nextOrSubmit, forState: .Normal)
                self.view.layoutIfNeeded()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGestureRecognizer()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        phoneNumberTextField.delegate = self
        passwordTextField.delegate = self
        passwordConfirmationTextField.delegate = self
        beginningAnimations()
    }
    
    func beginningAnimations() {
        nextButton.alpha = 0
        UIView.animateWithDuration(1, delay: 0, options: [], animations: {
            self.kratosImageViewLarge.active = false
            self.kratosImageViewSmall.active = true
            self.kratosImageViewCentered.active = false
            self.kratosImageViewTop.active = true
            self.view.layoutIfNeeded()
            }, completion: nil)
        
        phoneNumberTextField.alpha = 0.01
        passwordTextField.alpha = 0.01
        
        UIView.animateWithDuration(1, delay: 1, options: [], animations: {
            self.phoneNumberNoWidthConstraint.active = false
            self.phoneNumberFullWidthConstraint.active = true
            
            self.passwordNoWidthConstraint.active = false
            self.passwordFullWidthConstraint.active = true

            self.view.layoutIfNeeded()
        }, completion: nil)
        
        UIView.animateWithDuration(0.5, delay: 1.5, options: [UIViewAnimationOptions.TransitionCrossDissolve], animations: {
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
    
    @IBAction func registerButtonPressed(sender: AnyObject) {
        isLogin = !isLogin
        if isLogin {
            passwordConfirmationTextField.alpha = 1
            UIView.animateWithDuration(0.5, delay: 0, options: [UIViewAnimationOptions.TransitionCrossDissolve], animations: {
                self.passwordConfirmationTextField.alpha = 0.01
                self.view.layoutIfNeeded()
                }, completion: nil)
            
            UIView.animateWithDuration(0.5, delay: 0.5, options: [], animations: {
                self.passwordConfirmationFullWIdthConstraint.active = false
                self.passwordConfirmationNoWidthConstraint.active = true
                self.view.layoutIfNeeded()
                }, completion: nil)
        } else {
            passwordConfirmationTextField.alpha = 0.01
            UIView.animateWithDuration(1, delay: 0, options: [], animations: {
                self.passwordConfirmationNoWidthConstraint.active = false
                self.passwordConfirmationFullWIdthConstraint.active = true
                self.view.layoutIfNeeded()
                }, completion: nil)
            
            UIView.animateWithDuration(0.5, delay: 1, options: [UIViewAnimationOptions.TransitionCrossDissolve], animations: {
                self.passwordConfirmationTextField.alpha = 1
                self.view.layoutIfNeeded()
                }, completion: nil)
        }
        
    }
    
    @IBAction func nextButtonPressed(sender: AnyObject) {
        if isLogin {
            if let phone = phoneNumberTextField.text,
                let phoneInt = Int(phone),
                let password = passwordTextField.text where textFieldsValid() {
                Datastore.sharedDatastore.loginWith(phoneInt, and: password, onCompletion: { (success) in
                    if success {
                        NSNotificationCenter.defaultCenter().postNotificationName("toMainVC", object: nil)
                    } else {
                        let alertVC = UIAlertController(title: "Invalid Credentials", message: "Your phone number and password combination do not match our records", preferredStyle: .Alert)
                        alertVC.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) in
                            self.dismissViewControllerAnimated(false, completion: nil)
                        }))
                        self.presentViewController(alertVC, animated: true, completion: nil)
                    }
                })
            } else {
                let alertVC = UIAlertController(title: "Invalid Input", message: "Your phone and/or password are invalid", preferredStyle: .Alert)
                alertVC.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) in
                    self.dismissViewControllerAnimated(false, completion: nil)
                }))
                self.presentViewController(alertVC, animated: true, completion: nil)
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
    
    func animate(underlineView: UIView, with validation: Bool) {
        UIView.animateWithDuration(0.5, animations: {
            underlineView.backgroundColor = validation ? UIColor.kratosBlue : UIColor.kratosRed
            underlineView.layoutIfNeeded()
        })
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        textField.layoutIfNeeded()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func handleTapOutside(recognizer: UITapGestureRecognizer) {
        view.endEditing(true)
        if textFieldsValid() {
            UIView.animateWithDuration(1, animations: {
                self.nextButton.alpha = 1
                self.kratosLabel.alpha = 0
                self.view.layoutIfNeeded()
            })
        } else {
            UIView.animateWithDuration(1, animations: {
                self.kratosLabel.alpha = 1
                self.nextButton.alpha = 0
                self.view.layoutIfNeeded()
            })
        }
    }
    
    private func setupGestureRecognizer() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(SubmitAddressViewController.handleTapOutside(_:)))
        view.addGestureRecognizer(tapRecognizer)
    }
}
