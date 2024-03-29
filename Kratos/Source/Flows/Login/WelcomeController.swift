//
//  WelcomeController.swift
//  Kratos
//
//  Created by Dylan Straughan on 4/17/18.
//  Copyright © 2018 Dylan Straughan. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

class WelcomeController: UIViewController {
    // MARK: - `properties` -
    let disposeBag = DisposeBag()
    
    let imageView = UIImageView(image: #imageLiteral(resourceName: "KratosLogo"))
    let titleLabel = UILabel(style: .h1)
    let createAccountButton = Button(style: .b1)
    let signInButton = Button(style: .cta)

    // MARK: - `lifecycle` -
    override func viewDidLoad() {
        super.viewDidLoad()
        
        styleViews()
        addSubviews()
        
        bind()
        localizeStrings()
    }
}

// MARK: - `localizer` -
extension WelcomeController: Localizer {
    func localizeStrings() {
        titleLabel.text = localize(.kratos)
        createAccountButton.setTitle(localize(.welcomeCreateButtonTitle), for: .normal)
        signInButton.setTitle(localize(.login), for: .normal)
    }
}

// MARK: - `viewBuilder` -
extension WelcomeController: ViewBuilder {
    func styleViews() {
        setDefaultNavVC()
    }
    
    func addSubviews() {
        addImageView()
        addTitle()
        addCreateAccountButton()
        addSignInButton()
    }
    
    private func addImageView() {
        view.addSubview(imageView)
        
        imageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.width.equalTo(Dimension.largeImageViewHeight)
        }
    }
    private func addTitle() {
        view.addSubview(titleLabel)
        titleLabel.textAlignment = .center
        
        titleLabel.snp.makeConstraints { make in
            make.centerY.centerX.equalToSuperview()
            make.top.equalTo(imageView.snp.bottom).offset(Dimension.largeMargin)
        }
    }
    private func addCreateAccountButton() {
        view.addSubview(createAccountButton)
        
        createAccountButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(Dimension.mediumMargin)
        }
    }
    private func addSignInButton() {
        view.addSubview(signInButton)
        
        signInButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(Dimension.mediumMargin)
            make.top.equalTo(createAccountButton.snp.bottom).offset(Dimension.defaultMargin)
            make.bottom.equalTo(view.snp.bottomMargin).offset(-Dimension.iPhoneXMargin)
            make.height.equalTo(Dimension.largeButtonHeight)
        }
    }
}

// MARK: - `rxBinder` -
extension WelcomeController: RxBinder {
    func bind() {
        createAccountButton.rx.tap
            .subscribe(
                onNext: { [unowned self] in
                    let vc = LoginController(client: Client.provider(), state: .create)
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            )
            .disposed(by: disposeBag)
        
        signInButton.rx.tap
            .subscribe(
                onNext: { [unowned self] in
                    let vc = LoginController(client: Client.provider(), state: .login)
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            )
            .disposed(by: disposeBag)
    }
}
