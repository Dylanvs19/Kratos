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
    let disposeBag = DisposeBag()
    let viewModel: FeedbackViewModel
    var curtain = Curtain()
    
    let scrollView = UIScrollView()
    let stackView = UIStackView()
    let submitButton = ActivityButton(style: .cta)
    var feedbackArray: [FeedbackView] = []
    
    //MARK: - Initializer -
    init(client: FeedbackService) {
        self.viewModel = FeedbackViewModel(client: client)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        styleViews()
        addSubviews()
        view.layoutIfNeeded()
        print(view.frame.size)
        bind()
        adjustForKeyboard()
        localizeStrings()
        addCurtain()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.fetchFeedback()
    }
}

//MARK: - Localizer -
extension FeedbackController: Localizer {
    func localizeStrings() {
        title = localize(.feedback)
        submitButton.setTitle(localize(.feedbackSubmitFeedbackButtonTitle), for: .normal)
    }
}

//MARK: - ViewBuilder -
extension FeedbackController: ViewBuilder {
    func styleViews() {
        view.style(with: .backgroundColor(.white))
    }
    
    func addSubviews() {
        addScrollView()
        addStackView()
        addSubmitButton()
    }
    
    private func addScrollView() {
        view.addSubview(scrollView)

        scrollView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(Dimension.topMargin)
            make.leading.trailing.equalToSuperview().inset(Dimension.defaultMargin)
        }
    }
    
    private func addStackView() {
        scrollView.addSubview(stackView)
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        stackView.alignment = .fill
        
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func addSubmitButton() {
        view.addSubview(submitButton)

        submitButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(Dimension.mediumMargin)
            make.bottom.equalTo(view.snp.bottomMargin).offset(-Dimension.iPhoneXMargin)
            make.top.equalTo(scrollView.snp.bottom).offset(Dimension.smallMargin)
            make.height.equalTo(Dimension.largeButtonHeight)
        }
    }
}

//MARK: - Binds -
extension FeedbackController: RxBinder {
    func bind() {
        viewModel.questions
            .asObservable()
            .subscribe(
                onNext: { [unowned self] questions in
                    self.feedbackArray = questions.map {
                        let view = FeedbackView(question: $0)
                        
                        self.stackView.addArrangedSubview(view)
                        self.stackView.layoutSubviews()
                        
                        view.snp.makeConstraints { make in
                            make.width.equalTo(self.scrollView.frame.width)
                        }
                        return view
                    }
                }
            )
            .disposed(by: disposeBag)
        
        Observable.combineLatest(viewModel.fetchLoadStatus.asObservable(),
                                 viewModel.postLoadStatus.asObservable()) { $0 == .loading || $1 == .loading}
            .bind(to: submitButton.active)
            .disposed(by: disposeBag)
        
        viewModel.postLoadStatus
            .asObservable()
            .onSuccess { [unowned self] in
                self.presentMessageAlert(title: localize(.feedbackSubmittedAlertTitle),
                                    message: localize(.feedbackSubmittedAlertText),
                                    buttonOneTitle: localize(.ok),
                                    buttonTwoTitle: nil,
                                    buttonOneAction: {
                                            self.navigationController?.popViewController(animated: true)
                                    },
                                    buttonTwoAction: nil)
            }
            .disposed(by: disposeBag)
        
        viewModel.postLoadStatus
            .map { $0 == .loading }
            .bind(to: submitButton.active)
            .disposed(by: disposeBag)
        
        submitButton.rx.tap
            .map { [unowned self] in self.feedbackArray.map { $0.isAnswered ? $0.answer : nil }.compactMap { $0 }}
            .map {
                var dict = [String: String]()
                $0.forEach {
                    dict[$0.0] = $0.1
                }
                return dict
            }
            .bind(to: viewModel.answers)
            .disposed(by: disposeBag)
    }
    
    private func adjustForKeyboard() {
        keyboardHeight
            .subscribe(
                onNext: { [weak self] height in
                    guard let `self` = self else { return }
                    UIView.animate(withDuration: 0.2, animations: {
                        self.submitButton.snp.updateConstraints{ make in
                            make.bottom.equalTo(self.view.snp.bottomMargin).offset(-Dimension.iPhoneXMargin - height)
                        }
                        self.view.layoutIfNeeded()
                    })
                }
            )
            .disposed(by: disposeBag)
    }
}
