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
    
    let dictionaryFormat = Variable<[String: String]>([String: String]())
    
    let questionLabel = UILabel()
    let textView = UITextView()
    var isAnswered: Bool {
        return !(textView.text.isEmpty || textView.text == "")
    }
    
    // MARK: - Initializer -
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
        constrainViews()
        styleViews()
        bind()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setQuestion(question: String) {
        questionLabel.text = question
    }
}

extension FeedbackView: ViewBuilder {
    func addSubviews() {
        addSubview(questionLabel)
        addSubview(textView)
    }
    func constrainViews() {
        questionLabel.snp.makeConstraints { make in
            make.leading.top.trailing.equalToSuperview().inset(10)
        }
        textView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview().inset(10)
            make.top.equalTo(questionLabel.snp.bottom).offset(10)
            make.height.equalTo(200)
        }
    }
    func styleViews() {
        questionLabel.style(with: [.font(.cellTitle),
                                   .numberOfLines(4)])
        textView.style(with: [.font(.body),
                              .titleColor(.gray)])
    }
}

extension FeedbackView: RxBinder {
    func bind() {
        
    }
}
