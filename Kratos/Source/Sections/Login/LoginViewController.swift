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

class LoginViewController: UIViewController {
    
    fileprivate let client: Client
    fileprivate let viewModel: LoginViewModel
    fileprivate let disposeBag = DisposeBag()
    fileprivate let scrollView = UIScrollView()
    fileprivate let contentView = UIView()
    
    fileprivate var kratosImageView = UIImageView(image: #imageLiteral(resourceName: "Kratos"))
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
    
    init(client: Client) {
        self.client = client
        self.viewModel = LoginViewModel(client: client)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSubviews()
        constrainViews()
        style()
        bind()
        
        navigationController?.isNavigationBarHidden = true
        setInitialState()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        beginningAnimations()
    }
    
    //MARK: Animation
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

extension LoginViewController: ViewBuilder {
    
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
    
    func style() {
        loginContinueButton.style(with: [.titleColor(.kratosRed), .highlightedTitleColor(.red), .font(.header), .disabledTitleColor(.lightGray)])
        signUpRegisterButton.style(with: [.titleColor(.kratosRed), .font(.body)])
        forgotPasswordButton.style(with: [.titleColor(.kratosRed), .font(.body)])
        
        signUpRegisterButton.isUserInteractionEnabled = true
        forgotPasswordButton.isUserInteractionEnabled = true
        loginContinueButton.isUserInteractionEnabled = true
    }
}

extension LoginViewController: RxBinder {
    func bind() {
        setupButtonBindings()
        setupTextFieldBindings()
        navigationBindings()
    }
    
    func setupButtonBindings() {
        
        viewModel.viewState.asObservable()
            .map { $0 == .forgotPassword }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] (isForgotPassword) in
                UIView.animate(withDuration: 0.2, animations: { 
                    isForgotPassword ? self?.passwordTextField.animateOut() : self?.passwordTextField.animateIn()
                    self?.view.layoutIfNeeded()
                })
            })
            .disposed(by: disposeBag)
        
        viewModel.viewState.asObservable()
            .map { $0.signInSignUpButtonTitle }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] (title) in
                self?.signUpRegisterButton.animateTitleChange(to: title)
            })
            .disposed(by: disposeBag)
        
        viewModel.viewState.asObservable()
            .map { $0.loginButtonTitle }
            .subscribe(onNext: { [weak self] (title) in
                self?.loginContinueButton.animateTitleChange(to: title)
            })
            .disposed(by: disposeBag)
        
        viewModel.viewState.asObservable()
            .map { $0.forgotPasswordTitle }
            .bind(to: forgotPasswordButton.rx.title(for: .normal))
            .disposed(by: disposeBag)
        
        viewModel.formValid.asObservable()
            .subscribe(onNext: { [weak self] (valid) in
                self?.loginContinueButton.rx.base.isEnabled = valid
            })
            .disposed(by: disposeBag)
        
        signUpRegisterButton.rx.controlEvent([.touchUpInside])
            .bind(to: viewModel.signInSignUpButtonTap)
            .disposed(by: disposeBag)
        
        loginContinueButton.rx.controlEvent([.touchUpInside])
            .bind(to: viewModel.loginButtonTap)
            .disposed(by: disposeBag)
        
        forgotPasswordButton.rx.controlEvent([.touchUpInside])
            .bind(to: viewModel.forgotPasswordButtonTap)
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
        viewModel.loginSuccessful.asObservable()
            .map { $0 }
            .subscribe(onNext: { [weak self] _ in
                if let client = self?.client {
                    let vc = UINavigationController(rootViewController: TabBarController(client: client))
                    UIApplication.shared.delegate?.rootTransition(to: vc)
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.registrationContinueSuccessful.asObservable()
            .subscribe(onNext: { [weak self] credentials in
                guard let client = self?.client else { fatalError("`self` has been dealocated before it was accessed") }
                let vc = AccountDetailsViewController(client: client, accountDetails: credentials)
                self?.navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: disposeBag)
    }
}
