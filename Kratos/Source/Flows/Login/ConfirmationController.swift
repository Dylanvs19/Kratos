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
    let viewModel: ConfirmationViewModel
    let disposeBag = DisposeBag()
    
    //UI Elements
    let kratosImageView = UIImageView(image: #imageLiteral(resourceName: "KratosLogo"))
    let titleLabel = UILabel()
    let detailLabel = UILabel()
    let textField = TextField(style: .standard,
                              type: .confirmation,
                              placeholder: localize(.textFieldConfirmationTitle))
    let resendConfirmationButton = Button(style: .b2)
    let submitButton = ActivityButton(style: .cta)
    
    var curtain: Curtain = Curtain()
    
    //Constants
    let submitButtonHeight: CGFloat = 50
    
    // MARK: - Initialization -
    init(client: Client, email: String, password: String) {
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
    func styleViews() {
        view.backgroundColor = .white
    }
    
    func addSubviews() {
        addImageView()
        addTitleLabel()
        addTextView()
        addTextField()
        addResendConfirmationButton()
        addSubmitButton()
    }
    
    private func addImageView() {
        view.addSubview(kratosImageView)

        kratosImageView.snp.makeConstraints { make in
            make.height.equalTo(kratosImageView.snp.width)
            make.height.equalTo(90)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().multipliedBy(0.3)
        }
    }
    
    private func addTitleLabel() {
        view.addSubview(titleLabel)
        titleLabel.font = .h2
        titleLabel.textColor = .gray
        titleLabel.textAlignment = .center

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(kratosImageView.snp.bottom).offset(15)
            make.leading.trailing.equalToSuperview().inset(20)
        }
    }
    
    private func addTextView() {
        view.addSubview(detailLabel)
        detailLabel.font = .bodyFont
        detailLabel.textAlignment = .center
        detailLabel.numberOfLines = 0
        
        detailLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(15)
            make.leading.trailing.equalToSuperview().inset(20)
        }
    }
    
    private func addTextField() {
        view.addSubview(textField)

        textField.snp.remakeConstraints { (make) in
            make.top.equalTo(detailLabel.snp.bottom).offset(15)
            make.centerX.equalTo(view)
        }
    }
    
    private func addResendConfirmationButton() {
        view.addSubview(resendConfirmationButton)
        resendConfirmationButton.titleLabel?.font = .bodyFont
        resendConfirmationButton.setTitleColor(.gray, for: .normal)

        resendConfirmationButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-20)
        }
    }
    
    private func addSubmitButton() {
        view.addSubview(submitButton)
        
        submitButton.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview().inset(Dimension.mediumMargin)
            make.top.greaterThanOrEqualTo(resendConfirmationButton.snp.bottom).offset(Dimension.defaultMargin)
            make.bottom.equalTo(view.snp.bottomMargin).offset(-Dimension.iPhoneXMargin)
            make.height.equalTo(Dimension.largeButtonHeight)
        }
    }
}

// MARK: - Localize -
extension ConfirmationController: Localizer {
    func localizeStrings() {
        titleLabel.text = localize(.confirmationTitle)
        resendConfirmationButton.setTitle(localize(.confirmationResendConfirmationButtonTitle), for: .normal)
        submitButton.setTitle(localize(.submit), for: .normal)
        detailLabel.text = localize(.confirmationExplainationText)
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
                let vc = NotificationsRegistrationViewController(client: Client.provider())
                self.navigationController?.pushViewController(vc, animated: true)
            }
            .disposed(by: disposeBag)
        
        viewModel.resendEmailLoadStatus
            .asObservable()
            .onSuccess { [weak self] in
               self?.presentMessageAlert(title: "Email Resent",
                                         message: "A confirmation code has been resent to your email address.",
                                         buttonOneTitle: "OK")
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
