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

    static func instantiate <ViewController: UIViewController> () -> ViewController {
        if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: String(describing: ViewController.self)) as? ViewController {
            return viewController
        }
        fatalError("\(String(describing: ViewController.self)) was not able to load")
    }
    
    func enableSwipeBack() {
        let swipeGR = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeRight(_:)))
        swipeGR.direction = .right
        view.addGestureRecognizer(swipeGR)
        view.removeBlurEffect()
    }
    
    func handleSwipeRight(_ gestureRecognizer: UIGestureRecognizer) {
        _ = navigationController?.popViewController(animated: true)
    }
    
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
    
    func presentHomeAddress(with person: Person) {
        var address = "Could not find an office address for this representative"
        if let addy = person.terms?.first?.officeAddress, person.isCurrent == true {
            address = addy
        }
        let alertVC = UIAlertController(title: "A D D R E S S", message: address, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "O K ", style: .destructive, handler: nil))
        present(alertVC, animated: true, completion: nil)
    }
    
    func showError(error: KratosError, onClose: (() -> Void)? = nil) {
        var title = "Error"
        var message = ""

        switch error {
        case .timeout:
            title = "Error"
            message = "Our server timed out. We are on it. Check back soon."
        case .invalidSerialization,
             .unknown:
            title = "Error"
            message = "Something went wrong on our end. We are on it. Check back soon."
        case .nilData:
            title = "Error"
            message = "We didn't get any data back for this. We are checking it out."
        case .invalidURL(let error),
             .duplicateUserCredentials(let error),
             .invalidCredentials(let error),
             .appSideError(let error),
             .serverSideError(let error):
            if let error = error?.first,
               let key = error.keys.first,
               let value = error[key] {
                title = key.capitalized
                message = value.lowercased().localizedCapitalized
            }
        case .nonHTTPResponse,
             .mappingError,
             .authError:
            title = "Error"
            message = "Something went wrong on our end. We are on it. Check back soon."
        }
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action) in
            onClose?()
        }))
        DispatchQueue.main.async { 
            self.present(alertVC, animated: true, completion: nil)
        }
    }
    
    func showError(_ error: KratosError) {
        showError(error: error, onClose: nil)
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
    
    func embedInNavVC() -> UINavigationController {
        let navVC = UINavigationController()
        navVC.setViewControllers([self], animated: false)
        self.configureNavVC()
        return navVC
    }
    
    func configureNavVC() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.backItem?.title = ""
        navigationController?.extendedLayoutIncludesOpaqueBars = true
        navigationController?.automaticallyAdjustsScrollViewInsets = false
    }
    
    func presentSafariView(with url: String) {
        if let url = URL(string:url) {
            let vc = SFSafariViewController(url: url)
            self.present(vc, animated: true, completion: nil)
        }
    }
}


