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
    }
    
    private func setupGestureRecognizer() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(SubmitAddressViewController.handleTapOutside(_:)))
        view.addGestureRecognizer(tapRecognizer)
    }
    
    
    
    
}
