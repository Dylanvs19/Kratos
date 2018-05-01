//
//  UIViewController+Extensions.swift
//  Kratos
//
//  Created by Dylan Straughan on 7/31/16.
//  Copyright © 2017 Kratos, Inc. All rights reserved.
//
import UIKit
import RxSwift
import RxCocoa
import SafariServices

extension UIViewController {
    
    // MARK: - RepContact Handling -
    func presentTwitter(with person: Person) {
        guard let handle = person.twitter, person.isCurrent == true else {
            let alertVC = UIAlertController(title: "Error", message: "Representative does not have a twitter account", preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "O K", style: .destructive, handler: nil))
            present(alertVC, animated: true, completion: nil)
            return
        }
        
        if let url = URL(string: "twitter://user?screen_name=\(handle)"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            if let url = URL(string: "https://twitter.com/\(handle)") {
                let vc = SFSafariViewController(url: url)
                self.present(vc, animated: true, completion: nil)
            }
        }
    }
    
    func presentSafariView(with url: String) {
        if let url = URL(string:url) {
            let vc = SFSafariViewController(url: url)
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    func presentHomeAddress(with person: Person) {
        var address = "Could not find an office address for this representative"
        if let addy = person.terms?.first?.officeAddress, person.isCurrent == true {
            address = addy
        }
        let alertVC = UIAlertController(title: "A D D R E S S", message: address, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "O K ", style: .destructive, handler: nil))
        present(alertVC, animated: true, completion: nil)
    }
    
    // MARK: - Error Handling -
    func showError(_ error: KratosError, onClose: (() -> Void)? = nil) {
        var title = localize(.errorTitle)
        var message = ""

        switch error {
        case .unknown,
             .mappingError,
             .server:
            message = localize(.errorMessage)
        case .authError(_):
            break
        case .requestError(let errorTitle, let errorMessage, _):
                title = errorTitle.localizedCapitalized
                message = errorMessage.localizedCapitalized
        }
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action) in
            onClose?()
        }))
        DispatchQueue.main.async { 
            self.present(alertVC, animated: true, completion: nil)
        }
    }
    
    func presentMessageAlert(title: String, message: String, buttonOneTitle: String, buttonTwoTitle: String? = nil, buttonOneAction:(() -> ())? = nil, buttonTwoAction:(() -> ())? = nil) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: buttonOneTitle, style: .cancel, handler: { (action) in
            buttonOneAction?()
        }))
        if let buttonTwoTitle = buttonTwoTitle {
            alertVC.addAction(UIAlertAction(title: buttonTwoTitle, style: .cancel, handler: { (action) in
                buttonTwoAction?()
            }))
        }
        DispatchQueue.main.async {
            self.present(alertVC, animated: true, completion: nil)
        }
    }
    
    // MARK: - NavVC Convenience -
    func embedInNavVC() -> UINavigationController {
        let navVC = UINavigationController()
        navVC.setViewControllers([self], animated: false)
        self.setDefaultNavVC()
        return navVC
    }
    
    func setDefaultNavVC() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationController?.navigationBar.backItem?.title = ""
        navigationController?.navigationBar.tintColor = Color.lightGray.value
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.font: Font.subHeader.value]
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.extendedLayoutIncludesOpaqueBars = true
        navigationController?.automaticallyAdjustsScrollViewInsets = false
    }
    
    func setDefaultClearButton() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "clearIcon").withRenderingMode(.alwaysOriginal).af_imageAspectScaled(toFill: CGSize(width: 25, height: 25)), style: .plain, target: self, action: #selector(clearPressed))
        self.view.layoutIfNeeded()
    }
    
    @objc private func clearPressed() {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    /// A sequence of CGFloat values for the endHeight of a UIKeyboard's height. 
    var keyboardHeight: ControlEvent<CGFloat> {
        let frameheight = NotificationCenter.default.rx
                            .notification(NSNotification.Name.UIKeyboardWillChangeFrame)
                            .map { notification -> CGFloat? in
                                guard let frame = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue else { return nil }
                                return frame.cgRectValue.height
                            }
                            .filterNil()
        let hideHeight = NotificationCenter.default.rx
                            .notification(NSNotification.Name.UIKeyboardWillHide)
                            .map { _ in CGFloat(0) }
        return ControlEvent(events: Observable.of(frameheight, hideHeight).merge())
    }
    
    func dismissKeyboardOnTap() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapOutside(_:)))
        view.addGestureRecognizer(tapRecognizer)
    }
    
    @objc func handleTapOutside(_ recognizer: UITapGestureRecognizer) {
        view.endEditing(true)
    }
}
