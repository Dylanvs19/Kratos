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

fileprivate extension KratosTextField.TextfieldType {
    var expandedWidthMultiplier: CGFloat {
        switch self {
        case .first, .last, .email, .password, .address, .city, .confirmation, .search: return 0.8
        case .party, .dob, .zip, .state: return 0.35
        }
    }
    
    var centerXPosition: CGFloat {
        switch self {
        case .first, .last, .email, .password, .address, .city, .confirmation, .search: return 1
        case .party, .state: return 0.55
        case .dob, .zip: return 1.45
        }
    }
    
    var offsetYPosition: CGFloat {
        switch self {
        case .email: return 50
        case .password: return 100
        case .first: return 25
        case .last: return 80
        case .dob, .party: return 135
        case .address: return 190
        case .city: return 245
        case .state, .zip: return 300
        default:
            return 0
        }
    }
}

class AccountDetailsController: UIViewController, CurtainPresenter, AnalyticsEnabled {
    
    // MARK: - Enums -
    enum State {
        case create
        case edit
        
        var saveRegisterButtonTitle: String {
            switch self {
            case .create:
                return localize(.accountDetailsRegisterButtonTitle)
            case .edit:
                return localize(.accountDetailsSaveButtonTitle)
            }
        }
        
        var title: String {
            switch self {
            case .create:
                return "Create Account"
            case .edit:
                return "Account Details"
            }
        }
    }
    
    // MARK: - Variables -
    var client: Client
    fileprivate let viewModel: AccountDetailsViewModel
    fileprivate let disposeBag = DisposeBag()
    
    fileprivate let scrollView = UIScrollView()
    fileprivate let contentView = UIView()
    
    fileprivate var saveRegisterButton = UIButton()
    
    fileprivate let datePicker = DatePickerView()
    fileprivate let shade = UIView()
    fileprivate var datePickerTopConstraint: Constraint?
    
    fileprivate let buttonHeight: CGFloat = 50
    
    fileprivate let firstTextField = KratosTextField(type: .first)
    fileprivate let lastTextField = KratosTextField(type: .last)
    fileprivate let partyTextField = KratosTextField(type: .party)
    fileprivate let dobTextField = KratosTextField(type: .dob)
    fileprivate let streetTextField = KratosTextField(type: .address)
    fileprivate let cityTextField = KratosTextField(type: .city)
    fileprivate let stateTextField = KratosTextField(type: .state)
    fileprivate let zipTextField = KratosTextField(type: .zip)
    fileprivate let addressExplainationLabel = UILabel()
    
    lazy fileprivate var fieldData: [FieldData] = {
        return [FieldData(field: self.firstTextField, fieldType: .first, viewModelVariable: self.viewModel.first, validation: self.viewModel.firstValid),
                FieldData(field: self.lastTextField, fieldType: .last, viewModelVariable: self.viewModel.last, validation: self.viewModel.lastValid),
                FieldData(field: self.partyTextField, fieldType: .party, viewModelVariable: self.viewModel.party, validation: self.viewModel.partyValid),
                FieldData(field: self.dobTextField, fieldType: .dob, viewModelVariable: self.viewModel.dob, validation: self.viewModel.dobValid),
                FieldData(field: self.streetTextField, fieldType: .address, viewModelVariable: self.viewModel.street, validation: self.viewModel.streetValid),
                FieldData(field: self.cityTextField, fieldType: .city, viewModelVariable: self.viewModel.city, validation: self.viewModel.cityValid),
                FieldData(field: self.stateTextField, fieldType: .state, viewModelVariable: self.viewModel.userState, validation: self.viewModel.stateValid),
                FieldData(field: self.zipTextField, fieldType: .zip, viewModelVariable: self.viewModel.zip, validation: self.viewModel.zipValid)]
    }()
    
    var curtain: Curtain = Curtain()
    
    // MARK: - Initialization -
    init(client: Client, state: State, credentials: (email: String, password: String) = (email: "", password: "")) {
        self.client = client
        self.viewModel = AccountDetailsViewModel(with: client, state: state, credentials: credentials)
        super.init(nibName: nil, bundle: nil)
        self.title = state.title
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        datePicker.configureDatePicker()
        styleViews()
        addSubviews()
        constrainViews()
        localizeStrings()
        bind()
        setupGestureRecognizer()
        setInitialState()
        addCurtain()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setDefaultNavVC()
        log(event: .accountDetailsController)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        beginningAnimations()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        setDefaultNavVC()
    }
    
    // MARK - Configuration -
    func setInitialState() {
        fieldData.forEach { (data) in
            data.field.isHidden = true
            data.field.animateOut()
        }
        self.view.layoutIfNeeded()
    }
    
