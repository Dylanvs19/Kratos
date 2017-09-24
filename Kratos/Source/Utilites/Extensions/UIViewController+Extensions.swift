//
//  UIViewController+Extensions.swift
//  Kratos
//
//  Created by Dylan Straughan on 7/31/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//
import UIKit
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
                title = errorTitle
                message = errorMessage
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
        navigationController?.navigationBar.tintColor = Color.lightGray.value
        navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: Font.subHeader.value]
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.backItem?.title = ""
        navigationController?.extendedLayoutIncludesOpaqueBars = true
        navigationController?.automaticallyAdjustsScrollViewInsets = false
    }
}


