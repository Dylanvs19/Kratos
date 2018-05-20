//
//  AccountDetailViewController.swift
//  Kratos
//
//  Created by Dylan Straughan on 5/20/17.
//  Copyright © 2017 Kratos, Inc. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import SnapKit

class AccountDetailsController: UIViewController, AnalyticsEnabled {
    
    // MARK: - Enums -
    enum State {
        case create
        case edit
        
        var saveRegisterButtonTitle: String {
            switch self {
            case .create: return localize(.register)
            case .edit: return localize(.accountDetailsSaveButtonTitle)
            }
        }
    }
    
    // MARK: - Variables -
    private let viewModel: AccountDetailsViewModel
    private let disposeBag = DisposeBag()
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private var kratosImageView = UIImageView(image: #imageLiteral(resourceName: "KratosLogo"))
    private let datePicker = DatePickerView()
    private let shade = UIView()
    
    private let firstTextField = TextField(style: .standard,
                                           type: .name,
                                           placeholder: localize(.textFieldFirstTitle))
    private let lastTextField = TextField(style: .standard,
                                          type: .name,
                                          placeholder: localize(.textFieldLastTitle))
    private let partyTextField = TextField(style: .standard,
                                           type: .custom,
                                           placeholder: localize(.party))
    private let dobTextField = TextField(style: .standard,
                                         type: .custom,
                                         placeholder: localize(.birthdate))
    private let streetTextField = TextField(style: .standard,
                                            type: .text,
                                            placeholder: localize(.textFieldAddressTitle))
    private let cityTextField = TextField(style: .standard,
                                          type: .text,
                                          placeholder: localize(.textFieldCityTitle))
    private let stateTextField = TextField(style: .standard,
                                           type: .state,
                                           placeholder: localize(.textFieldStateTitle))
    private let zipTextField = TextField(style: .standard,
                                         type: .zipcode,
                                         placeholder: localize(.textFieldZipcodeTitle))
    private var gradientView = UIView()
    private var ctaButton = ActivityButton(style: .cta)
    
    // MARK: - Initialization -
    init(client: UserService & AuthService,
         state: State,
         credentials: (email: String, password: String) = (email: "", password: "")) {
        self.viewModel = AccountDetailsViewModel(with: client, state: state, credentials: credentials)
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
        datePicker.configureDatePicker()
        dismissKeyboardOnTap()
        configureGradientView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setDefaultNavVC()
        log(event: .accountDetailsController)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        setDefaultNavVC()
    }
    
    // MARK - Configuration -
    func presentPartySelectionActionSheet() {
        let alertVC = UIAlertController.init(title: localize(.party), message: localize(.accountDetailsPartyActionSheetDescription), preferredStyle: .actionSheet)
        alertVC.addAction(UIAlertAction(title: localize(.accountDetailsDemocratButtonTitle),
                                        style: .destructive,
                                        handler: { [unowned self] (action) in
                                            self.partyTextField.set(text: localize(.accountDetailsDemocratText))
                                            self.viewModel.party.value = localize(.accountDetailsDemocratText)
        }))
        alertVC.addAction(UIAlertAction(title: localize(.accountDetailsRepublicanButtonTitle),
                                        style: .destructive,
                                        handler: { [unowned self] (action) in
                                            self.partyTextField.set(text: localize(.accountDetailsRepublicanText))
                                            self.viewModel.party.value = localize(.accountDetailsRepublicanText)
        }))
        alertVC.addAction(UIAlertAction(title: localize(.accountDetailsIndependentButtonTitle),
                                        style: .destructive,
                                        handler: { (action) in
                                            self.partyTextField.set(text: localize(.accountDetailsIndependentText))
                                            self.viewModel.party.value = localize(.accountDetailsIndependentText)
        }))
        present(alertVC, animated: true, completion: nil)
    }
    
    func showDatePicker() {
        UIView.animate(withDuration: 0.25) {
            self.shade.alpha = 0.3
            self.datePicker.snp.updateConstraints {make in
                make.top.equalTo(self.view.snp.bottomMargin).offset(-260)
            }
            self.view.layoutIfNeeded()
        }
    }
    
    func hideDatePicker() {
        UIView.animate(withDuration: 0.25) {
            self.shade.alpha = 0
            self.datePicker.snp.updateConstraints {make in
                make.top.equalTo(self.view.snp.bottomMargin)
            }
            self.view.layoutIfNeeded()
        }
    }
    
    private func configureGradientView() {
        gradientView.addVerticalGradient(from: .clearWhite,
                                         bottomColor: .white,
                                         startPoint: CGPoint(x: 0.5, y: 0),
                                         endPoint: CGPoint(x: 0.5, y: 0.3))
    }
}

// MARK: - ViewBuilder -
extension AccountDetailsController: ViewBuilder {
    func styleViews() {
        view.backgroundColor = Color.white.value
        edgesForExtendedLayout = .all
        automaticallyAdjustsScrollViewInsets = false
    }
    
