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

class LoginViewController: UIViewController, ActivityIndicatorPresenter {
    
    fileprivate let client: Client
    fileprivate let viewModel: LoginViewModel
    fileprivate let disposeBag = DisposeBag()
    fileprivate let scrollView = UIScrollView()
    fileprivate let contentView = UIView()
    
    fileprivate var kratosImageView = UIImageView(image: #imageLiteral(resourceName: "Kratos"))
    fileprivate var loginContinueButton = UIButton()
    fileprivate var signUpRegisterButton = UIButton()
    fileprivate var forgotPasswordButton = UIButton()
    
    fileprivate let emailTextField = KratosTextField()
    fileprivate let passwordTextField = KratosTextField()
    
    var imageViewHeightConstraint: Constraint?
    var imageViewYConstraint: Constraint?
    
    internal var activityIndicator: KratosActivityIndicator? = KratosActivityIndicator()
    var shadeView: UIView = UIView()
    
    init(client: Client) {
        self.client = client
        viewModel = LoginViewModel(client: client)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        style()
        buildViews()
        bind()
        configureTextFields()
        
        setupGestureRecognizer()
        navigationController?.isNavigationBarHidden = true
        setInitialState()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        beginningAnimations()
    }
    
    func configureTextFields() {
        let expandedWidth = self.view.frame.width * 0.8
        emailTextField.configureWith(textlabelText: "E M A I L", expandedWidth: expandedWidth, textFieldType: .email)
        passwordTextField.configureWith(textlabelText: "P A S S W O R D", expandedWidth: expandedWidth, textFieldType: .password,  secret: true)
    }
    
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
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    func handleTapOutside(_ recognizer: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    fileprivate func setupGestureRecognizer() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(SubmitAddressViewController.handleTapOutside(_:)))
        view.addGestureRecognizer(tapRecognizer)
    }
}

extension LoginViewController: ViewBuilder {
    
    func buildViews() {
        buildScrollView()
        buildContentView()
        buildKratosImageView()
        buildKratosTextFieldViews()
        buildLoginContinueButton()
        buildSignUpRegisterButton()
        buildForgotPasswordButton()
    }
    
    func buildScrollView() {
        self.view.addSubview(scrollView)
        scrollView.snp.makeConstraints { (make) in
            make.edges.equalTo(view)
        }
    }
    func buildContentView() {
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints { (make) in
            make.edges.equalTo(view)
        }
    }
    func buildKratosImageView() {
        contentView.addSubview(kratosImageView)
        kratosImageView.snp.makeConstraints { make in
            make.height.equalTo(kratosImageView.snp.width)
            make.height.equalTo(150)
            make.centerX.equalTo(view)
            make.centerY.equalTo(view).multipliedBy(0.3)
        }
    }
    func buildKratosTextFieldViews() {
        contentView.addSubview(emailTextField)
        emailTextField.snp.makeConstraints { (make) in
            make.top.equalTo(kratosImageView.snp.bottom).offset(40)
            make.centerX.equalTo(view)
        }
        
        contentView.addSubview(passwordTextField)
        passwordTextField.snp.makeConstraints { (make) in
            make.top.equalTo(kratosImageView.snp.bottom).offset(90)
            make.centerX.equalTo(view)
        }
    }
    func buildLoginContinueButton() {
        contentView.addSubview(loginContinueButton)
        loginContinueButton.snp.makeConstraints { (make) in
            make.top.equalTo(kratosImageView.snp.bottom).offset(150)
            make.centerX.equalTo(view)
        }
    }
    func buildSignUpRegisterButton() {
        contentView.addSubview(signUpRegisterButton)
        signUpRegisterButton.snp.makeConstraints { (make) in
            make.bottom.equalTo(view).inset(15)
            make.trailing.equalTo(view).inset(15)
        }
    }
    func buildForgotPasswordButton() {
        contentView.addSubview(forgotPasswordButton)
        forgotPasswordButton.snp.makeConstraints { (make) in
            make.bottom.equalTo(view).inset(15)
            make.leading.equalTo(view).inset(15)
        }
    }
    
    func style() {
        loginContinueButton.setTitleColor(.kratosRed, for: .normal)
        loginContinueButton.setTitleColor(.red, for: .highlighted)
        loginContinueButton.setTitleColor(.lightGray, for: .disabled)
        signUpRegisterButton.setTitleColor(.lightGray, for: .normal)
        forgotPasswordButton.setTitleColor(.lightGray, for: .normal)
        
        loginContinueButton.titleLabel?.font = Font.futura(size: 24).font
        signUpRegisterButton.titleLabel?.font = Font.futura(size: 14).font
        forgotPasswordButton.titleLabel?.font = Font.futura(size: 14).font
        
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
        emailTextField.textField.rx.text
            .map { $0 ?? "" }
            .bind(to: viewModel.email)
            .disposed(by: disposeBag)
        
        passwordTextField.textField.rx.text
            .map { $0 ?? "" }
            .bind(to: viewModel.password)
            .disposed(by: disposeBag)
        
        //Animations
        Observable.combineLatest(passwordTextField.textField.rx.controlEvent([.editingDidBegin, .editingDidEnd]), viewModel.password.asObservable(), resultSelector: { (didEnd, password) -> Bool in
                !password.isEmpty
            })
            .subscribe(onNext: { [weak self] (shoudAnimateUp) in
                self?.passwordTextField.animateTextLabelPosistion(shouldAnimateUp: shoudAnimateUp)
            })
            .disposed(by: disposeBag)
        
        Observable.combineLatest(emailTextField.textField.rx.controlEvent([.editingDidBegin, .editingDidEnd]), viewModel.email.asObservable(), resultSelector: { (didEnd, email) -> Bool in
            !email.isEmpty
            })
            .subscribe(onNext: { [weak self] (shoudAnimateUp) in
                self?.emailTextField.animateTextLabelPosistion(shouldAnimateUp: shoudAnimateUp)
            })
            .disposed(by: disposeBag)
        
        viewModel.emailValid.asObservable()
            .subscribe(onNext: { [weak self] (valid) in
                self?.emailTextField.changeColor(for: valid)
            })
            .disposed(by: disposeBag)
        
        viewModel.passwordValid.asObservable()
            .subscribe(onNext: { [weak self] (valid) in
                self?.passwordTextField.changeColor(for: valid)
            })
            .disposed(by: disposeBag)
    }
    
    func navigationBindings() {
        viewModel.nextViewController.asObservable()
            .subscribe(onNext: { [weak self] vc in
                self?.navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: disposeBag)
    }
}
