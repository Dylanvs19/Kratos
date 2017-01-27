//
//  FeedbackViewController.swift
//  Kratos
//
//  Created by Dylan Straughan on 1/25/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import UIKit

class FeedbackViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var stackView: UIStackView!
    
    fileprivate var questions = [String]() {
        didSet {
            configure()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidHide(sender:)), name: NSNotification.Name.UIKeyboardDidHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow(sender:)),name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        scrollView.delegate = self
        setupGestureRecognizer()
        loadData()
    }
    
    func loadData() {
        APIManager.getFeedback(success: { (questions) in
            self.questions = questions
        }) { (error) in
            self.showError(error)
        }
    }
    
    func configure() {
        let headerView = FeedbackHeaderView()
        stackView.addArrangedSubview(headerView)
        
        questions.forEach { (question) in
            let view = FeedbackQuestionView()
            view.configure(with: question)
            stackView.addArrangedSubview(view)
        }
        
        let view = ShowMoreView()
        view.configure(with: "Submit", actionBlock: submitTapped)
        stackView.addArrangedSubview(view)
        
        let cancelView = ShowMoreView()
        cancelView.configure(with: "Cancel", actionBlock: cancelTapped)
        stackView.addArrangedSubview(cancelView)
    }
    
    func submitTapped() {
        var responseDict = [String: String]()
        stackView.arrangedSubviews.forEach { (view) in
            if type(of: view) == FeedbackQuestionView.self {
                let view = view as! FeedbackQuestionView
                if let question = view.questionLabel.text,
                   let text = view.textView.text {
                    responseDict[question] = text
                }
            }
        }
        var send = false
        for (_, value) in responseDict where !value.isEmpty {
            send = true
        }
        if send {
        APIManager.postFeedback(with: responseDict, success: { (success) in
            self.presentMessageAlert(title: "Thank You!", message: "We have gotten your feedback! Thanks!", buttonOneTitle: "OK", buttonTwoTitle: nil, buttonOneAction: {
                self.dismiss(animated: true, completion: nil)
            }, buttonTwoAction: nil)
        }) { (error) in
            self.showError(error: error)
        }
        } else {
            self.presentMessageAlert(title: "Error", message: "It seems like all your fields are empty.", buttonOneTitle: "OK")
        }
    }
    
    func cancelTapped() {
        self.dismiss(animated: true, completion: nil)
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
    
    fileprivate func setupGestureRecognizer() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(SubmitAddressViewController.handleTapOutside(_:)))
        view.addGestureRecognizer(tapRecognizer)
    }
    
    func handleTapOutside(_ recognizer: UITapGestureRecognizer) {
        // Resign First Responder
        view.endEditing(true)
    }
}
