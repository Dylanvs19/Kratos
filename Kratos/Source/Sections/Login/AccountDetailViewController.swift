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
    
    fileprivate let firstNameTextField = KratosTextField()
    fileprivate let lastNameTextField = KratosTextField()
    fileprivate let partyTextField = KratosTextField()
    fileprivate let dobTextField = KratosTextField()
    fileprivate let streetTextField = KratosTextField()
    fileprivate let cityTextField = KratosTextField()
    fileprivate let stateTextField = KratosTextField()
    fileprivate let zipTextField = KratosTextField()
    
    fileprivate let datePicker = DatePickerView()
    fileprivate var datePickerTopConstraint: Constraint?
    
    init(client: Client, state: AccountDetailsViewModel.ViewState) {
        self.client = client
        self.viewModel = AccountDetailsViewModel(client: client, viewState: state)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = false
        style()
        buildViews()
        bind()
        configureTextFields()
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
    
    func configureTextFields() {
        firstNameTextField.configureWith(textlabelText: "F I R S T", expandedWidth: (view.frame.width * 0.35), textFieldType: .first)
        lastNameTextField.configureWith(textlabelText: "L A S T", expandedWidth: (view.frame.width * 0.35), textFieldType: .last)
        partyTextField.configureWith(textlabelText: "P A R T Y", expandedWidth: (view.frame.width * 0.35), secret: false, shouldPresentKeyboard: false)
        dobTextField.configureWith(textlabelText: "B I R T H D A Y", expandedWidth: (view.frame.width * 0.35), secret: false, shouldPresentKeyboard: false)
        streetTextField.configureWith(textlabelText: "A D D R E S S", expandedWidth: (view.frame.width * 0.8))
        cityTextField.configureWith(textlabelText: "C I T Y", expandedWidth: (view.frame.width * 0.3))
        stateTextField.configureWith(textlabelText: "S T A T E", expandedWidth: (view.frame.width * 0.16), textFieldType: .state)
        zipTextField.configureWith(textlabelText: "Z I P", expandedWidth: (view.frame.width * 0.3), textFieldType: .zip)
    }
    
    func setInitialState() {
        self.firstNameTextField.isHidden = true
        self.lastNameTextField.isHidden = true
        self.partyTextField.isHidden = true
        self.dobTextField.isHidden = true
        self.streetTextField.isHidden = true
        self.cityTextField.isHidden = true
        self.stateTextField.isHidden = true
        self.zipTextField.isHidden = true
        
        self.firstNameTextField.animateOut()
        self.lastNameTextField.animateOut()
        self.partyTextField.animateOut()
        self.dobTextField.animateOut()
        self.streetTextField.animateOut()
        self.cityTextField.animateOut()
        self.stateTextField.animateOut()
        self.zipTextField.animateOut()
        
        self.view.layoutIfNeeded()
    }
    
    fileprivate func beginningAnimations() {
        UIView.animate(withDuration: 0.25, delay: 0.5, options: [], animations: {
            self.firstNameTextField.isHidden = false
            self.lastNameTextField.isHidden = false
            self.partyTextField.isHidden = false
            self.dobTextField.isHidden = false
            self.streetTextField.isHidden = false
            self.cityTextField.isHidden = false
            self.stateTextField.isHidden = false
            self.zipTextField.isHidden = false
            
            self.firstNameTextField.animateIn()
            self.lastNameTextField.animateIn()
            self.partyTextField.animateIn()
            self.dobTextField.animateIn()
            self.streetTextField.animateIn()
            self.cityTextField.animateIn()
            self.stateTextField.animateIn()
            self.zipTextField.animateIn()
            
            self.view.layoutIfNeeded()
        }, completion: nil)
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
                make.top.equalTo(self.view.snp.bottom).offset(200)
                make.height.equalTo(200)
                make.width.equalTo(self.view).inset(20)
                make.centerX.equalTo(self.view)
            }
        }
    }
    
    func hideDatePicker() {
        UIView.animate(withDuration: 0.25) {
            self.datePicker.snp.remakeConstraints { (make) in
                make.top.equalTo(self.view.snp.bottom)
                make.height.equalTo(200)
                make.width.equalTo(self.view).inset(20)
                make.centerX.equalTo(self.view)
            }
        }
    }
}

extension AccountDetailsViewController: DatePickerViewDelegate {
    
