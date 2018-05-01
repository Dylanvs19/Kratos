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
    let textView = UITextView()
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
        localizeStrings()
        addSubviews()
        constrainViews()
        styleViews()
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        log(event: .notificationController)
    }
}

extension NotificationsRegistrationViewController: ViewBuilder {
    func addSubviews() {
        self.view.addSubview(kratosImageView)
        self.view.addSubview(titleLabel)
        self.view.addSubview(textView)
        self.view.addSubview(confirmationButton)
        self.view.addSubview(skipButton)
    }
    
    func constrainViews() {
        kratosImageView.snp.makeConstraints { make in
            make.height.equalTo(kratosImageView.snp.width)
            make.height.equalTo(90)
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
            make.width.equalToSuperview().inset(40)
        }
        confirmationButton.snp.makeConstraints { make in
            make.top.equalTo(textView.snp.bottom).offset(40)
            make.leading.trailing.equalToSuperview()
        }
        skipButton.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    func styleViews() {
        view.style(with: .backgroundColor(.white))
        titleLabel.style(with: [.font(.title),
                                .titleColor(.gray)])
        textView.style(with: [.font(.body),
                              .textAlignment(.center)])
        
        confirmationButton.style(with: [.backgroundColor(.slate),
                                        .font(.subTitle),
                                        .titleColor(.kratosRed),
                                        .highlightedTitleColor(.red)])
        skipButton.style(with: [.backgroundColor(.slate),
                                        .font(.subTitle),
                                        .titleColor(.gray),
                                        .highlightedTitleColor(.slate)])
        textView.isScrollEnabled = false

    }
}

extension NotificationsRegistrationViewController: Localizer {
    func localizeStrings() {
        skipButton.setTitle(localize(.notificationSkipButtonTitle), for: .normal)
        confirmationButton.setTitle(localize(.register), for: .normal)
        textView.text = localize(.notificationExplanationText)
        titleLabel.text = localize(.notificationTitle)
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


