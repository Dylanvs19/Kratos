//
//  LogInViewController.swift
//  Kratos
//
//  Created by Dylan Straughan on 9/13/16.
//  Copyright © 2017 Kratos, Inc. All rights reserved.
//

import UIKit
import SafariServices
import RxSwift
import RxCocoa
import SnapKit

class LoginController: UIViewController, AnalyticsEnabled {
    
    // MARK: - Enums -
    enum State {
        case login
        case create
        
        var loginButtonTitle: String {
            switch self {
            case .login: return localize(.login)
            case .create: return localize(.loginContinueButtonTitle)
            }
        }
    }
    
    // MARK: - Variables -
    var client: Client
     private let viewModel: LoginViewModel
     private let disposeBag = DisposeBag()
    
     private let scrollView = UIScrollView()
     private let contentView = UIView()
    
     private var kratosImageView = UIImageView(image: #imageLiteral(resourceName: "KratosLogo"))
    
     private let emailTextField = TextField(style: .standard,
                                            type: .email,
                                            placeholder: localize(.textFieldEmailTitle))
     private let passwordTextField = TextField(style: .standard,
                                               type: .password,
                                               placeholder: localize(.textFieldPasswordTitle))
     private var forgotPasswordButton = Button(style: .b1)
     private var ctaButton = ActivityButton(style: .cta)
    
    var imageViewHeightConstraint: Constraint?
    var imageViewYConstraint: Constraint?
        
    // MARK: - Initialization -
    init(client: Client, state: State = .login) {
        self.client = client
        self.viewModel = LoginViewModel(client: client, state: state)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - LifeCycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        styleViews()
        addSubviews()
        
        bind()
        localizeStrings()
        dismissKeyboardOnTap()
        setDefaultNavVC()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        log(event: .loginController)
    }
}

// MARK: - Binds -
extension LoginController: Localizer {
    func localizeStrings() {
        forgotPasswordButton.setTitle(localize(.loginForgotPasswordButtonTitle), for: .normal)
        ctaButton.setTitle(viewModel.state.loginButtonTitle, for: .normal)
    }
}

// MARK: - ViewBuilder -
extension LoginController: ViewBuilder {
    func styleViews() {
        view.backgroundColor = Color.white.value
        edgesForExtendedLayout = .all
        automaticallyAdjustsScrollViewInsets = false
    }
    
    func addSubviews() {
        addScrollView()
        addContentView()
        addImageView()
        addEmailField()
        addPasswordField()
        addForgotPasswordButton()
        addCTAButton()
    }
    
    private func addScrollView() {
        view.addSubview(scrollView)
        
        scrollView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    private func addContentView() {
        scrollView.addSubview(contentView)
        contentView.isUserInteractionEnabled = true 
        
        contentView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
            make.width.equalTo(view.snp.width)
            make.height.greaterThanOrEqualTo(view.snp.height)
        }
    }
    
    private func addImageView() {
        contentView.addSubview(kratosImageView)
        
        kratosImageView.snp.makeConstraints { make in
            make.height.width.equalTo(Dimension.smallImageViewHeight)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().multipliedBy(0.3)
        }
    }
    
    private func addEmailField() {
        contentView.addSubview(emailTextField)
        
        emailTextField.snp.makeConstraints { (make) in
            make.top.equalTo(kratosImageView.snp.bottom).offset(Dimension.largeMargin)
            make.leading.trailing.equalToSuperview().inset(Dimension.mediumMargin)
        }
    }
    
    private func addPasswordField() {
        contentView.addSubview(passwordTextField)
        
        passwordTextField.snp.makeConstraints { (make) in
            make.top.equalTo(emailTextField.snp.bottom).offset(Dimension.defaultMargin)
            make.leading.trailing.equalToSuperview().inset(Dimension.mediumMargin)
        }
    }
    
    private func addForgotPasswordButton() {
        contentView.addSubview(forgotPasswordButton)
        forgotPasswordButton.alpha = viewModel.state == .create ? 0 : 1
        
        forgotPasswordButton.snp.makeConstraints { (make) in
            make.top.greaterThanOrEqualTo(passwordTextField.snp.bottom).offset(Dimension.defaultMargin)
            make.leading.trailing.equalToSuperview().inset(Dimension.mediumMargin)
            make.bottom.lessThanOrEqualToSuperview().inset(Dimension.largeButtonHeight)
        }
    }
    
