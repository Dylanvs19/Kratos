//
//  NotificationsRegistrationViewController.swift
//  Kratos
//
//  Created by Dylan Straughan on 1/25/17.
//  Copyright © 2017 Kratos, Inc. All rights reserved.
//

import UIKit
import Firebase
import UserNotifications
import RxCocoa
import RxSwift

class NotificationsRegistrationViewController: UIViewController, AnalyticsEnabled {

    var client: Client
    let disposeBag = DisposeBag()
    
    let kratosImageView = UIImageView(image: #imageLiteral(resourceName: "KratosLogo"))
    let titleLabel = UILabel()
    let detailsLabel = UILabel()
    let confirmationButton = UIButton()
    let skipButton = UIButton()
    
    init(client: Client) {
        self.client = client
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        styleViews()
        addSubviews()
        
        localizeStrings()
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        log(event: .notificationController)
    }
}

extension NotificationsRegistrationViewController: Localizer {
    func localizeStrings() {
        skipButton.setTitle(localize(.notificationSkipButtonTitle), for: .normal)
        confirmationButton.setTitle(localize(.register), for: .normal)
        detailsLabel.text = localize(.notificationExplanationText)
        titleLabel.text = localize(.notificationTitle)
    }
}

extension NotificationsRegistrationViewController: ViewBuilder {
    func styleViews() {
        view.backgroundColor = .white
    }
    
    func addSubviews() {
        addImageView()
        addTitleLabel()
        addDetailsLabel()
        addConfirmationButton()
        addSkipButton()
    }
    
    private func addImageView() {
        self.view.addSubview(kratosImageView)
        
        kratosImageView.snp.makeConstraints { make in
            make.height.equalTo(kratosImageView.snp.width)
            make.height.equalTo(90)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().multipliedBy(0.3)
        }
    }
    
    private func addTitleLabel() {
        self.view.addSubview(titleLabel)
        titleLabel.font = .h2
        titleLabel.textColor = .gray
       
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(kratosImageView.snp.bottom).offset(15)
            make.centerX.equalToSuperview()
        }
    }
    
    private func addDetailsLabel() {
        self.view.addSubview(detailsLabel)
        detailsLabel.font = .bodyFont
        detailsLabel.textAlignment = .center
        detailsLabel.numberOfLines = 0
       
        detailsLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(15)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().inset(40)
        }
    }
    
    private func addConfirmationButton() {
        self.view.addSubview(confirmationButton)
        confirmationButton.backgroundColor = .slate
        confirmationButton.titleLabel?.font = .h4
        confirmationButton.setTitleColor(.kratosRed, for: .normal)
        confirmationButton.setTitleColor(.red, for: .highlighted)
       
        confirmationButton.snp.makeConstraints { make in
            make.top.equalTo(detailsLabel.snp.bottom).offset(40)
            make.leading.trailing.equalToSuperview()
        }
    }
    
    private func addSkipButton() {
        self.view.addSubview(skipButton)
        skipButton.backgroundColor = .slate
        skipButton.titleLabel?.font = .h4
        skipButton.setTitleColor(.gray, for: .normal)
        skipButton.setTitleColor(.slate, for: .highlighted)

        skipButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().inset(Dimension.iPhoneXBottomMargin)
        }
    }
}

extension NotificationsRegistrationViewController: RxBinder {
    func bind() {
        confirmationButton.rx.controlEvent(.touchUpInside)
            .subscribe(
                onNext: { [weak self] _ in
                    guard let `self` = self else { return }
                    self.log(event: .notification(.register))
                    UIApplication.shared.registerForRemoteNotifications()
                    
                    if #available(iOS 10.0, *) {
                        let authOptions : UNAuthorizationOptions = [.alert, .badge, .sound]
                        UNUserNotificationCenter.current().requestAuthorization(
                            options: authOptions,
                            completionHandler: {_,_ in })
                    }
                    
                    UIApplication.shared.registerForRemoteNotifications()
                    
                    let rootVC = TabBarController(with: self.client)
                    ApplicationLauncher.rootTransition(to: rootVC)
                }
            )
            .disposed(by: disposeBag)
        
        skipButton.rx.controlEvent(.touchUpInside)
            .subscribe(
                onNext: { [weak self] in
                    guard let `self` = self else { return }
                    self.log(event: .notification(.skip))
                    let rootVC = TabBarController(with: self.client)
                    ApplicationLauncher.rootTransition(to: rootVC)
                }
            )
            .disposed(by: disposeBag)
    }
}


