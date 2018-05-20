//
//  FeedbackView.swift
//  Kratos
//
//  Created by Dylan Straughan on 10/14/17.
//  Copyright © 2017 Kratos, Inc. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import SnapKit

class FeedbackView: UIView {
    // MARK: - Variables -
    let disposeBag = DisposeBag()
    
    let question: String
    let questionLabel = UILabel(style: .h3)
    let textView = UITextView()
    var isAnswered: Bool {
        return !(textView.text.isEmpty || textView.text == "")
    }
    var answer: (String, String) {
        return ((question), (textView.text ?? ""))
    }
    
    // MARK: - Initializer -
    init(question: String) {
        self.question = question
        super.init(frame: .zero)
        
        styleViews()
        addSubviews()
        localizeStrings()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension FeedbackView: Localizer {
    func localizeStrings() {
        questionLabel.text = question
    }
}

extension FeedbackView: ViewBuilder {
    func styleViews() {}
    
    func addSubviews() {
        addQuestionLabel()
        addTextView()
    }
    
    private func addQuestionLabel() {
        addSubview(questionLabel)
        questionLabel.textAlignment = .center
        questionLabel.setContentHuggingPriority(.required, for: .vertical)
        questionLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        
        questionLabel.snp.makeConstraints { make in
            make.leading.top.trailing.equalToSuperview()
            make.height.equalTo(30)
        }
    }
    
    private func addTextView() {
        addSubview(textView)
        textView.layer.borderColor = UIColor.slate.cgColor
        textView.layer.borderWidth = 2
        textView.textColor = Color.black.value
        textView.font = Font.body.value

        textView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(questionLabel.snp.bottom).offset(10)
            make.height.equalTo(200)
            make.bottom.equalToSuperview()
        }
    }
}