    func addSubviews() {
        addScrollView()
        addContentView()
        addImageView()
        addFirstNameLabel()
        addLastName()
        addPartyLabel()
        addDOBLabel()
        addStreetLabel()
        addCityLabel()
        addStateLabel()
        addZipcodeLabel()
        addShade()
        addGradient()
        addCTAButton()
        addDatePicker()
    }
    
    private func addScrollView() {
        view.addSubview(scrollView)
        
        scrollView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
    }
    
    private func addContentView() {
        scrollView.addSubview(contentView)
        
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
            make.top.equalToSuperview().inset(Dimension.largeButtonHeight)
        }
    }
    
    private func addFirstNameLabel() {
        contentView.addSubview(firstTextField)
        
        firstTextField.snp.makeConstraints { (make) in
            make.top.equalTo(kratosImageView.snp.bottom).offset(Dimension.mediumMargin)
            make.leading.trailing.equalToSuperview().inset(Dimension.mediumMargin)
        }
    }
    
    private func addLastName() {
        contentView.addSubview(lastTextField)
        
        lastTextField.snp.makeConstraints { (make) in
            make.top.equalTo(firstTextField.snp.bottom).offset(Dimension.mediumMargin)
            make.leading.trailing.equalToSuperview().inset(Dimension.mediumMargin)
        }
    }
    
    private func addPartyLabel() {
        contentView.addSubview(partyTextField)
        
        partyTextField.snp.makeConstraints { (make) in
            make.top.equalTo(lastTextField.snp.bottom).offset(Dimension.mediumMargin)
            make.leading.trailing.equalToSuperview().inset(Dimension.mediumMargin)
        }
    }
    
    private func addDOBLabel() {
        contentView.addSubview(dobTextField)
        
        dobTextField.snp.makeConstraints { (make) in
            make.top.equalTo(partyTextField.snp.bottom).offset(Dimension.mediumMargin)
            make.leading.trailing.equalToSuperview().inset(Dimension.mediumMargin)
        }
    }
    
    private func addStreetLabel() {
        contentView.addSubview(streetTextField)
        
        streetTextField.snp.makeConstraints { (make) in
            make.top.equalTo(dobTextField.snp.bottom).offset(Dimension.mediumMargin)
            make.leading.trailing.equalToSuperview().inset(Dimension.mediumMargin)
        }
    }
    
    private func addCityLabel() {
        contentView.addSubview(cityTextField)
        
        cityTextField.snp.makeConstraints { (make) in
            make.top.equalTo(streetTextField.snp.bottom).offset(Dimension.mediumMargin)
            make.leading.trailing.equalToSuperview().inset(Dimension.mediumMargin)
        }
    }
    
    private func addStateLabel() {
        contentView.addSubview(stateTextField)
        
        stateTextField.snp.makeConstraints { (make) in
            make.top.equalTo(cityTextField.snp.bottom).offset(Dimension.mediumMargin)
            make.leading.trailing.equalToSuperview().inset(Dimension.mediumMargin)
        }
    }
    
    private func addZipcodeLabel() {
        contentView.addSubview(zipTextField)
        
        zipTextField.snp.makeConstraints { (make) in
            make.top.equalTo(stateTextField.snp.bottom).offset(Dimension.mediumMargin)
            make.leading.trailing.equalToSuperview().inset(Dimension.mediumMargin)
            make.bottom.lessThanOrEqualToSuperview().inset(Dimension.largeButtonHeight)
        }
    }
    
    private func addGradient() {
        view.addSubview(gradientView)
        
        gradientView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    private func addCTAButton() {
        view.addSubview(ctaButton)
        
        ctaButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(Dimension.mediumMargin)
            make.bottom.equalTo(view.snp.bottomMargin).offset(-Dimension.iPhoneXMargin)
            make.top.equalTo(scrollView.snp.bottom).offset(-Dimension.mediumMargin)
            make.top.equalTo(gradientView.snp.top).offset(Dimension.textfieldHeight)
            make.height.equalTo(Dimension.largeButtonHeight)
        }
    }
    
    private func addShade() {
        view.addSubview(shade)
        shade.alpha = 0
        shade.backgroundColor = Color.black.value

        shade.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func addDatePicker() {
        view.addSubview(datePicker)
        
        datePicker.snp.makeConstraints { (make) in
            make.top.equalTo(view.snp.bottomMargin)
            make.height.equalTo(250)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().inset(10)
        }
    }
}

// MARK: - RxBinder -
extension AccountDetailsController: RxBinder {
    func bind() {
        setupButtonBindings()
        setupTextfieldBindings()
        setupNavigationBindings()
        setupLoadStatusBindings()
        adjustForKeyboard()
    }
    
    func setupTextfieldBindings() {
        bindTextfieldsToUserObject()
        bindCustomTextfieldInteractions()
    }
    
