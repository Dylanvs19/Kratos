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


class RepresentativeViewController: UIViewController {
    
    let client: Client
    let viewModel: RepresentativeViewModel
    let disposeBag = DisposeBag()
    let loadStatus = Variable<LoadStatus>(.none)
    
    let topView = UIView()
    let representativeImageView = RepImageView()
    let nameLabel = UILabel()
    let repDetailsView = UIView()
    let repTypeLabel = UILabel()
    let stateLabel = UILabel()
    let partyLabel = UILabel()
    
    let contactView = RepContactView()
    
    let repInfoView: RepInfoView
    
    var topViewHeight: Constraint?
    var contactViewHeight: Constraint?
    var repInfoViewHeight: Constraint?

    let repImageViewHeight: CGFloat = 60
    
    init(client: Client, representative: Person) {
        self.client = client
        self.viewModel = RepresentativeViewModel(client: client, representative: representative)
        self.repInfoView = RepInfoView(with: client, representative: representative)
        super.init(nibName: nil, bundle: nil)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        edgesForExtendedLayout = [.top, .right, .left]
        styleViews()
        addSubviews()
        constrainViews()
        bind()
        //RepInfoView needs to be laid out and constrained after view is larger than .zero
        view.layoutIfNeeded()
        repInfoView.buildViews()
    }
}

extension RepresentativeViewController {
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

extension RepresentativeViewController: ViewBuilder {
    func addSubviews() {
        view.addSubview(topView)
        topView.addSubview(representativeImageView)
        topView.addSubview(nameLabel)
        topView.addSubview(repDetailsView)
        repDetailsView.addSubview(partyLabel)
        repDetailsView.addSubview(repTypeLabel)
        repDetailsView.addSubview(stateLabel)
        view.addSubview(contactView)
        view.addSubview(repInfoView)
    }
    func constrainViews() {
        topView.snp.remakeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            topViewHeight = make.height.equalTo(115).constraint
        }
        representativeImageView.snp.remakeConstraints { make in
            make.top.equalToSuperview().offset(40)
            make.leading.bottom.equalToSuperview().inset(15)
            make.height.width.equalTo(repImageViewHeight)
        }
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(representativeImageView.snp.top).offset(10)
            make.centerX.equalToSuperview()
        }
        repDetailsView.snp.remakeConstraints { make in
            make.centerX.equalTo(nameLabel)
            make.top.equalTo(nameLabel.snp.bottom).offset(5)
        }
        repTypeLabel.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
        }
        stateLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalTo(repTypeLabel.snp.trailing).offset(3)
        }
        partyLabel.snp.makeConstraints { make in
            make.trailing.top.bottom.equalToSuperview()
            make.leading.equalTo(stateLabel.snp.trailing).offset(3)
        }
        contactView.snp.makeConstraints { make in
            make.top.equalTo(topView.snp.bottom).offset(5)
            make.leading.trailing.equalToSuperview().inset(20)
            contactViewHeight = make.height.equalTo(35).constraint
        }
        repInfoView.snp.makeConstraints { make in
            make.top.equalTo(contactView.snp.bottom).offset(5)
            make.leading.trailing.equalToSuperview().inset(10)
            make.bottom.equalTo(view.snp.bottom).offset(-10)
        }
    }
    
    func styleViews() {
        view.style(with: .backgroundColor(.slate))
        topView.style(with: .backgroundColor(.white))
        topView.addShadow()
        
        nameLabel.style(with: .font(.title))
        repTypeLabel.style(with: [.font(.subTitle), .titleColor(.lightGray)])
        stateLabel.style(with: [.font(.subTitle), .titleColor(.lightGray)])
        partyLabel.style(with: [.font(.subTitle)])
    }
}

extension RepresentativeViewController: RxBinder {
    func bind() {
        bindTopView()
        bindContactView()
        bindRepInfoView()
    }
    
    func bindTopView() {
        viewModel.url.asObservable()
            .filterNil()
            .bind(to: self.representativeImageView.rx.setImage())
            .disposed(by: disposeBag)
        viewModel.representative.asObservable()
            .map { $0?.currentParty?.color }
            .filterNil()
            .subscribe(onNext: { [weak self] color in
                self?.partyLabel.textColor = color.value
            })
            .disposed(by: disposeBag)
        viewModel.name.asObservable()
            .bind(to: nameLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.repType.asObservable()
            .bind(to: repTypeLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.state.asObservable()
            .bind(to: stateLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.party.asObservable()
            .bind(to: partyLabel.rx.text)
            .disposed(by: disposeBag)
    }
    
    func bindContactView() {
        
        viewModel.contactMethods.asObservable()
            .subscribe(onNext: { [weak self] methods in
                self?.contactView.set(contactMethods: methods)
            })
            .disposed(by: disposeBag)
        
        viewModel.phonePressed.asObservable()
            .subscribe(onNext: { [weak self] phoneNumber in
                self?.presentPhonePrompt(with: phoneNumber)
            })
            .disposed(by: disposeBag)
        viewModel.twitterPressed.asObservable()
            .subscribe(onNext: { [weak self] handle in
                self?.presentTwitter(with: handle)
            })
            .disposed(by: disposeBag)
        viewModel.websitePressed.asObservable()
            .subscribe(onNext: { [weak self] url in
                self?.presentWebsite(with: url)
            })
            .disposed(by: disposeBag)
        viewModel.officePressed.asObservable()
            .subscribe(onNext: { [weak self] address in
                self?.presentOffice(with: address)
            })
            .disposed(by: disposeBag)
    }
    
    func bindRepInfoView() {
        repInfoView.selectedBillID
            .subscribe(onNext: { [weak self] in
                guard let client = self?.client,
                    let navVC = self?.navigationController else { return }
                let vc = BillViewController(client: client, billID: $0)
                navVC.pushViewController(vc, animated: true)
            })
            .disposed(by: disposeBag)
        
        repInfoView.contentOffset.asObservable()
            .bind(to: viewModel.contentOffset)
            .disposed(by: disposeBag)
    }
}