    func selectedDate(date: Date) {
        Observable.just(DateFormatter.utcDateFormatter.string(from: date))
            .do(onNext: { [weak self] (date) in
                self?.hideDatePicker()
            })
            .bind(to: dobTextField.textField.rx.text)
            .disposed(by: disposeBag)
    }
}

extension AccountDetailsViewController: ViewBuilder {
    
    func buildViews() {
        buildScrollView()
        buildContentView()
        buildKratosImageView()
        buildKratosTextFieldViews()
        buildcancelDoneButtonButton()
        buildSaveEditRegisterButtonButton()
        buildDatePickerView()
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
        contentView.addSubview(firstNameTextField)
        firstNameTextField.snp.makeConstraints { (make) in
            make.top.equalTo(kratosImageView.snp.bottom).offset(15)
            make.centerX.equalTo(view).multipliedBy(0.5)
        }
        contentView.addSubview(lastNameTextField)
        lastNameTextField.snp.makeConstraints { (make) in
            make.top.equalTo(kratosImageView.snp.bottom).offset(15)
            make.centerX.equalTo(view).multipliedBy(1.5)
        }
        contentView.addSubview(partyTextField)
        partyTextField.snp.makeConstraints { (make) in
            make.top.equalTo(kratosImageView.snp.bottom).offset(70)
            make.centerX.equalTo(view).multipliedBy(0.5)
        }
        contentView.addSubview(dobTextField)
        dobTextField.snp.makeConstraints { (make) in
            make.top.equalTo(kratosImageView.snp.bottom).offset(70)
            make.centerX.equalTo(view).multipliedBy(1.5)
        }
        contentView.addSubview(streetTextField)
        streetTextField.snp.makeConstraints { (make) in
            make.top.equalTo(kratosImageView.snp.bottom).offset(125)
            make.centerX.equalTo(view)
        }
        contentView.addSubview(cityTextField)
        cityTextField.snp.makeConstraints { (make) in
            make.top.equalTo(kratosImageView.snp.bottom).offset(180)
            make.centerX.equalTo(view).multipliedBy(0.5)
        }
        contentView.addSubview(stateTextField)
        stateTextField.snp.makeConstraints { (make) in
            make.top.equalTo(kratosImageView.snp.bottom).offset(180)
            make.centerX.equalTo(view)
        }
        contentView.addSubview(zipTextField)
        zipTextField.snp.makeConstraints { (make) in
            make.top.equalTo(kratosImageView.snp.bottom).offset(180)
            make.centerX.equalTo(view).multipliedBy(1.5)
        }
    }
    
    func buildcancelDoneButtonButton() {
        contentView.addSubview(cancelDoneButton)
        cancelDoneButton.snp.makeConstraints { (make) in
            make.bottom.equalTo(view).inset(15)
            make.centerX.equalTo(view)
        }
    }
    
    func buildSaveEditRegisterButtonButton() {
        contentView.addSubview(saveEditRegisterButton)
        saveEditRegisterButton.snp.makeConstraints { (make) in
            make.bottom.equalTo(cancelDoneButton.snp.top).inset(15)
            make.centerX.equalTo(view)
        }
    }
    
    func buildDatePickerView() {
        view.addSubview(datePicker)
        datePicker.snp.makeConstraints { (make) in
            make.top.equalTo(view.snp.bottom)
            make.height.equalTo(200)
            make.width.equalTo(view).inset(20)
            make.centerX.equalTo(view)
        }
    }
    
    func style() {
        saveEditRegisterButton.setTitleColor(.kratosRed, for: .normal)
        saveEditRegisterButton.setTitleColor(.red, for: .highlighted)
        cancelDoneButton.setTitleColor(.lightGray, for: .normal)
        cancelDoneButton.setTitleColor(.gray, for: .highlighted)
        
        saveEditRegisterButton.titleLabel?.font = Font.futura(size: 24).font
        cancelDoneButton.titleLabel?.font = Font.futura(size: 14).font
        
        saveEditRegisterButton.isUserInteractionEnabled = true
        cancelDoneButton.isUserInteractionEnabled = true
    }
    
}

extension AccountDetailsViewController: RxBinder {
    
    func bind() {
        bindTextFields()
        bindButtons()
    }
    
