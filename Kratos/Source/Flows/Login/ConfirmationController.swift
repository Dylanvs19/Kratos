//
//  ConfirmationViewController.swift
//  Kratos
//
//  Created by Dylan Straughan on 3/25/17.
//  Copyright © 2017 Kratos, Inc. All rights reserved.
//

import UIKit
import SnapKit
import RxCocoa
import RxSwift

class ConfirmationController: UIViewController, CurtainPresenter, AnalyticsEnabled {
    
    // MARK: - Properties -
    var client: Client
    let viewModel: ConfirmationViewModel
    let disposeBag = DisposeBag()
    
    //UI Elements
    let kratosImageView = UIImageView(image: #imageLiteral(resourceName: "KratosLogo"))
    let titleLabel = UILabel()
    let textView = UITextView()
    let textField = TextField(style: .confirmation,
                                          type: .confirmation,
                                          placeholder: localize(.textFieldConfirmationTitle))
    let resendConfirmationButton = UIButton()
    let submitButton = UIButton()
    
    var curtain: Curtain = Curtain()
    
    //Constants
    let submitButtonHeight: CGFloat = 50
    
    // MARK: - Initialization -
    init(client: Client, email: String, password: String) {
        self.client = client
        self.viewModel = ConfirmationViewModel(client: client, email: email, password: password)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        styleViews()
        addSubviews()
        
        constrainViews()
        bind()
        localizeStrings()
        dismissKeyboardOnTap()
        addCurtain()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setDefaultNavVC()
        log(event: .confirmationController)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        setDefaultNavVC()
    }
}

// MARK: - ViewBuilder -
extension ConfirmationController: ViewBuilder {
    func addSubviews() {
        view.addSubview(kratosImageView)
        view.addSubview(titleLabel)
        view.addSubview(textView)
        view.addSubview(textField)
        view.addSubview(resendConfirmationButton)
        view.addSubview(submitButton)
    }
    
    func constrainViews() {
        kratosImageView.snp.makeConstraints { make in
            make.height.equalTo(kratosImageView.snp.width)
            make.height.equalTo(90)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().multipliedBy(0.3)
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(kratosImageView.snp.bottom).offset(15)
            make.centerX.equalToSuperview()
        }
        self.view.layoutIfNeeded()
        textView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(15)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        self.view.layoutIfNeeded()
        textField.snp.remakeConstraints { (make) in
            make.top.equalTo(textView.snp.bottom).offset(15)
            make.centerX.equalTo(view)
            make.width.equalTo(0)
        }
        resendConfirmationButton.snp.makeConstraints { make in
            make.bottom.equalTo(submitButton.snp.top).offset(-20)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-20)
        }
        submitButton.snp.remakeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(submitButtonHeight)
        }
    }
    
    func styleViews() {
        view.style(with: .backgroundColor(.white))
        titleLabel.style(with: [.font(.title),
                                .titleColor(.gray),
                                .textAlignment(.center)])
        textView.style(with: [.font(.cellSubtitle),
                              .textAlignment(.center)])
        resendConfirmationButton.style(with: [.font(.body),
                                .titleColor(.gray)])
        submitButton.style(with: [.backgroundColor(.gray),
                                .font(.header),
                                .titleColor(.white),
                                .highlightedTitleColor(.red)])
        textView.isScrollEnabled = false
    }
}

// MARK: - Localize -
extension ConfirmationController: Localizer {
    func localizeStrings() {
        titleLabel.text = localize(.confirmationTitle)
        resendConfirmationButton.setTitle(localize(.confirmationResendConfirmationButtonTitle), for: .normal)
        submitButton.setTitle(localize(.submit), for: .normal)
        textView.text = localize(.confirmationExplainationText)
    }
}

// MARK: - Binds -
extension ConfirmationController: RxBinder {
    
    func bind() {
        textField.text
            .filterNil()
            .bind(to: viewModel.confirmation)
            .disposed(by: disposeBag)
        resendConfirmationButton.rx.tap
            .subscribe(
                onNext: { [weak self] in
                    self?.viewModel.resendCode()
                }
            )
            .disposed(by: disposeBag)
        submitButton.rx.tap
            .subscribe(
                onNext: { [unowned self] in
                    self.log(event: .confirmed)
                    self.viewModel.confirmAccount()
                }
            )
            .disposed(by: disposeBag)
        viewModel.loadStatus
            .asObservable()
            .bind(to: curtain.loadStatus)
            .disposed(by: disposeBag)
        viewModel.loadStatus
            .asObservable()
            .onError(
                execute: { [unowned self] error in
                    self.log(event: .error(KratosError.cast(from: error)))
                    self.showError(KratosError.cast(from: error))
                }
            )
            .disposed(by: disposeBag)
        viewModel.loadStatus
            .asObservable()
            .onSuccess { [unowned self] in
                let vc = NotificationsRegistrationViewController(client: self.client)
                self.navigationController?.pushViewController(vc, animated: true)
            }
            .disposed(by: disposeBag)
        viewModel.resendEmailLoadStatus
            .asObservable()
            .onSuccess { [weak self] in
               self?.presentMessageAlert(title: "Email Resent", message: "A confirmation code has been resent to your email address.", buttonOneTitle: "OK")
            }
            .disposed(by: disposeBag)
        viewModel.isValid
            .asObservable()
            .do(
                onNext: { [weak self] isEnabled in
                    let color: Color = isEnabled ? .kratosRed : .lightGray
                    self?.submitButton.style(with: .backgroundColor(color))
                }
            )
            .bind(to: self.submitButton.rx.isEnabled)
            .disposed(by: disposeBag)
    }
}