    func bindTextfieldsToUserObject() {
        firstTextField.text
            .map { $0 ?? "" }
            .bind(to: viewModel.first)
            .disposed(by: disposeBag)
        
        lastTextField.text
            .map { $0 ?? "" }
            .bind(to: viewModel.last)
            .disposed(by: disposeBag)
        
        partyTextField.text
            .map { $0 ?? "" }
            .bind(to: viewModel.party)
            .disposed(by: disposeBag)
        
        dobTextField.text
            .map { $0 ?? "" }
            .bind(to: viewModel.dob)
            .disposed(by: disposeBag)
        
        streetTextField.text
            .map { $0 ?? "" }
            .bind(to: viewModel.street)
            .disposed(by: disposeBag)
        
        cityTextField.text
            .map { $0 ?? "" }
            .bind(to: viewModel.city)
            .disposed(by: disposeBag)
        
        stateTextField.text
            .map { $0 ?? "" }
            .bind(to: viewModel.first)
            .disposed(by: disposeBag)
        
        zipTextField.text
            .map { $0 ?? "" }
            .bind(to: viewModel.zip)
            .disposed(by: disposeBag)
        
        firstTextField.isValid
            .bind(to: viewModel.firstValid)
            .disposed(by: disposeBag)
        
        lastTextField.isValid
            .bind(to: viewModel.lastValid)
            .disposed(by: disposeBag)
        
        partyTextField.isValid
            .bind(to: viewModel.partyValid)
            .disposed(by: disposeBag)
        
        dobTextField.isValid
            .bind(to: viewModel.dobValid)
            .disposed(by: disposeBag)
        
        streetTextField.isValid
            .bind(to: viewModel.streetValid)
            .disposed(by: disposeBag)
        
        cityTextField.isValid
            .bind(to: viewModel.cityValid)
            .disposed(by: disposeBag)
        
        stateTextField.isValid
            .bind(to: viewModel.stateValid)
            .disposed(by: disposeBag)
        
        zipTextField.isValid
            .bind(to: viewModel.zipValid)
            .disposed(by: disposeBag)
    }
    
    func setNewUserValues() {
        firstTextField.set(text: viewModel.first.value)
        lastTextField.set(text: viewModel.last.value)
        partyTextField.set(text: viewModel.party.value)
        dobTextField.set(text: viewModel.dob.value)
        streetTextField.set(text: viewModel.street.value)
        cityTextField.set(text: viewModel.city.value)
        stateTextField.set(text: viewModel.userState.value)
        zipTextField.set(text: viewModel.zip.value)
    }
    
    func bindCustomTextfieldInteractions() {
            partyTextField.tap
                .subscribe(onNext: { [unowned self] in self.presentPartySelectionActionSheet() })
                .disposed(by: disposeBag)
            dobTextField.tap
                .subscribe(onNext: { [unowned self] in self.showDatePicker() })
                .disposed(by: disposeBag)
        }
    
    func setupButtonBindings() {
        viewModel.state
            .asObservable()
            .map { $0.saveRegisterButtonTitle}
            .bind(to: ctaButton.rx.title(for: .normal))
            .disposed(by: disposeBag)
        
        viewModel.user
            .subscribe(onNext: { [unowned self] _ in self.setNewUserValues() })
            .disposed(by: disposeBag)
        
        ctaButton.rx.tap
            .withLatestFrom(self.viewModel.state.asObservable())
            .subscribe(
                onNext: { [unowned self] state in
                    switch state {
                    case .create:
                        self.log(event: .accountDetails(.register))
                        self.viewModel.register()
                    case .edit:
                        self.log(event: .accountDetails(.edit))
                        self.viewModel.save()
                    }
                }
            )
            .disposed(by: disposeBag)
        
        viewModel.formValid
            .bind(to: ctaButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        datePicker.selectedDate
            .map { DateFormatter.presentation.string(from: $0) }
            .do(
                onNext: { [unowned self] date in
                    self.hideDatePicker()
                    self.dobTextField.set(text: date)
                }
            )
            .bind(to: viewModel.dob)
            .disposed(by: disposeBag)
    }
    
    func setupNavigationBindings() {
        viewModel.registerLoadStatus
            .asObservable()
            .onSuccess { [unowned self] in
                let vc = ConfirmationController(client: Client.provider(), email: self.viewModel.email.value, password: self.viewModel.password.value)
                self.navigationController?.pushViewController(vc, animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    func setupLoadStatusBindings() {
        viewModel.loadStatus
            .asObservable()
            .onError(
                execute: { [unowned self] error in
                    self.log(event: .error(KratosError.cast(from: error)))
                    self.showError(KratosError.cast(from: error))
                }
            )
            .disposed(by: disposeBag)
        
        viewModel.registerLoadStatus
            .asObservable()
            .onError(
                execute: { [weak self] error in
                    self?.log(event: .error(KratosError.cast(from: error)))
                    self?.showError(KratosError.cast(from: error))
                }
            )
            .disposed(by: disposeBag)
    }
    
    private func adjustForKeyboard() {
        keyboardHeight
            .subscribe(
                onNext: { [weak self] height in
                    guard let `self` = self else { return }
                    UIView.animate(withDuration: 0.2, animations: {
                        self.ctaButton.snp.updateConstraints{ make in
                            make.bottom.equalTo(self.view.snp.bottomMargin).offset(-Dimension.iPhoneXMargin - height)
                        }
                        self.view.layoutIfNeeded()
                    })
                }
            )
            .disposed(by: disposeBag)
    }
}
