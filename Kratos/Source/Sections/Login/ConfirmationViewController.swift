//
//  ConfirmationViewController.swift
//  Kratos
//
//  Created by Dylan Straughan on 3/25/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import UIKit
import SnapKit
import RxCocoa
import RxSwift

class ConfirmationViewController: UIViewController {
    
    let client: Client
    let viewModel: ConfirmationViewModel
    let disposeBag = DisposeBag()
    
    //UI Elements
    let kratosImageView = UIImageView(image: #imageLiteral(resourceName: "Kratos"))
    let titleLabel = UILabel()
    let textView = UITextView()
    let linkButton = UIButton()
    
    init(client: Client) {
        self.client = client
        self.viewModel = ConfirmationViewModel(client: client)
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
    }
    
    func setInfoFromRegistration(email: String, password: String) {
        viewModel.email.value = email
        viewModel.password.value = password
    }
}

extension ConfirmationViewController: ViewBuilder {
    func addSubviews() {
        self.view.addSubview(kratosImageView)
        self.view.addSubview(titleLabel)
        self.view.addSubview(textView)
        self.view.addSubview(linkButton)
    }
    
    func constrainViews() {
        kratosImageView.snp.makeConstraints { make in
            make.height.equalTo(kratosImageView.snp.width)
            make.height.equalTo(150)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().multipliedBy(0.3)
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(kratosImageView.snp.bottom).offset(15)
            make.centerX.equalToSuperview()
        }
        textView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(15)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().inset(-20)
        }
        linkButton.snp.makeConstraints { make in
            make.top.equalTo(textView.snp.bottom).offset(40)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-20)
        }
    }
    
    func style() {
        titleLabel.font = Font.futura(size: 17).font
        titleLabel.textColor = .gray
        
        textView.font = Font.avenirNextMedium(size: 15).font
        
        linkButton.backgroundColor = .kratosLightGray
        linkButton.titleLabel?.font = Font.futura(size: 17).font
        linkButton.setTitleColor(.kratosRed, for: .normal)
        linkButton.setTitleColor(.red, for: .highlighted)
    }
}

extension ConfirmationViewController: RxBinder {
    
    func bind() {
        viewModel.buttonTitle.asObservable()
            .bind(to: linkButton.rx.title(for: .normal))
            .disposed(by: disposeBag)
        
        viewModel.title.asObservable()
            .bind(to: titleLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.text.asObservable()
            .bind(to: textView.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.push.asObservable()
            .subscribe(onNext: { [weak self] in
                guard let s = self else { fatalError("self deallocated before it was accessed") }
                let vc = NotificationsRegistrationViewController(client: s.client)
                s.navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: disposeBag)
        
        linkButton.rx.controlEvent(.touchUpInside)
            .bind(to: viewModel.confirmationPressed)
            .disposed(by: disposeBag)
    }
    
    
}