    // MARK - Animations -
    fileprivate func beginningAnimations() {
        UIView.animate(withDuration: 0.2, delay: 0.1, options: [], animations: {
            self.fieldData.forEach { (data) in
                data.field.isHidden = false
            }
            self.animateIn()
            self.view.layoutIfNeeded()
        }, completion: { _ in
            UIView.animate(withDuration: 0.2, delay: 0, options: [], animations: {
                self.fieldData.forEach { (data) in
                    data.field.animateIn()
                    self.view.layoutIfNeeded()
                }
            })
        })
    }
    
    fileprivate func animateIn() {
        fieldData.forEach { (data) in
            data.field.snp.remakeConstraints({ make in
                make.top.equalTo(topLayoutGuide.snp.bottom).offset(data.fieldType.offsetYPosition)
                make.centerX.equalToSuperview().multipliedBy(data.fieldType.centerXPosition)
                make.width.equalTo(self.view.frame.width * data.fieldType.expandedWidthMultiplier)
                make.height.equalTo(25)
            })
        }
    }
    
    func presentPartySelectionActionSheet() {
        let alertVC = UIAlertController.init(title: localize(.accountDetailsPartyActionSheetTitle), message: localize(.accountDetailsPartyActionSheetDescription), preferredStyle: .actionSheet)
        alertVC.addAction(UIAlertAction(title: localize(.accountDetailsDemocratButtonTitle), style: .destructive, handler: { (action) in
            if let data = self.fieldData.filter({ $0.fieldType == .party }).first {
                data.field.textFieldText(localize(.accountDetailsDemocratText))
                data.viewModelVariable.value = localize(.accountDetailsDemocratText)
            }
        }))
        alertVC.addAction(UIAlertAction(title: localize(.accountDetailsRepublicanButtonTitle), style: .destructive, handler: { (action) in
            if let data = self.fieldData.filter({ $0.fieldType == .party }).first {
                data.field.textFieldText(localize(.accountDetailsRepublicanText))
                data.viewModelVariable.value = localize(.accountDetailsRepublicanText)
            }
        }))
        alertVC.addAction(UIAlertAction(title: localize(.accountDetailsIndependentButtonTitle), style: .destructive, handler: { (action) in
            if let data = self.fieldData.filter({ $0.fieldType == .party }).first {
                data.field.textFieldText(localize(.accountDetailsIndependentText))
                data.viewModelVariable.value = localize(.accountDetailsIndependentText)
            }
        }))
        present(alertVC, animated: true, completion: nil)
    }
    
    func showDatePicker() {
        UIView.animate(withDuration: 0.25) { 
            self.datePicker.snp.remakeConstraints { (make) in
                make.bottom.equalTo(self.view.snp.bottom).inset(10)
                make.height.equalTo(250)
                make.width.equalTo(self.view).inset(20)
                make.centerX.equalTo(self.view)
            }
            self.shade.alpha = 0.3
            self.view.layoutIfNeeded()
        }
    }
    
    func hideDatePicker() {
        UIView.animate(withDuration: 0.25) {
            self.datePicker.snp.remakeConstraints { (make) in
                make.top.equalTo(self.view.snp.bottom)
                make.height.equalTo(250)
                make.width.equalTo(self.view).inset(20)
                make.centerX.equalTo(self.view)
            }
            self.shade.alpha = 0
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func handleTapOutside(_ recognizer: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    fileprivate func setupGestureRecognizer() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapOutside(_:)))
        view.addGestureRecognizer(tapRecognizer)
    }
}

// MARK: - Localizer -
extension AccountDetailsController: Localizer {
    func localizeStrings() {
        addressExplainationLabel.text = localize(.accountDetailsAddressExplanationText)
    }
}
// MARK: - ViewBuilder -
extension AccountDetailsController: ViewBuilder {
    
    func addSubviews() {
        self.view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        fieldData.forEach { (data) in
            contentView.addSubview(data.field)
        }
        contentView.addSubview(saveRegisterButton)
        view.addSubview(shade)
        view.addSubview(addressExplainationLabel)
        view.addSubview(datePicker)
    }
    
    func constrainViews() {
        scrollView.snp.remakeConstraints { (make) in
            make.edges.equalTo(view)
        }
        contentView.snp.remakeConstraints { (make) in
            make.edges.equalTo(view)
        }
        fieldData.forEach { (data) in
            data.field.snp.remakeConstraints({ make in
                make.top.equalTo(topLayoutGuide.snp.bottom).offset(data.fieldType.offsetYPosition)
                make.centerX.equalToSuperview().multipliedBy(data.fieldType.centerXPosition)
                make.width.equalTo(0)
                make.height.equalTo(25)
            })
        }
        saveRegisterButton.snp.remakeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(50)
        }
        addressExplainationLabel.snp.remakeConstraints { (make) in
            make.bottom.equalTo(saveRegisterButton.snp.top).offset(-10)
            make.leading.trailing.equalToSuperview().inset(40)
        }
        shade.snp.remakeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        datePicker.snp.remakeConstraints { (make) in
            make.top.equalTo(view.snp.bottom)
            make.height.equalTo(250)
            make.width.centerX.equalToSuperview().inset(20)
        }
    }
    
    func styleViews() {
        view.style(with: .backgroundColor(.white))
        saveRegisterButton.style(with: [.font(.header),
                                        .backgroundColor(.kratosRed),
                                        .titleColor(.white),
                                        .highlightedTitleColor(.red)])
        addressExplainationLabel.style(with: [.font(.body),
                                              .titleColor(.gray),
                                              .numberOfLines(4),
                                              .textAlignment(.center)])
        shade.style(with: .backgroundColor(.black))
        shade.alpha = 0
    }
}

