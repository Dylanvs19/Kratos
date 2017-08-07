//
//  BillViewController.swift
//  Kratos
//
//  Created by Dylan Straughan on 7/12/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class BillViewController: UIViewController {
    
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
    let trackButton: TrackButton
    //BillInfo
    let billInfoView = BillInfoView()
    
    // MARK: - Initialization -
    init(client: Client, billID: Int) {
        self.client = client
        self.viewModel = BillViewModel(client: client, billID: billID)
        self.trackButton = TrackButton(with: client, billId: billID)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSubviews()
        constrainViews()
        styleViews()
        bind()
        //RepInfoView needs to be laid out and constrained after view is larger than .zero
        view.layoutIfNeeded()
        billInfoView.build()
    }
}

// MARK: - View Builder -
extension BillViewController: ViewBuilder {
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
            make.leading.trailing.equalToSuperview()
            make.top.equalToSuperview()
        }
        titleLabel.snp.remakeConstraints { make in
            make.leading.top.trailing.equalToSuperview().inset(50)
        }
        divider.snp.remakeConstraints { make in
            make.trailing.leading.equalToSuperview().inset(20)
            make.top.equalTo(self.titleLabel.snp.bottom).offset(5)
            make.height.equalTo(1)
        }
        trackButton.snp.remakeConstraints { make in
            make.top.equalTo(divider.snp.bottom).offset(10)
            make.trailing.bottom.equalToSuperview().inset(10)
            make.width.equalTo(55)
        }
        statusLabel.snp.remakeConstraints { make in
            make.leading.equalTo(self.divider)
            make.top.equalTo(self.divider.snp.bottom).offset(2)
            make.trailing.equalTo(self.trackButton.snp.leading)
        }
        statusDateLabel.snp.remakeConstraints { make in
            make.leading.equalTo(self.divider)
            make.top.equalTo(self.statusLabel.snp.bottom).offset(2)
            make.trailing.equalTo(self.trackButton.snp.leading)
        }
        billInfoView.snp.makeConstraints { make in
            make.top.equalTo(billHeader.snp.bottom).offset(5)
            make.leading.trailing.equalToSuperview().inset(10)
            make.bottom.equalTo(bottomLayoutGuide.snp.top).offset(-10)
        }
    }
    func styleViews() {
        view.style(with: .backgroundColor(.slate))
        billHeader.style(with: [.backgroundColor(.white)])
        divider.style(with: [.backgroundColor(.kratosRed)])
        titleLabel.style(with: [.numberOfLines(8),
                                .font(.title),
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
        
        trackButton.addShadow()
    }
}

// MARK: - Binds -
extension BillViewController: RxBinder {
    func bind() {
        viewModel.title.asObservable()
            .bind(to: titleLabel.rx.text)
            .disposed(by: disposeBag)
        viewModel.status.asObservable()
            .bind(to: statusLabel.rx.text)
            .disposed(by: disposeBag)
        viewModel.statusDate.asObservable()
            .bind(to: statusDateLabel.rx.text)
            .disposed(by: disposeBag)
        viewModel.bill.asObservable()
            .subscribe(onNext: { [weak self] bill in
                self?.billInfoView.update(with: bill)
            })
            .disposed(by: disposeBag)
    }
}
