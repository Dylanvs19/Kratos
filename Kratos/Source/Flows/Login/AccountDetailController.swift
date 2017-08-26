//
//  AccountDetailViewController.swift
//  Kratos
//
//  Created by Dylan Straughan on 5/20/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import SnapKit

class AccountDetailsController: UIViewController {
    
    enum State {
        case createAccount
        case editAccount
        case viewAccount
        
        var saveEditRegisterButtonTitle: String {
            switch self {
            case .createAccount:
                return localize(.accountDetailsRegisterButtonTitle)
            case .editAccount:
                return localize(.accountDetailsSaveButtonTitle)
            case .viewAccount:
                return localize(.accountDetailsEditButtonTitle)
            }
        }
        
        var cancelDoneButtonTitle: String {
            switch self {
            case .createAccount:
                return ""
            case .editAccount:
                return localize(.accountDetailsCancelButtonTitle)
            case .viewAccount:
                return localize(.accountDetailsRegisterButtonTitle)
            }
        }
    }
    
    fileprivate let client: Client
    fileprivate let viewModel: AccountDetailsViewModel
    fileprivate let disposeBag = DisposeBag()
    fileprivate let scrollView = UIScrollView()
    fileprivate let contentView = UIView()
    
    fileprivate var kratosImageView = UIImageView(image: #imageLiteral(resourceName: "KratosLogo"))
    fileprivate var saveEditRegisterButton = UIButton()
    fileprivate var cancelDoneButton = UIButton()
    
    fileprivate let firstTextField = KratosTextField(type: .first)
    fileprivate let lastTextField = KratosTextField(type: .last)
    fileprivate let partyTextField = KratosTextField(type: .party)
    fileprivate let dobTextField = KratosTextField(type: .dob)
    fileprivate let streetTextField = KratosTextField(type: .address)
    fileprivate let cityTextField = KratosTextField(type: .city)
    fileprivate let stateTextField = KratosTextField(type: .state)
    fileprivate let zipTextField = KratosTextField(type: .zip)
    
    fileprivate let datePicker = DatePickerView()
    fileprivate var datePickerTopConstraint: Constraint?
    
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
    
    init(client: Client, state: State) {
        self.client = client
        self.viewModel = AccountDetailsViewModel(client: client, state: state)
        super.init(nibName: nil, bundle: nil)
    }
    
    //Initializer for registration flow
    init(client: Client, accountDetails: (email: String, password: String)) {
        self.client = client
        self.viewModel = AccountDetailsViewModel(client: client, state: .createAccount)
        super.init(nibName: nil, bundle: nil)
        viewModel.email.value = accountDetails.email
        viewModel.password.value = accountDetails.password
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = false

        datePicker.configureDatePicker()
        datePicker.delegate = self
        
        styleViews()
        addSubviews()
        constrainViews()
        bind()
        
        setupGestureRecognizer()
        setInitialState()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        beginningAnimations()
    }
    
    func setInfoFromRegistration(email: String, password: String) {
        viewModel.email.value = email
        viewModel.password.value = password
    }
    
    func setInitialState() {
        fieldData.forEach { (data) in
            data.field.isHidden = true
            data.field.animateOut()
        }
        self.view.layoutIfNeeded()
    }
    
    fileprivate func beginningAnimations() {
        UIView.animate(withDuration: 0.25, delay: 0.25, options: [], animations: {
            self.fieldData.forEach { (data) in
                data.field.isHidden = false
                data.field.animateIn()
            }
            self.animateIn()
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    fileprivate func animateIn() {
        fieldData.forEach { (data) in
            data.field.snp.remakeConstraints({ make in
                make.top.equalTo(kratosImageView.snp.bottom).offset(data.fieldType.offsetYPosition)
                make.centerX.equalTo(view).multipliedBy(data.fieldType.centerXPosition)
                make.width.equalTo(self.view.frame.width * data.fieldType.expandedWidthMultiplier)
            })
        }
    }
    
    func presentPartySelectionActionSheet() {
        let alertVC = UIAlertController.init(title: localize(.accountDetailsPartyActionSheetTitle), message: localize(.accountDetailsPartyActionSheetDescription), preferredStyle: .actionSheet)
        alertVC.addAction(UIAlertAction(title: localize(.accountDetailsDemocratButtonTitle), style: .destructive, handler: { (action) in
            self.partyTextField.setText(localize(.accountDetailsDemocratText))
        }))
        alertVC.addAction(UIAlertAction(title: localize(.accountDetailsRepublicanButtonTitle), style: .destructive, handler: { (action) in
            self.partyTextField.setText(localize(.accountDetailsRepublicanText))
        }))
        alertVC.addAction(UIAlertAction(title: localize(.accountDetailsIndependentButtonTitle), style: .destructive, handler: { (action) in
            self.partyTextField.setText(localize(.accountDetailsIndependentText))
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
            self.view.layoutIfNeeded()
        }
    }
    
    func handleTapOutside(_ recognizer: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    fileprivate func setupGestureRecognizer() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapOutside(_:)))
        view.addGestureRecognizer(tapRecognizer)
    }
}

extension AccountDetailsController: DatePickerViewDelegate {
    
    func selectedDate(date: Date) {
        Observable.just(DateFormatter.presentation.string(from: date))
            .do(onNext: { [weak self] (date) in
                self?.hideDatePicker()
            })
            .asDriver(onErrorJustReturn: "")
            .drive(onNext: { [weak self] (date) in
                self?.dobTextField.setText(date)
            })
            .disposed(by: disposeBag)
    }
}

extension AccountDetailsController: ViewBuilder {
    
    func addSubviews() {
        self.view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(kratosImageView)
        fieldData.forEach { (data) in
            contentView.addSubview(data.field)
        }
        contentView.addSubview(cancelDoneButton)
        contentView.addSubview(saveEditRegisterButton)
        view.addSubview(datePicker)
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
            data.field.snp.makeConstraints({ make in
                make.top.equalTo(kratosImageView.snp.bottom).offset(data.fieldType.offsetYPosition)
                make.centerX.equalTo(view).multipliedBy(data.fieldType.centerXPosition)
                make.width.equalTo(0)
            })
        }
        cancelDoneButton.snp.makeConstraints { (make) in
            make.bottom.equalTo(view).inset(15)
            make.centerX.equalTo(view)
        }
        saveEditRegisterButton.snp.makeConstraints { (make) in
            make.bottom.equalTo(cancelDoneButton.snp.top).inset(15)
            make.centerX.equalTo(view)
        }
        datePicker.snp.makeConstraints { (make) in
            make.top.equalTo(view.snp.bottom)
            make.height.equalTo(250)
            make.width.equalTo(view).inset(20)
            make.centerX.equalTo(view)
        }
    }
    
    func styleViews() {
        saveEditRegisterButton.style(with: [.font(.header),
                                            .titleColor(.kratosRed),
                                            .highlightedTitleColor(.red)
                                            ])
        
        cancelDoneButton.style(with: [.font(.header),
                                            .titleColor(.lightGray),
                                            .highlightedTitleColor(.gray)
                                     ])
        
        saveEditRegisterButton.isUserInteractionEnabled = true
        cancelDoneButton.isUserInteractionEnabled = true
    }
}

extension AccountDetailsController: RxBinder {
    
    func bind() {
        setupButtonBindings()
        setupTextfieldBindings()
        setupNavigationBindings()
    }
    
    func setupTextfieldBindings() {
        bindTextfieldsToUserObject()
        bindTextfieldsForAnimations()
        bindCustomTextfieldInteractions()
    }
    
    func bindTextfieldsToUserObject() {
        //Build from User object
        fieldData.forEach { (data) in
            data.field.setText(data.viewModelVariable.value)
            data.field.textField.rx.text
                .map { $0 ?? "" }
                .bind(to: data.viewModelVariable)
                .disposed(by: disposeBag)
        }
    }
    
    func bindTextfieldsForAnimations() {
        
        fieldData.forEach { (data) in
            data.validation.asObservable()
                .subscribe(onNext: { (valid) in
                    data.field.changeColor(for: valid)
                })
                .disposed(by: disposeBag)
        }
    }
    
    func bindCustomTextfieldInteractions() {
        partyTextField.textField.rx.controlEvent([.editingDidBegin])
            .subscribe { [weak self] (event) in
                self?.presentPartySelectionActionSheet()
            }
            .disposed(by: disposeBag)
        
        dobTextField.textField.rx.controlEvent([.editingDidBegin])
            .subscribe { [weak self] (event) in
                self?.showDatePicker()
            }
            .disposed(by: disposeBag)
    }
    
    func setupButtonBindings() {
        viewModel.state.asObservable()
            .map { $0.saveEditRegisterButtonTitle}
            .bind(to: saveEditRegisterButton.rx.title(for: .normal))
            .disposed(by: disposeBag)
        
        viewModel.state.asObservable()
            .map { $0.cancelDoneButtonTitle}
            .bind(to: cancelDoneButton.rx.title(for: .normal))
            .disposed(by: disposeBag)
        
        saveEditRegisterButton.rx.tap
            .withLatestFrom(self.viewModel.state.asObservable())
            .subscribe(onNext: { [weak self] state in
                switch state {
                case .createAccount:
                    self?.viewModel.register()
                case .editAccount:
                    self?.viewModel.save()
                case .viewAccount:
                    self?.dismiss(animated: true, completion: nil)
                }
            })
            .disposed(by: disposeBag)
        
        cancelDoneButton.rx.tap
            .map { _ in self.viewModel.state.value }
            .subscribe(onNext: { [weak self] state in
                switch state {
                case .createAccount:
                    break
                case .editAccount:
                    self?.viewModel.cancel()
                case .viewAccount:
                    self?.dismiss(animated: true, completion: nil)
                }
            })
            .disposed(by: disposeBag)
        
        Observable.combineLatest(
            viewModel.formValid.asObservable(),
            viewModel.state.asObservable(), resultSelector: { (valid, state) -> Bool in
                return state == .createAccount && !valid
            })
            .subscribe(onNext: { [weak self] (valid) in
                self?.saveEditRegisterButton.rx.base.isEnabled = !valid
            })
            .disposed(by: disposeBag)
    }
    
    func setupNavigationBindings() {
        viewModel.registerLoadStatus.asObservable()
            .onSuccess { [weak self] in 
                guard let `self` = self else { fatalError("self deallocated before it was accessed") }
                let vc = ConfirmationController(client: self.client)
                vc.setInfoFromRegistration(email: self.viewModel.email.value, password: self.viewModel.password.value)
                self.navigationController?.pushViewController(vc, animated: true)
        }
        .disposed(by: disposeBag)
    }
}