    func bindTextFields() {
        
        //Build from User object
        viewModel.user.asObservable()
            .map { $0.firstName ?? ""}
            .bind(to: firstNameTextField.textField.rx.text)
            .disposed(by: disposeBag)
        viewModel.user.asObservable()
            .map { $0.lastName ?? ""}
            .bind(to: lastNameTextField.textField.rx.text)
            .disposed(by: disposeBag)
        viewModel.user.asObservable()
            .map { $0.party?.rawValue ?? ""}
            .bind(to: partyTextField.textField.rx.text)
            .disposed(by: disposeBag)
        viewModel.user.asObservable()
            .map {
                if let date = $0.dob {
                    return DateFormatter.presentationDateFormatter.string(from: date)
                }
                return ""
            }
            .bind(to: dobTextField.textField.rx.text)
            .disposed(by: disposeBag)
        viewModel.user.asObservable()
            .map { $0.address?.street ?? ""}
            .bind(to: streetTextField.textField.rx.text)
            .disposed(by: disposeBag)
        viewModel.user.asObservable()
            .map { $0.address?.city ?? ""}
            .bind(to: cityTextField.textField.rx.text)
            .disposed(by: disposeBag)
        viewModel.user.asObservable()
            .map { $0.address?.state ?? ""}
            .bind(to: stateTextField.textField.rx.text)
            .disposed(by: disposeBag)
        viewModel.user.asObservable()
            .map {
                if let zip = $0.address?.zipCode {
                    return "\(zip)"
                }
                return ""
            }
            .bind(to: zipTextField.textField.rx.text)
            .disposed(by: disposeBag)
        
        //Bind textFields text to viewModel variables 
        firstNameTextField.textField.rx.text
            .map { $0 ?? "" }
            .bind(to: viewModel.first)
            .disposed(by: disposeBag)
        lastNameTextField.textField.rx.text
            .map { $0 ?? "" }
            .bind(to: viewModel.last)
            .disposed(by: disposeBag)
        partyTextField.textField.rx.text
            .map { $0 ?? "" }
            .bind(to: viewModel.party)
            .disposed(by: disposeBag)
        dobTextField.textField.rx.text
            .map { $0 ?? "" }
            .bind(to: viewModel.dob)
            .disposed(by: disposeBag)
        streetTextField.textField.rx.text
            .map { $0 ?? "" }
            .bind(to: viewModel.street)
            .disposed(by: disposeBag)
        cityTextField.textField.rx.text
            .map { $0 ?? "" }
            .bind(to: viewModel.city)
            .disposed(by: disposeBag)
        stateTextField.textField.rx.text
            .map { $0 ?? "" }
            .bind(to: viewModel.state)
            .disposed(by: disposeBag)
        zipTextField.textField.rx.text
            .map { $0 ?? "" }
            .bind(to: viewModel.zip)
            .disposed(by: disposeBag)
        
        //Animations
        Observable.combineLatest(
            firstNameTextField.textField.rx.controlEvent([.editingDidBegin, .editingDidEnd]),
            viewModel.first.asObservable(),
            resultSelector: { (didEnd, password) -> Bool in
            !password.isEmpty
            })
            .subscribe(onNext: { [weak self] (shoudAnimateUp) in
                self?.firstNameTextField.animateTextLabelPosistion(shouldAnimateUp: shoudAnimateUp)
            })
            .disposed(by: disposeBag)
        Observable.combineLatest(
            lastNameTextField.textField.rx.controlEvent([.editingDidBegin, .editingDidEnd]),
            viewModel.last.asObservable(), resultSelector: { (didEnd, email) -> Bool in
            !email.isEmpty
            })
            .subscribe(onNext: { [weak self] (shoudAnimateUp) in
                self?.lastNameTextField.animateTextLabelPosistion(shouldAnimateUp: shoudAnimateUp)
            })
            .disposed(by: disposeBag)
        Observable.combineLatest(
            partyTextField.textField.rx.controlEvent([.editingDidBegin, .editingDidEnd]),
            viewModel.party.asObservable(), resultSelector: { (didEnd, party) -> Bool in
                !party.isEmpty
        })
            .subscribe(onNext: { [weak self] (shoudAnimateUp) in
                self?.partyTextField.animateTextLabelPosistion(shouldAnimateUp: shoudAnimateUp)
            })
            .disposed(by: disposeBag)
        Observable.combineLatest(
            dobTextField.textField.rx.controlEvent([.editingDidBegin, .editingDidEnd]),
            viewModel.dob.asObservable(), resultSelector: { (didEnd, email) -> Bool in
                !email.isEmpty
        })
            .subscribe(onNext: { [weak self] (shoudAnimateUp) in
                self?.dobTextField.animateTextLabelPosistion(shouldAnimateUp: shoudAnimateUp)
            })
            .disposed(by: disposeBag)
        Observable.combineLatest(
            streetTextField.textField.rx.controlEvent([.editingDidBegin, .editingDidEnd]),
            viewModel.street.asObservable(), resultSelector: { (didEnd, email) -> Bool in
                !email.isEmpty
        })
            .subscribe(onNext: { [weak self] (shoudAnimateUp) in
                self?.streetTextField.animateTextLabelPosistion(shouldAnimateUp: shoudAnimateUp)
            })
            .disposed(by: disposeBag)
        Observable.combineLatest(
            cityTextField.textField.rx.controlEvent([.editingDidBegin, .editingDidEnd]),
            viewModel.city.asObservable(), resultSelector: { (didEnd, email) -> Bool in
                !email.isEmpty
        })
            .subscribe(onNext: { [weak self] (shoudAnimateUp) in
                self?.cityTextField.animateTextLabelPosistion(shouldAnimateUp: shoudAnimateUp)
            })
            .disposed(by: disposeBag)
        Observable.combineLatest(
            stateTextField.textField.rx.controlEvent([.editingDidBegin, .editingDidEnd]),
            viewModel.state.asObservable(), resultSelector: { (didEnd, email) -> Bool in
                !email.isEmpty
        })
            .subscribe(onNext: { [weak self] (shoudAnimateUp) in
                self?.stateTextField.animateTextLabelPosistion(shouldAnimateUp: shoudAnimateUp)
            })
            .disposed(by: disposeBag)
        Observable.combineLatest(
            zipTextField.textField.rx.controlEvent([.editingDidBegin, .editingChanged, .editingDidEnd]),
            viewModel.zip.asObservable(), resultSelector: { (didEnd, email) -> Bool in
                !email.isEmpty
        })
            .subscribe(onNext: { [weak self] (shoudAnimateUp) in
                self?.zipTextField.animateTextLabelPosistion(shouldAnimateUp: shoudAnimateUp)
            })
            .disposed(by: disposeBag)
        
        viewModel.firstValid.asObservable()
            .subscribe(onNext: { [weak self] (valid) in
                self?.firstNameTextField.changeColor(for: valid)
            })
            .disposed(by: disposeBag)
        
        viewModel.lastValid.asObservable()
            .subscribe(onNext: { [weak self] (valid) in
                self?.lastNameTextField.changeColor(for: valid)
            })
            .disposed(by: disposeBag)
        viewModel.partyValid.asObservable()
            .subscribe(onNext: { [weak self] (valid) in
                self?.partyTextField.changeColor(for: valid)
            })
            .disposed(by: disposeBag)
        
        viewModel.dobValid.asObservable()
            .subscribe(onNext: { [weak self] (valid) in
                self?.dobTextField.changeColor(for: valid)
            })
            .disposed(by: disposeBag)
        viewModel.streetValid.asObservable()
            .subscribe(onNext: { [weak self] (valid) in
                self?.streetTextField.changeColor(for: valid)
            })
            .disposed(by: disposeBag)
        
        viewModel.cityValid.asObservable()
            .subscribe(onNext: { [weak self] (valid) in
                self?.cityTextField.changeColor(for: valid)
            })
            .disposed(by: disposeBag)
        viewModel.stateValid.asObservable()
            .subscribe(onNext: { [weak self] (valid) in
                self?.stateTextField.changeColor(for: valid)
            })
            .disposed(by: disposeBag)
        
        viewModel.zipValid.asObservable()
            .subscribe(onNext: { [weak self] (valid) in
                self?.zipTextField.changeColor(for: valid)
            })
            .disposed(by: disposeBag)
        
        //Custom Interactions
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
    
    func bindButtons() {
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
    }
    
    func navigationBinds() {
        viewModel.nextViewController.asObservable()
            .subscribe(onNext: { [weak self] vc in
                self?.navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: disposeBag)
    }
    
}
