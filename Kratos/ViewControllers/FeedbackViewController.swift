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
    
    fileprivate var questions = [
                                    "What do you think about x?",
                                    "What do you think about y?",
                                    "What do you think about x?",
                                    "What do you think about y?"
                                ]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidHide(sender:)), name: NSNotification.Name.UIKeyboardDidHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow(sender:)),name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        scrollView.delegate = self
        setupGestureRecognizer()
        configure()
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
        // Make API Call w response Dict. 
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
