//
//  FeedbackQuestionView.swift
//  Kratos
//
//  Created by Dylan Straughan on 1/25/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import UIKit

class FeedbackQuestionView: UIView, Loadable, UITextViewDelegate {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        customInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        customInit()
    }

    func configure(with question: String) {
        textView.delegate = self
        textView.layer.cornerRadius = 2
        questionLabel.text = question
        textView.text = ""
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        resignFirstResponder()
        textField.endEditing(true)
        return true
    }
}
