//
//  LogInViewController.swift
//  Kratos
//
//  Created by Dylan Straughan on 9/13/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import UIKit
import SafariServices
import RxSwift
import RxCocoa
import SnapKit

class LoginController: UIViewController {
    
    // MARK: - Enums -
    enum State {
        case login
        case createAccount
        case forgotPassword
        
        var loginButtonTitle: String {
            switch self {
            case .login:
                return localize(.loginLoginButtonTitle)
            case .createAccount:
                return localize(.loginContinueButtonTitle)
            case .forgotPassword:
                return localize(.loginSendButtonTitle)
            }
        }
        var signInSignUpButtonTitle: String {
            switch self {
            case .login:
                return localize(.loginSignInButtonTitle)
            case .createAccount:
                return localize(.loginSignInButtonTitle)
            case .forgotPassword:
                return localize(.loginSignUpButtonTitle)
            }
        }
        var forgotPasswordTitle: String {
            return localize(.loginForgotPasswordButtonTitle)
        }
    }
    
    // MARK: - Variables -
    fileprivate let client: Client
    fileprivate let viewModel: LoginViewModel
    fileprivate let disposeBag = DisposeBag()
    
    fileprivate let scrollView = UIScrollView()
    fileprivate let contentView = UIView()
    
    fileprivate var kratosImageView = UIImageView(image: #imageLiteral(resourceName: "KratosLogo"))
    fileprivate var loginContinueButton = UIButton()
    fileprivate var signUpRegisterButton = UIButton()
    fileprivate var forgotPasswordButton = UIButton()
    
    fileprivate let emailTextField = KratosTextField(type: .email)
    fileprivate let passwordTextField = KratosTextField(type: .password)
    
    lazy fileprivate var fieldData: [FieldData] = {
        return [FieldData(field: self.emailTextField, fieldType: .email, viewModelVariable: self.viewModel.email, validation: self.viewModel.emailValid),
                FieldData(field: self.passwordTextField, fieldType: .password, viewModelVariable: self.viewModel.password, validation: self.viewModel.passwordValid)]
    }()
    
    var imageViewHeightConstraint: Constraint?
    var imageViewYConstraint: Constraint?
    
    // MARK: - Initialization -
    init(client: Client) {
        self.client = client
        self.viewModel = LoginViewModel(client: client)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - LifeCycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        addSubviews()
        constrainViews()
        styleViews()
        bind()
        
        navigationController?.isNavigationBarHidden = true
        setInitialState()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        beginningAnimations()
    }
    
    //MARK: - Animation -
    func setInitialState() {
        emailTextField.isHidden = true
        passwordTextField.isHidden = true
        emailTextField.animateOut()
        passwordTextField.animateOut()
        self.view.layoutIfNeeded()
    }
    
    fileprivate func beginningAnimations() {
        UIView.animate(withDuration: 0.25, delay: 0.5, options: [], animations: {
            self.emailTextField.isHidden = false
            self.passwordTextField.isHidden = false
            self.emailTextField.animateIn()
            self.passwordTextField.animateIn()
            self.animateIn()
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    fileprivate func animateIn() {
        fieldData.forEach { (data) in
            data.field.snp.remakeConstraints { (make) in
                make.top.equalTo(kratosImageView.snp.bottom).offset(data.fieldType.offsetYPosition)
                make.centerX.equalTo(view)
                make.width.equalTo(self.view.frame.width * data.fieldType.expandedWidthMultiplier)
            }
        }
    }
}

// MARK: - ViewBuilder -
extension LoginController: ViewBuilder {
    
    func addSubviews() {
        self.view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(kratosImageView)
        fieldData.forEach { (data) in
            contentView.addSubview(data.field)
        }
        contentView.addSubview(loginContinueButton)
        contentView.addSubview(signUpRegisterButton)
        contentView.addSubview(forgotPasswordButton)
    }
    
    func constrainViews() {
        scrollView.snp.makeConstraints { (make) in
            make.edges.equalTo(view)
        }
        contentView.snp.makeConstraints { (make) in
            make.edges.equalTo(view)
        }
        kratosImageView.snp.makeConstraints { make in
            make.height.equalTo(kratosImageView.snp.width)
            make.height.equalTo(150)
            make.centerX.equalTo(view)
            make.centerY.equalTo(view).multipliedBy(0.3)
        }
        fieldData.forEach { (data) in
            data.field.snp.makeConstraints { (make) in
                make.top.equalTo(kratosImageView.snp.bottom).offset(data.fieldType.offsetYPosition)
                make.centerX.equalTo(view)
                make.width.equalTo(0)
            }
        }
        loginContinueButton.snp.makeConstraints { (make) in
            make.top.equalTo(kratosImageView.snp.bottom).offset(150)
            make.centerX.equalTo(view)
        }
        signUpRegisterButton.snp.makeConstraints { (make) in
            make.bottom.equalTo(view).inset(15)
            make.trailing.equalTo(view).inset(15)
        }
        forgotPasswordButton.snp.makeConstraints { (make) in
            make.bottom.equalTo(view).inset(15)
            make.leading.equalTo(view).inset(15)
        }
    }
    
    func styleViews() {
        loginContinueButton.style(with: [.titleColor(.kratosRed), .highlightedTitleColor(.red), .font(.header), .disabledTitleColor(.lightGray)])
        signUpRegisterButton.style(with: [.titleColor(.kratosRed), .font(.body)])
        forgotPasswordButton.style(with: [.titleColor(.kratosRed), .font(.body)])
        
        signUpRegisterButton.isUserInteractionEnabled = true
        forgotPasswordButton.isUserInteractionEnabled = true
        loginContinueButton.isUserInteractionEnabled = true
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
        
        viewModel.state.asObservable()
            .map { $0 == .forgotPassword }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] (isForgotPassword) in
                UIView.animate(withDuration: 0.2, animations: { 
                    isForgotPassword ? self?.passwordTextField.animateOut() : self?.passwordTextField.animateIn()
                    self?.view.layoutIfNeeded()
                })
            })
            .disposed(by: disposeBag)
        
        viewModel.state.asObservable()
            .map { $0.signInSignUpButtonTitle }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] (title) in
                self?.signUpRegisterButton.animateTitleChange(to: title)
            })
            .disposed(by: disposeBag)
        
        viewModel.state.asObservable()
            .map { $0.loginButtonTitle }
            .subscribe(onNext: { [weak self] (title) in
                self?.loginContinueButton.animateTitleChange(to: title)
            })
            .disposed(by: disposeBag)
        
        viewModel.state.asObservable()
            .map { $0.forgotPasswordTitle }
            .bind(to: forgotPasswordButton.rx.title(for: .normal))
            .disposed(by: disposeBag)
        
        viewModel.formValid.asObservable()
            .bind(to: loginContinueButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        signUpRegisterButton.rx.tap
            .bind(to: viewModel.signInSignUpButtonTap)
            .disposed(by: disposeBag)
        
        loginContinueButton.rx.tap
            .map { _ in self.viewModel.state.value }
            .subscribe(onNext: { [weak self] state in
                switch state {
                case .login:
                    self?.viewModel.login()
                case .forgotPassword:
                    self?.viewModel.postForgotPassword()
                case .createAccount:
                    guard let `self` = self else { fatalError("self deallocated before it was accessed") }
                    if let credentials = self.viewModel.credentials.value {
                        let vc = AccountDetailsController(client: self.client, state: .create, credentials: credentials)
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            })
            .disposed(by: disposeBag)
        
        forgotPasswordButton.rx.tap
            .bind(to: viewModel.forgotPasswordButtonTap)
            .disposed(by: disposeBag)
        
        viewModel.loginLoadStatus.asObservable()
            .onSuccess { [weak self] in
                guard let `self` = self else { fatalError("self deallocated before it was accessed") }
                let vc = TabBarController(with: self.client)
                ApplicationLauncher.rootTransition(to: vc)
            }
            .disposed(by: disposeBag)
        viewModel.loginLoadStatus.asObservable()
            .onError(execute: { error in
                guard let error = error as? KratosError else { return }
                self.showError(error)
            })
            .disposed(by: disposeBag)
        viewModel.forgotPasswordLoadStatus.asObservable()
            .onSuccess {
                // Show alert here
            }
            .disposed(by: disposeBag)
        
    }
    
    func setupTextFieldBindings() {
        fieldData.forEach { (data) in
            data.field.textField.rx.text
                .map { $0 ?? "" }
                .bind(to: data.viewModelVariable)
                .disposed(by: disposeBag)
        }
        
        //Animations
        fieldData.forEach { (data) in
            data.validation.asObservable()
                .subscribe(onNext: { (valid) in
                    data.field.changeColor(for: valid)
                })
                .disposed(by: disposeBag)
        }
    }
    
    func navigationBindings() {
        viewModel.loginLoadStatus.asObservable()
            .onSuccess { [weak self] in
                guard let `self` = self else { fatalError("self deallocated before it was accessed") }
                let vc = TabBarController(with: self.client)
                ApplicationLauncher.rootTransition(to: vc)
        }
        .disposed(by: disposeBag)
        
        viewModel.loginLoadStatus.asObservable()
            .onError(execute: { error in
                // deal w error
            })
            .disposed(by: disposeBag)
        
    }
}
