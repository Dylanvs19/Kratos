//
//  RepresentativeViewController.swift
//  Kratos
//
//  Created by Dylan Straughan on 6/14/17.
//  Copyright © 2017 Kratos, Inc. All rights reserved.
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
    let repTypeStateLabel = UILabel(style: .h5lightGrey)
    let partyLabel = UILabel(style: .tab)
    
    // RepContactView
    let contactView = RepContactView()
    
    // RepInfoView
    let repInfoView: RepInfoView
    
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
        styleViews()
        addSubviews()
        bind()
        //RepInfoView needs to be laid out and constrained after view is larger than .zero
        view.layoutIfNeeded()
        repInfoView.build()
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

fileprivate extension Dimension {
    /// 60px
    static let repImageViewHeight: CGFloat = 60
}

// MARK: - View Builder -
extension RepresentativeController: ViewBuilder {
    func styleViews() {
        edgesForExtendedLayout = [.top, .right, .left]
        automaticallyAdjustsScrollViewInsets = false
        view.clipsToBounds = false
        view.backgroundColor = Color.slate.value
        
        stateImageView.alpha = 0.2
        stateImageView.contentMode = .scaleAspectFit
    }
    
    func addSubviews() {
        addTopView()
        addRepImageView()
        addStateImageView()
        addPartyLabel()
        addRepStateLabel()
        addContactView()
        addRepInfoView()
    }
    
    private func addTopView() {
        view.addSubview(topView)
        topView.backgroundColor = Color.white.value
        
        topView.snp.remakeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(Dimension.topMargin + Dimension.repImageViewHeight + 20)
        }
    }
    
    private func addRepImageView() {
        topView.addSubview(representativeImageView)

        representativeImageView.snp.remakeConstraints { make in
            make.top.equalToSuperview().offset(Dimension.topMargin + 5)
            make.leading.bottom.equalToSuperview().inset(15)
            make.height.width.equalTo(Dimension.repImageViewHeight)
        }
    }
    
    private func addStateImageView() {
        topView.addSubview(stateImageView)
        
        stateImageView.snp.remakeConstraints { make in
            make.top.equalTo(representativeImageView.snp.top)
            make.trailing.bottom.equalToSuperview().inset(15)
            make.height.width.equalTo(Dimension.repImageViewHeight)
        }
    }
    
    private func addPartyLabel() {
        topView.addSubview(partyLabel)

        partyLabel.snp.makeConstraints { make in
            make.top.equalTo(representativeImageView.snp.top).offset(5)
            make.centerX.equalToSuperview()
            make.height.equalTo(Dimension.tabButtonHeight)
        }
    }
    
    private func addRepStateLabel() {
        topView.addSubview(repTypeStateLabel)

        repTypeStateLabel.snp.makeConstraints { make in
            make.top.equalTo(partyLabel.snp.bottom).offset(5)
            make.centerX.equalToSuperview()
        }
    }
    
    private func addContactView() {
        view.addSubview(contactView)

        contactView.snp.makeConstraints { make in
            make.top.equalTo(topView.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(35)
        }
    }
    
    private func addRepInfoView() {
        view.addSubview(repInfoView)

        repInfoView.snp.makeConstraints { make in
            make.top.equalTo(contactView.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(10)
            make.bottom.equalTo(view.snp.bottom).offset(-10)
        }
    }
}


// MARK: - Binds -
extension RepresentativeController: Localizer {
    func localizeStrings() {
        if let repName = viewModel.representative.value?.fullName {
            self.title = repName
        } else if let repName = viewModel.lightRep.value?.fullName {
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