// MARK: - RxBinder -
extension AccountDetailsController: RxBinder {
    
    func bind() {
        setupButtonBindings()
        setupTextfieldBindings()
        setupNavigationBindings()
        setupLoadStatusBindings()
    }
    
    func setupTextfieldBindings() {
        bindTextfieldsToUserObject()
        bindTextfieldsForAnimations()
        bindCustomTextfieldInteractions()
    }
    
    func bindTextfieldsToUserObject() {
        //Build from User object
        fieldData.forEach { (data) in
            data.field.rx.text
                .map { $0 ?? "" }
                .bind(to: data.viewModelVariable)
                .disposed(by: disposeBag)
        }
    }
    
    func setNewUserValues() {
        fieldData.forEach { (data) in
            data.field.textFieldText(data.viewModelVariable.value)
        }
    }
    
    func bindTextfieldsForAnimations() {
        fieldData.forEach { (data) in
            data.validation
                .asObservable()
                .subscribe(onNext: { (valid) in
                    data.field.changeColor(for: valid)
                })
                .disposed(by: disposeBag)
        }
    }
    
    func bindCustomTextfieldInteractions() {
        if let data = fieldData.filter({ $0.fieldType == .party }).first {
            data.field.tap
                .subscribe { [weak self] (event) in
                    self?.presentPartySelectionActionSheet()
                }
                .disposed(by: disposeBag)
        }
        
        if let data = fieldData.filter({ $0.fieldType == .dob }).first {
            data.field.tap
                .subscribe { [weak self] (event) in
                    self?.view.endEditing(true)
                    self?.showDatePicker()
                }
                .disposed(by: disposeBag)
        }
    }
    
    func setupButtonBindings() {
        viewModel.state
            .asObservable()
            .map { $0.saveRegisterButtonTitle}
            .bind(to: saveRegisterButton.rx.title(for: .normal))
            .disposed(by: disposeBag)
        viewModel.user
            .asObservable()
            .filterNil()
            .subscribe(onNext: { [weak self] _ in
                self?.setNewUserValues()
            })
            .disposed(by: disposeBag)
        saveRegisterButton.rx.tap
            .withLatestFrom(self.viewModel.state.asObservable())
            .subscribe(onNext: { [weak self] state in
                switch state {
                case .create:
                    self?.log(event: .accountDetails(.register))
                    self?.viewModel.register()
                case .edit:
                    self?.log(event: .accountDetails(.edit))
                    self?.viewModel.save()
                }
            })
            .disposed(by: disposeBag)
        viewModel.formValid
            .asObservable()
            .do(
                onNext: { [weak self] isEnabled in
                    let color: Color = isEnabled ? .kratosRed : .lightGray
                    self?.saveRegisterButton.style(with: .backgroundColor(color))
                }
            )
            .bind(to: self.saveRegisterButton.rx.isEnabled)
            .disposed(by: disposeBag)
        datePicker.selectedDate
            .asObservable()
            .map { DateFormatter.presentation.string(from: $0) }
            .do(
                onNext: { [weak self] date in
                    self?.hideDatePicker()
                    if let data = self?.fieldData.filter({ $0.fieldType == .dob }).first {
                        data.field.textFieldText(date)
                    }
                }
            )
            .bind(to: viewModel.dob)
            .disposed(by: disposeBag)
    }
    
    func setupNavigationBindings() {
        viewModel.registerLoadStatus
            .asObservable()
            .onSuccess { [weak self] in
                guard let `self` = self else { fatalError("self deallocated before it was accessed") }
                let vc = ConfirmationController(client: self.client, email: self.viewModel.email.value, password: self.viewModel.password.value)
                self.navigationController?.pushViewController(vc, animated: true)
        }
        .disposed(by: disposeBag)
    }
    
    func setupLoadStatusBindings() {
        viewModel.registerLoadStatus
            .asObservable()
            .bind(to: curtain.loadStatus)
            .disposed(by: disposeBag)
        viewModel.loadStatus
            .asObservable()
            .bind(to: curtain.loadStatus)
            .disposed(by: disposeBag)
        viewModel.loadStatus
            .asObservable()
            .onError(
                execute: { [weak self] error in
                    self?.log(event: .error(KratosError.cast(from: error)))
                    self?.showError(KratosError.cast(from: error))
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
}
