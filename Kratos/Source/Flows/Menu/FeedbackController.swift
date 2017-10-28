//
//  FeedbackController.swift
//  Kratos
//
//  Created by Dylan Straughan on 9/28/17.
//  Copyright © 2017 Kratos, Inc. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class FeedbackController: UIViewController, CurtainPresenter {
    //MARK: - Variables -
    let client: Client
    let disposeBag = DisposeBag()
    let viewModel: FeedbackViewModel
    var curtain = Curtain()
    
    let scrollView = UIScrollView()
    let contentView = UIView()
    let submitButton = UIButton()
    
    //MARK: - Initializer -
    init(client: Client) {
        self.client = client
        self.viewModel = FeedbackViewModel(client: client)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavVC()
        localizeStrings()
        addSubviews()
        constrainViews()
        styleViews()
        addCurtain()
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.fetchFeedback()
    }
    
    //MARK: - Configuration -
    func configureNavVC() {
        
    }
}

//MARK: - Localizer -
extension FeedbackController: Localizer {
    func localizeStrings() {
        title = "Feedback"
    }
}

//MARK: - ViewBuilder -
extension FeedbackController: ViewBuilder {
    func addSubviews() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        view.addSubview(submitButton)
    }
    func constrainViews() {
        submitButton.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(50)
        }
        scrollView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(submitButton.snp.top)
        }
    }
    func styleViews() {
        view.style(with: .backgroundColor(.white))
    }
}

//MARK: - Binds -
extension FeedbackController: RxBinder {
    func bind() {
        viewModel.questions
            .asObservable()
            .subscribe(
                onNext: { [weak self] questions in
                    print(questions)
                    guard let `self` = self else { return }
                    var lastView: UIView = self.view
                    for (i, question) in questions.enumerated() {
                        let view = FeedbackView()
                        view.setQuestion(question: question)
                        self.contentView.addSubview(view)
                        view.snp.makeConstraints { make in
                            make.leading.trailing.equalToSuperview()
                            if i == 0 {
                                make.top.equalToSuperview()
                            } else if i == (questions.count - 1) {
                                make.top.equalTo(lastView.snp.bottom).offset(1)
                                make.bottom.equalToSuperview()
                            } else {
                                make.top.equalTo(lastView.snp.bottom).offset(1)
                            }
                        }
                        lastView = view
                    }
                    self.scrollView.layoutIfNeeded()
                }
            )
            .disposed(by: disposeBag)
    }
}
