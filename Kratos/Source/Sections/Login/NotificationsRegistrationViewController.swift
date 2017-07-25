//
//  NotificationsRegistrationViewController.swift
//  Kratos
//
//  Created by Dylan Straughan on 1/25/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import UIKit
import Firebase
import UserNotifications
import RxCocoa
import RxSwift

class NotificationsRegistrationViewController: UIViewController {

    let client: Client
    let viewModel: NotificationsRegistrationViewModel
    let disposeBag = DisposeBag()
    
    let kratosImageView = UIImageView(image: #imageLiteral(resourceName: "Kratos"))
    let titleLabel = UILabel()
    let textView = UITextView()
    let confirmationButton = UIButton()
    let skipButton = UIButton()
    
    init(client: Client) {
        self.client = client
        self.viewModel = NotificationsRegistrationViewModel(client: client)
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
    
    @IBAction func registerForNotificationsButtonPressed(_ sender: Any) {
       
        NotificationCenter.default.post(name: Notification.Name(rawValue: "toMainVC"), object: nil)
    }
    @IBAction func skipButtonPressed(_ sender: Any) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "toMainVC"), object: nil)
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
        confirmationButton.snp.makeConstraints { make in
            make.top.equalTo(textView.snp.bottom).offset(40)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().inset(-20)
        }
        skipButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().inset(-20)
        }
    }
    
    func style() {
        titleLabel.font = Font.futura(size: 17).font
        titleLabel.textColor = .gray
        
        textView.font = Font.avenirNextMedium(size: 15).font
        
        confirmationButton.backgroundColor = .kratosLightGray
        confirmationButton.titleLabel?.font = Font.futura(size: 17).font
        confirmationButton.setTitleColor(.kratosRed, for: .normal)
        confirmationButton.setTitleColor(.red, for: .highlighted)
        
        skipButton.titleLabel?.font = Font.futura(size: 17).font
        skipButton.setTitleColor(.gray, for: .normal)
        skipButton.setTitleColor(.kratosLightGray, for: .highlighted)
    }
}

extension NotificationsRegistrationViewController: RxBinder {
    
    func bind() {
        viewModel.confirmationButtonTitle.asObservable()
            .bind(to: confirmationButton.rx.title(for: .normal))
            .disposed(by: disposeBag)
        
        viewModel.skipButtonTitle.asObservable()
            .bind(to: skipButton.rx.title(for: .normal))
            .disposed(by: disposeBag)
        
        viewModel.title.asObservable()
            .bind(to: titleLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.text.asObservable()
            .bind(to: textView.rx.text)
            .disposed(by: disposeBag)
        
        confirmationButton.rx.controlEvent(.touchUpInside)
            .subscribe(onNext: { _ in
                UIApplication.shared.registerForRemoteNotifications()
                
                if #available(iOS 10.0, *) {
                    let authOptions : UNAuthorizationOptions = [.alert, .badge, .sound]
                    UNUserNotificationCenter.current().requestAuthorization(
                        options: authOptions,
                        completionHandler: {_,_ in })
                }
                
                NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.tokenRefreshNotification), name: NSNotification.Name.firInstanceIDTokenRefresh, object: nil)
                UIApplication.shared.registerForRemoteNotifications()
                
                let rootVC = UINavigationController(rootViewController: UserRepsViewController(client: self.client))
                UIApplication.shared.delegate?.rootTransition(to: rootVC)
            })
            .disposed(by: disposeBag)
        
        skipButton.rx.controlEvent(.touchUpInside)
            .subscribe(onNext: { _ in
                let rootVC = UINavigationController(rootViewController: UserRepsViewController(client: self.client))
                UIApplication.shared.delegate?.rootTransition(to: rootVC)
            })
            .disposed(by: disposeBag)
    }
}


