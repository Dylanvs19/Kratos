//
//  MenuController.swift
//  Kratos
//
//  Created by Dylan Straughan on 3/22/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

class MenuController: UIViewController {
    
    // MARK: - Variables -
    let client: Client
    let disposeBag = DisposeBag()
    
    let kratosImageView = UIImageView(image: #imageLiteral(resourceName: "KratosLogo"))
    let accountButton = UIButton()
    let feedbackButton = UIButton()
    let logoutButton = UIButton()
    let closeButton = UIButton()
    
    var interactor:Interactor? = nil
    
    // MARK: - Intialization -
    init(client: Client) {
        self.client = client
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        addSubviews()
        constrainViews()
        styleViews()
        localizeStrings()
        setupInteractions()
    }
    
    func handleGesture(sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: view)
        
        let progress = MenuHelper.calculateProgress(translationInView: translation, viewBounds: view.bounds, direction: .Left)
        
        MenuHelper.mapGestureStateToInteractor(
            gestureState: sender.state,
            progress: progress,
            interactor: interactor) {
                self.dismiss(animated: true, completion: nil)
        }
    }
}

    // MARK: - ViewBuilder -
extension MenuController: ViewBuilder {
    
    func addSubviews() {
        view.addSubview(kratosImageView)
        view.addSubview(accountButton)
        view.addSubview(feedbackButton)
        view.addSubview(logoutButton)
        view.addSubview(closeButton)
    }
    
    func constrainViews() {
        kratosImageView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(15)
            make.height.width.equalTo(100)
        }
        feedbackButton.snp.makeConstraints { (make) in
            make.centerY.trailing.equalToSuperview().inset(20)
        }
        accountButton.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview().inset(20)
            make.bottom.equalTo(feedbackButton.snp.top).offset(-20)
        }
        logoutButton.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview().inset(20)
            make.top.equalTo(feedbackButton.snp.bottom).offset(20)
        }
        closeButton.snp.makeConstraints { (make) in
            make.top.trailing.equalToSuperview().inset(15)
        }
    }
    
    func styleViews() {
        accountButton.style(with: [.titleColor(.gray), .font(.header)])
        feedbackButton.style(with: [.titleColor(.gray), .font(.header)])
        logoutButton.style(with: [.titleColor(.gray), .font(.header)])
        closeButton.style(with: [.titleColor(.kratosRed), .font(.title)])
    }
}

// MARK: - Localize - 
extension MenuController: Localizer {
    func localizeStrings() {
        accountButton.setTitle(localize(.menuAccountDetailsButtonTitle), for: .normal)
        feedbackButton.setTitle(localize(.menuFeedbackButtonTitle), for: .normal)
        logoutButton.setTitle(localize(.menuLogoutButtonTitle), for: .normal)
        closeButton.setTitle(localize(.menuCloseButtonTitle), for: .normal)
    }
}

// MARK - Interaction Responder -
extension MenuController: InteractionResponder {
    func setupInteractions() {
        accountButton.addTarget(self, action: #selector(accountPressed), for: .touchUpInside)
        feedbackButton.addTarget(self, action: #selector(feedbackPressed), for: .touchUpInside)
        logoutButton.addTarget(self, action: #selector(logoutPressed), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(closePressed), for: .touchUpInside)
    }
    
    func accountPressed() {
        let vc = AccountDetailsController(client: self.client, state: .viewAccount)
        self.present(vc, animated: true)
    }
    
    func feedbackPressed() {
//        let vc: FeedbackViewController = FeedbackViewController.instantiate()
//        self.present(vc, animated: true, completion: nil)
    }
    
    func logoutPressed() {
        self.dismiss(animated: false) { 
            self.client.tearDown()
        }
    }
    
    func closePressed() {
        dismiss(animated: true, completion: nil)
    }
}
