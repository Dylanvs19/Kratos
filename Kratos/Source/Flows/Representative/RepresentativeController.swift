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

class RepresentativeController: UIViewController, AnalyticsEnabled {
    
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
        self.repInfoView = RepInfoView(with: client)
        super.init(nibName: nil, bundle: nil)
    }
    
    init(client: Client, representative: LightPerson) {
        self.client = client
        self.viewModel = RepresentativeViewModel(client: client, representative: representative)
        self.repInfoView = RepInfoView(with: client)
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
        localizeStrings()
        log(event: .representativeController)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setDefaultNavVC()
    }
}

// MARK: - Contact Interactions -
extension RepresentativeController {
    func presentWebsite(with websiteAddress: String) {
        guard let url = URL(string: websiteAddress) else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
        
    }
    
    func presentPhonePrompt(with phone: String) {
        let filteredPhone = phone.components(separatedBy: CharacterSet.decimalDigits.inverted).joined(separator: "")
        guard let url = URL(string: "telprompt://\(filteredPhone)") else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
        
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
        
    }
    
    func presentOffice(with address: String) {
        let alertVC = UIAlertController(title: "A D D R E S S", message: address, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "O K ", style: .destructive, handler: nil))
        present(alertVC, animated: true, completion: nil)
       
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
            make.top.equalTo(topView.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(35)
        }
        repInfoView.snp.makeConstraints { make in
            make.top.equalTo(contactView.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(10)
            make.bottom.equalTo(view.snp.bottom)
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
extension RepresentativeController: Localizer {
    func localizeStrings() {
        if let repName = viewModel.representative.value?.fullName {
            self.title = repName
        }
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
        viewModel.representative
            .asObservable()
            .filterNil()
            .subscribe(
                onNext: { [weak self] rep in
                    self?.repInfoView.update(with: rep)
                }
            )
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
            .bind(to: contactView.contactMethods)
            .disposed(by: disposeBag)
        contactView.selectedMethod
            .subscribe(onNext: { [weak self] method in
                guard let `self` = self,
                      let rep = self.viewModel.representative.value else { return}
                self.viewModel.logContactEvent(contact: method, personId: rep.id)
                switch method.method {
                case .phone:
                    self.presentPhonePrompt(with: method.value)
                case .twitter:
                    self.presentTwitter(with: method.value)
                case .website:
                    self.presentWebsite(with: method.value)
                case .office:
                    self.presentOffice(with: method.value)
                }
            })
            .disposed(by: disposeBag)
    }
    
    func bindRepInfoView() {
        repInfoView.selectedBill
            .subscribe(
                onNext: { [weak self] in
                    guard let `self` = self else { return }
                    self.log(event: .representative(.billSelected(id: $0.id)))
                    let vc = BillController(client: self.client, bill: $0)
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            )
            .disposed(by: disposeBag)
        
        repInfoView.selectedLightTally
            .subscribe(
                onNext: { [weak self] in
                    guard let `self` = self else { return }
                    var vc = UIViewController()
                    if let id = $0.billId {
                        self.log(event: .representative(.billSelected(id: id)))
                        vc = BillController(client: self.client, lightTally: $0)
                    } else {
                        self.log(event: .representative(.tallySelected(id: $0.id)))
                        vc = TallyController(client: self.client, tally: $0)
                    }
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            )
            .disposed(by: disposeBag)
        repInfoView.selectedState
            .subscribe(
                onNext: { [weak self] state in
                    self?.log(event: .representative(.tabSelected(state)))
                }
            )
            .disposed(by: disposeBag)
    }
}
