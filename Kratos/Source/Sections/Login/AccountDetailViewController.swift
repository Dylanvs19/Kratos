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

class AccountDetailsViewController: UIViewController {
    
    fileprivate let client: Client
    fileprivate let viewModel: AccountDetailsViewModel
    fileprivate let disposeBag = DisposeBag()
    fileprivate let scrollView = UIScrollView()
    fileprivate let contentView = UIView()
    
    fileprivate var kratosImageView = UIImageView(image: #imageLiteral(resourceName: "Kratos"))
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
                FieldData(field: self.stateTextField, fieldType: .state, viewModelVariable: self.viewModel.state, validation: self.viewModel.stateValid),
                FieldData(field: self.zipTextField, fieldType: .zip, viewModelVariable: self.viewModel.zip, validation: self.viewModel.zipValid)]
    }()
    
    init(client: Client, state: AccountDetailsViewModel.ViewState) {
        self.client = client
        self.viewModel = AccountDetailsViewModel(client: client, viewState: state)
        super.init(nibName: nil, bundle: nil)
    }
    
    //Initializer for registration flow
    init(client: Client, accountDetails: (email: String, password: String)) {
        self.client = client
        self.viewModel = AccountDetailsViewModel(client: client, viewState: .registration)
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
        
        style()
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
        let alertVC = UIAlertController.init(title: "P A R T Y", message: "Choose your party affiliation", preferredStyle: .actionSheet)
        alertVC.addAction(UIAlertAction(title: "D E M O C R A T", style: .destructive, handler: { (action) in
            self.partyTextField.setText("Democrat")
        }))
        alertVC.addAction(UIAlertAction(title: "R E P U B L I C A N", style: .destructive, handler: { (action) in
            self.partyTextField.setText("Republican")
        }))
        alertVC.addAction(UIAlertAction(title: "I N D E P E N D E N T", style: .destructive, handler: { (action) in
            self.partyTextField.setText("Independent")
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

extension AccountDetailsViewController: DatePickerViewDelegate {
    
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

extension AccountDetailsViewController: ViewBuilder {
    
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
    
    func style() {
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

extension AccountDetailsViewController: RxBinder {
    
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
        viewModel.viewState.asObservable()
            .map { $0.saveEditRegisterButtonTitle}
            .bind(to: saveEditRegisterButton.rx.title(for: .normal))
            .disposed(by: disposeBag)
        
        viewModel.viewState.asObservable()
            .map { $0.cancelDoneButtonTitle}
            .bind(to: cancelDoneButton.rx.title(for: .normal))
            .disposed(by: disposeBag)
        
        saveEditRegisterButton.rx.controlEvent([.touchUpInside])
            .bind(to: viewModel.saveEditRegisterButtonTap)
            .disposed(by: disposeBag)
        
        cancelDoneButton.rx.controlEvent([.touchUpInside])
            .bind(to: viewModel.cancelDoneButtonTap)
            .disposed(by: disposeBag)
        
        Observable.combineLatest(
            viewModel.formValid.asObservable(),
            viewModel.viewState.asObservable(), resultSelector: { (valid, state) -> Bool in
                return state == .registration && !valid
            })
            .subscribe(onNext: { [weak self] (valid) in
                self?.saveEditRegisterButton.rx.base.isEnabled = !valid
            })
            .disposed(by: disposeBag)
    }
    
    func setupNavigationBindings() {
        viewModel.push.asObservable()
            .filter { $0 == true }
            .subscribe(onNext: { [weak self] vc in
                guard let s = self else { fatalError("self deallocated before it was accessed") }
                let vc = ConfirmationViewController(client: s.client)
                vc.setInfoFromRegistration(email: s.viewModel.email.value, password: s.viewModel.password.value)
                s.navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: disposeBag)
    }
}
