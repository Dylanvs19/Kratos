//
//  RepresentativeViewController.swift
//  Kratos
//
//  Created by Dylan Straughan on 6/14/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import SnapKit
import SafariServices


class RepresentativeController: UIViewController {
    
    // MARK: - Variables -
    // Standard
    let client: Client
    let viewModel: RepresentativeViewModel
    let disposeBag = DisposeBag()
    
    // topView
    let topView = UIView()
    let representativeImageView = RepImageView()
    let stateImageView = UIImageView()
    let repTypeStateLabel = UILabel()
    let partyLabel = UILabel()
    
    // RepContactView
    let contactView = RepContactView()
    
    // RepInfoView
    let repInfoView: RepInfoView

    let topMargin: CGFloat = 64
    let repImageViewHeight: CGFloat = 60
    
    // MARK: - Initializer -
    init(client: Client, representative: Person) {
        self.client = client
        self.viewModel = RepresentativeViewModel(client: client, representative: representative)
        self.repInfoView = RepInfoView(with: client, representative: representative)
        super.init(nibName: nil, bundle: nil)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        edgesForExtendedLayout = [.top, .right, .left]
        addSubviews()
        constrainViews()
        bind()
        //RepInfoView needs to be laid out and constrained after view is larger than .zero
        view.layoutIfNeeded()
        repInfoView.buildViews()
        styleViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setDefaultNavVC()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
}

// MARK: - Contact Interactions -
extension RepresentativeController {
    func presentWebsite(with websiteAddress: String) {
        guard let url = URL(string: websiteAddress) else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
        KratosAnalytics.ContactAnalyticType.website.fireEvent()
    }
    
    func presentPhonePrompt(with phone: String) {
        let filteredPhone = phone.components(separatedBy: CharacterSet.decimalDigits.inverted).joined(separator: "")
        guard let url = URL(string: "telprompt://\(filteredPhone)") else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
        KratosAnalytics.ContactAnalyticType.phone.fireEvent()
    }
    
    func presentTwitter(with handle: String) {
        
        if let url = URL(string: "twitter://user?screen_name=\(handle)"),
            UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            if let url = URL(string: "https://twitter.com/\(handle)") {
                let vc = SFSafariViewController(url: url)
                present(vc, animated: true, completion: nil)
            }
        }
        KratosAnalytics.ContactAnalyticType.twitter.fireEvent()
    }
    
    func presentOffice(with address: String) {
        let alertVC = UIAlertController(title: "A D D R E S S", message: address, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "O K ", style: .destructive, handler: nil))
        present(alertVC, animated: true, completion: nil)
        KratosAnalytics.ContactAnalyticType.officeAddress.fireEvent()
    }
}

// MARK: - View Builder -
extension RepresentativeController: ViewBuilder {
    func addSubviews() {
        view.addSubview(topView)
        topView.addSubview(representativeImageView)
        topView.addSubview(stateImageView)
        topView.addSubview(partyLabel)
        topView.addSubview(repTypeStateLabel)
        view.addSubview(contactView)
        view.addSubview(repInfoView)
    }
    func constrainViews() {
        topView.snp.remakeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(topMargin + repImageViewHeight + 20)
        }
        representativeImageView.snp.remakeConstraints { make in
            make.top.equalToSuperview().offset(topMargin + 5)
            make.leading.bottom.equalToSuperview().inset(15)
            make.height.width.equalTo(repImageViewHeight)
        }
        stateImageView.snp.remakeConstraints { make in
            make.top.equalTo(representativeImageView.snp.top)
            make.trailing.bottom.equalToSuperview().inset(15)
            make.height.width.equalTo(repImageViewHeight)
        }
        partyLabel.snp.makeConstraints { make in
            make.top.equalTo(representativeImageView.snp.top).offset(5)
            make.centerX.equalToSuperview()
        }
        repTypeStateLabel.snp.makeConstraints { make in
            make.top.equalTo(partyLabel.snp.bottom).offset(5)
            make.centerX.equalToSuperview()
        }
        contactView.snp.makeConstraints { make in
            make.top.equalTo(topView.snp.bottom).offset(5)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(35)
        }
        repInfoView.snp.makeConstraints { make in
            make.top.equalTo(contactView.snp.bottom).offset(5)
            make.leading.trailing.equalToSuperview().inset(10)
            make.bottom.equalTo(view.snp.bottom).offset(-10)
        }
    }
    
    func styleViews() {
        automaticallyAdjustsScrollViewInsets = false 
        view.clipsToBounds = false
        view.style(with: .backgroundColor(.slate))
        topView.style(with: .backgroundColor(.white))
        topView.addShadow()
        
        stateImageView.alpha = 0.2
        stateImageView.contentMode = .scaleAspectFit
        
        partyLabel.style(with: [.font(.tab)])
        repTypeStateLabel.style(with: [.font(.cellTitle),
                                       .titleColor(.lightGray)])
    }
}

// MARK: - Binds -
extension RepresentativeController: RxBinder {
    func bind() {
        bindTopView()
        bindContactView()
        bindRepInfoView()
    }
    func bindTopView() {
        viewModel.title
            .asObservable()
            .bind(to: self.rx.title)
            .disposed(by: disposeBag)
        viewModel.url
            .asObservable()
            .filterNil()
            .bind(to: self.representativeImageView.rx.setImage())
            .disposed(by: disposeBag)
        viewModel.representative
            .asObservable()
            .map { $0?.currentParty?.color }
            .filterNil()
            .subscribe(onNext: { [weak self] color in
                self?.partyLabel.textColor = color.value
            })
            .disposed(by: disposeBag)
        viewModel.repTypeState
            .asObservable()
            .bind(to: repTypeStateLabel.rx.text)
            .disposed(by: disposeBag)
        viewModel.state
            .asObservable()
            .filterNil()
            .map { $0.grayImage }
            .bind(to: stateImageView.rx.image)
            .disposed(by: disposeBag)
        viewModel.party
            .asObservable()
            .bind(to: partyLabel.rx.text)
            .disposed(by: disposeBag)
    }
    
    func bindContactView() {
        viewModel.contactMethods
            .asObservable()
            .bind(to: contactView.rx.contactMethods)
            .disposed(by: disposeBag)
        contactView.selectedMethod
            .subscribe(onNext: { [weak self] method in
                switch method {
                case .phone(let number):
                    self?.presentPhonePrompt(with: number)
                case .twitter(let handle):
                    self?.presentTwitter(with: handle)
                case .website(let url):
                    self?.presentWebsite(with: url)
                case .office(let address):
                    self?.presentOffice(with: address)
                }
            })
            .disposed(by: disposeBag)
    }
    
    func bindRepInfoView() {
        repInfoView.selectedBill
            .subscribe(onNext: { [weak self] in
                guard let client = self?.client,
                    let navVC = self?.navigationController else { return }
                let vc = BillController(client: client, bill: $0)
                navVC.pushViewController(vc, animated: true)
            })
            .disposed(by: disposeBag)
        
        repInfoView.selectedLightTally
            .subscribe(onNext: { [weak self] in
                guard let client = self?.client,
                    let navVC = self?.navigationController else { return }
                var vc = UIViewController()
                if $0.billId != nil {
                    vc = BillController(client: client, lightTally: $0)
                } else {
                    vc = TallyController(client: client, tally: $0)
                }
                navVC.pushViewController(vc, animated: true)
            })
            .disposed(by: disposeBag)
    }
}
