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
    let repTypeLabel = UILabel()
    let stateLabel = UILabel()
    let partyLabel = UILabel()
    
    let contactView = RepContactView()
    
    let repInfoView = RepInfoView()
    
    var topViewHeight: Constraint?
    var contactViewHeight: Constraint?
    var repInfoViewHeight: Constraint?

    
    init(client: Client, representative: Person) {
        self.client = client
        self.viewModel = RepresentativeViewModel(client: client, representative: representative)
        super.init(nibName: nil, bundle: nil)
        repInfoView.configure(with: client, representative: representative, contentOffset: viewModel.contentOffset)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        edgesForExtendedLayout = [.top, .right, .left]
        buildViews()
        style()
        bind()
        repInfoView.build()
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
    func buildViews() {
        buildTopView()
        buildContactView()
        buildRepInfoView()
        view.layoutIfNeeded()
    }
    
    func buildTopView() {
        view.addSubview(topView)
        topView.snp.remakeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            topViewHeight = make.height.equalTo(140).constraint
        }
        
        topView.addSubview(representativeImageView)
        representativeImageView.snp.remakeConstraints { make in
            make.top.equalToSuperview().offset(40)
            make.leading.equalToSuperview().offset(10)
            make.height.equalTo(80)
            make.width.equalTo(representativeImageView.snp.height)
        }
        
        topView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(representativeImageView.snp.top)
            make.leading.equalTo(representativeImageView.snp.trailing).offset(10)
        }
        
        topView.addSubview(partyLabel)
        partyLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalTo(representativeImageView.snp.centerY)
            make.leading.equalTo(representativeImageView.snp.trailing).offset(10)
        }
        
        topView.addSubview(repTypeLabel)
        repTypeLabel.snp.makeConstraints { make in
            make.bottom.equalTo(representativeImageView.snp.bottom)
            make.leading.equalTo(representativeImageView.snp.trailing).offset(10)
        }
        
        topView.addSubview(stateLabel)
        stateLabel.snp.makeConstraints { make in
            make.bottom.equalTo(representativeImageView.snp.bottom)
            make.leading.equalTo(repTypeLabel.snp.trailing).offset(3)
        }
    }
    
    func buildContactView() {
        view.addSubview(contactView)
        contactView.snp.makeConstraints { make in
            make.top.equalTo(topView.snp.bottom).offset(5)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            contactViewHeight = make.height.equalTo(35).constraint
        }
    }
    
    func buildRepInfoView() {
        view.addSubview(repInfoView)
        repInfoView.snp.makeConstraints { make in
            make.top.equalTo(contactView.snp.bottom).offset(5)
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.bottom.equalTo(view.snp.bottom).offset(-10)
        }
    }
    
    func style() {
        view.backgroundColor = .kratosLightGray
        topView.backgroundColor = .white
        topView.addShadow()
        
        nameLabel.font = Font.futuraStandard.font
        repTypeLabel.font = Font.futura(size: 12).font
        stateLabel.font = Font.futura(size: 12).font
        partyLabel.font = Font.futura(size: 12).font
        
        repTypeLabel.textColor = .lightGray
        stateLabel.textColor = .lightGray
    }
}

extension RepresentativeViewController: RxBinder {
    func bind() {
        bindTopView()
        bindContactView()
    }
    
    func bindTopView() {
        
        viewModel.representative.asObservable()
            .map { user -> (String, Chamber)? in
                guard let imageURL = user?.imageURL,
                    let currentChamber = user?.currentChamber else { return nil }
                return (imageURL, currentChamber)
            }
            .filterNil()
            .subscribe(onNext: { [weak self] (imageURL, currentChamber) in
                guard let client = self?.client else { return }
                self?.representativeImageView.loadRepImage(from: imageURL, chamber: currentChamber, with: client)
            })
            .disposed(by: disposeBag)
        
        viewModel.representative.asObservable()
            .map { $0?.currentParty?.color }
            .filterNil()
            .subscribe(onNext: { [weak self] color in
                self?.partyLabel.textColor = color
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
}