    private func addCTAButton() {
        view.addSubview(ctaButton)
        
        ctaButton.snp.makeConstraints { (make) in            make.leading.trailing.equalToSuperview().inset(Dimension.mediumMargin)
            make.top.equalTo(forgotPasswordButton.snp.bottom).offset(Dimension.defaultMargin)
            make.bottom.equalTo(view.snp.bottomMargin).offset(-Dimension.iPhoneXMargin)
        }
    }
}

// MARK: - Binds -
extension LoginController: RxBinder {
    func bind() {
        setupButtonBindings()
        setupTextFieldBindings()
        navigationBindings()
    }
    
    func setupButtonBindings() {
        viewModel.formValid
            .bind(to: ctaButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        ctaButton.rx.tap
            .map { _ in self.viewModel.state }
            .subscribe(
                onNext: { [unowned self] state in
                    switch state {
                    case .login:
                        self.viewModel.login()
                    case .create:
                        if let credentials = self.viewModel.credentials.value {
                            let vc = AccountDetailsController(client: self.client, state: .create, credentials: credentials)
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                    }
                }
            )
            .disposed(by: disposeBag)
        
        forgotPasswordButton.rx.tap
            .subscribe(onNext: { [unowned self] in self.viewModel.postForgotPassword()})
            .disposed(by: disposeBag)
        
        viewModel.loginLoadStatus
            .onSuccess { [unowned self] in
                let vc = TabBarController(with: self.client)
                ApplicationLauncher.rootTransition(to: vc)
            }
            .disposed(by: disposeBag)
        
        viewModel.loginLoadStatus
            .onError(
                execute: { [unowned self] error in
                    self.log(event: .error(KratosError.cast(from: error)))
                    self.showError(KratosError.cast(from: error))
                }
            )
            .disposed(by: disposeBag)
        
        viewModel.forgotPasswordLoadStatus
            .onSuccess { [unowned self] in
                self.log(event: .login(.forgotPassword))
                self.presentMessageAlert(title: localize(.loginForgotPasswordAlertTitle),
                                         message: localize(.loginForgotPasswordAlertText),
                                         buttonOneTitle: localize(.ok))
            }
            .disposed(by: disposeBag)
        
        viewModel.active
            .bind(to: ctaButton.active)
            .disposed(by: disposeBag)
        
        viewModel.emailValid
            .bind(to: forgotPasswordButton.rx.isEnabled)
            .disposed(by: disposeBag)
    }
    
    func setupTextFieldBindings() {
        emailTextField.isValid
            .bind(to: viewModel.emailValid)
            .disposed(by: disposeBag)
        
        emailTextField.text
            .filterNil()
            .bind(to: viewModel.email)
            .disposed(by: disposeBag)
        
        passwordTextField.isValid
            .bind(to: viewModel.passwordValid)
            .disposed(by: disposeBag)
        
        passwordTextField.text
            .filterNil()
            .bind(to: viewModel.password)
            .disposed(by: disposeBag)
        
    }
    
    func navigationBindings() {
        viewModel.loginLoadStatus
            .onSuccess { [unowned self] in
                let vc = TabBarController(with: self.client)
                ApplicationLauncher.rootTransition(to: vc)
            }
            .disposed(by: disposeBag)
        
        viewModel.loginLoadStatus
            .onError(
                execute: { [unowned self] error in
                    let kratosError = KratosError.cast(from: error)
                    switch kratosError {
                    case .requestError(let title, _, _):
                        // Scan for Confirmation error - if one occurs, push to Confirmation VC with relevant information.
                        // Otherwise, present error.
                        if title == "unconfirmed" {
                            let vc = ConfirmationController(client: self.client, email: self.viewModel.email.value, password: self.viewModel.password.value)
                            self.navigationController?.pushViewController(vc, animated: true)
                        } else {
                            self.showError(kratosError)
                        }
                    default:
                        self.showError(kratosError)
                    }
                }
            )
            .disposed(by: disposeBag)
    }
}
