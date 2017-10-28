//
//  BillViewController.swift
//  Kratos
//
//  Created by Dylan Straughan on 7/12/17.
//  Copyright © 2017 Kratos, Inc. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class BillController: UIViewController, AnalyticsEnabled {
    
    // MARK: - Properties - 
    // Standard
    let client: Client
    let viewModel: BillViewModel
    let disposeBag = DisposeBag()
    let loadStatus = Variable<LoadStatus>(.none)

    // UIElements
    //Header
    let billHeader = UIView()
    let titleLabel = UILabel()
    let divider = UIView()
    let statusLabel = UILabel()
    let statusDateLabel = UILabel()
    let trackButton = UIButton()
    //BillInfo
    let billInfoView = BillInfoView()
    //Constants
    let voteViewExpandedSize: CGFloat = 40
    
    // MARK: - Initialization -
    init(client: Client, lightTally: LightTally) {
        self.client = client
        self.viewModel = BillViewModel(with: client, lightTally: lightTally)
        super.init(nibName: nil, bundle: nil)
    }
    
    init(client: Client, bill: Bill) {
        self.client = client
        self.viewModel = BillViewModel(with: client, bill: bill)
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
        view.layoutIfNeeded()
        styleViews()
        bind()
        //RepInfoView needs to be laid out and constrained after view is larger than .zero
        billInfoView.build()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setDefaultNavVC()
        self.title = ""
        trackButton.addShadow()
        billHeader.addShadow()
        log(event: .billController)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setDefaultNavVC()
    }
    
    // MARK: - Animations -
    func updateTrackButton(for isTracking: Bool, animate: Bool) {
        let title = isTracking ? localize(.billTrackButtonTrackedTitle) : localize(.billTrackButtonUntrackedTitle)
        let color = isTracking ? Color.kratosBlue.value : Color.kratosGreen.value
        if animate {
        UIView.animate(withDuration: 0.3) {
            self.trackButton.setTitle(title, for: .normal)
            self.trackButton.backgroundColor = color
            self.trackButton.layoutIfNeeded()
            self.view.layoutIfNeeded()
        }
        } else {
            self.trackButton.setTitle(title, for: .normal)
            self.trackButton.backgroundColor = color
            self.trackButton.layoutIfNeeded()
            self.view.layoutIfNeeded()
        }
    }
}

// MARK: - View Builder -
extension BillController: ViewBuilder {
    func addSubviews() {
        view.addSubview(billHeader)
        billHeader.addSubview(titleLabel)
        billHeader.addSubview(divider)
        billHeader.addSubview(statusLabel)
        billHeader.addSubview(statusDateLabel)
        billHeader.addSubview(trackButton)
        view.addSubview(billInfoView)
    }
    func constrainViews() {
        billHeader.snp.remakeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        titleLabel.snp.remakeConstraints { make in
            make.top.equalToSuperview().inset(25)
            make.leading.trailing.equalToSuperview().inset(40)
        }
        divider.snp.remakeConstraints { make in
            make.trailing.leading.equalToSuperview().inset(20)
            make.top.equalTo(self.titleLabel.snp.bottom).offset(5)
            make.height.equalTo(1)
        }
        trackButton.snp.remakeConstraints { make in
            make.top.equalTo(divider.snp.bottom).offset(10)
            make.trailing.bottom.equalToSuperview().inset(10)
        }
        statusLabel.snp.remakeConstraints { make in
            make.leading.equalTo(self.divider)
            make.top.equalTo(self.divider.snp.bottom).offset(2)
            make.trailing.lessThanOrEqualTo(self.trackButton.snp.leading)
        }
        statusDateLabel.snp.remakeConstraints { make in
            make.leading.equalTo(self.divider)
            make.top.equalTo(self.statusLabel.snp.bottom).offset(2)
            make.trailing.lessThanOrEqualTo(self.trackButton.snp.leading)
        }
        billInfoView.snp.makeConstraints { make in
            make.top.equalTo(billHeader.snp.bottom).offset(5)
            make.leading.trailing.equalToSuperview().inset(10)
            make.bottom.equalTo(bottomLayoutGuide.snp.top)
        }
    }
    func styleViews() {
        view.style(with: .backgroundColor(.slate))
        billHeader.style(with: [.backgroundColor(.white)])
        divider.style(with: [.backgroundColor(.kratosRed)])
        titleLabel.style(with: [.numberOfLines(8),
                                .font(.subHeader),
                                .textAlignment(.center)
                                ])
        
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 2.0
        
        statusLabel.style(with: [.font(.body),
                                 .titleColor(.lightGray)
                                ])
        statusDateLabel.style(with: [.font(.body),
                                 .titleColor(.lightGray)
                                ])
        trackButton.contentEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5)
        trackButton.style(with: [.font(.tab),
                                 .cornerRadius(4)])
    }
}

// MARK: - Binds -
extension BillController: RxBinder {
    func bind() {
        viewModel.title
            .asObservable()
            .bind(to: titleLabel.rx.text)
            .disposed(by: disposeBag)
        viewModel.status
            .asObservable()
            .bind(to: statusLabel.rx.text)
            .disposed(by: disposeBag)
        viewModel.statusDate
            .asObservable()
            .bind(to: statusDateLabel.rx.text)
            .disposed(by: disposeBag)
        viewModel.bill
            .asObservable()
            .filterNil()
            .bind(to: billInfoView.rx.bill)
            .disposed(by: disposeBag)
        viewModel.isTracking
            .asObservable()
            .take(1)
            .subscribe(
                onNext: { [weak self] isTracking in
                    self?.updateTrackButton(for: isTracking, animate: false)
                }
            )
            .disposed(by: disposeBag)
        viewModel.isTracking
            .asObservable()
            .skip(1)
            .subscribe(
                onNext: { [weak self] isTracking in
                    self?.updateTrackButton(for: isTracking, animate: true)
                }
            )
            .disposed(by: disposeBag)
        viewModel.trackButtonLoadStatus
            .asObservable()
            .map { $0 != .loading }
            .bind(to: trackButton.rx.isEnabled)
            .disposed(by: disposeBag)
        billInfoView.selectedPerson
            .subscribe(onNext: { [weak self] person in
                guard let `self` = self else { fatalError("self deallocated before it was accessed") }
                self.log(event: .bill(.repSelected(id: person.id)))
                let vc = RepresentativeController(client: self.client, representative: person)
                self.navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: disposeBag)
        billInfoView.selectedTally
            .subscribe(
                onNext: { [weak self] tally in
                    guard let `self` = self else { fatalError("self deallocated before it was accessed") }
                    self.log(event: .bill(.tallySelected(id: tally.id)))
                    let vc = TallyController(client: self.client, tally: tally)
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            )
            .disposed(by: disposeBag)
        billInfoView.selectedState
            .subscribe(
                onNext: { [weak self] state in
                    self?.log(event: .bill(.tabSelected(state)))
                }
            )
            .disposed(by: disposeBag)
        trackButton.rx.tap
            .withLatestFrom(viewModel.isTracking.asObservable())
            .subscribe(
                onNext: { [weak self] isTracking in
                    guard let id = self?.viewModel.bill.value?.id else { return }
                    isTracking ? self?.log(event: .bill(.untrack(id: id))) : self?.log(event: .bill(.track(id: id)))
                    isTracking ? self?.viewModel.untrack() : self?.viewModel.track()
                }
            )
            .disposed(by: disposeBag)
    }
}
