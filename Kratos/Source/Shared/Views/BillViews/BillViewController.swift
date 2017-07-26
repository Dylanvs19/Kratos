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
    let trackingButton = UIButton()
    //BillInfo
    let billInfoView = BillInfoView()
    
    // MARK: - Initialization -
    init(client: Client, billID: Int) {
        self.client = client
        self.viewModel = BillViewModel(client: client, billID: billID)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        billHeader.addSubview(trackingButton)
        view.addSubview(billInfoView)
    }
    func constrainViews() {
        billHeader.snp.remakeConstraints { make in
            make.leading.top.trailing.equalToSuperview()
        }
        titleLabel.snp.remakeConstraints { make in
            make.leading.top.trailing.equalToSuperview().inset(10)
        }
        divider.snp.remakeConstraints { make in
            make.trailing.leading.equalTo(self.titleLabel)
            make.top.equalTo(self.titleLabel.snp.bottom).offset(5)
            make.height.equalTo(1)
        }
        trackingButton.snp.remakeConstraints { make in
            make.trailing.equalTo(self.divider)
            make.top.equalTo(self.divider.snp.bottom).offset(8)
            make.bottom.equalToSuperview().offset(-8)
        }
        statusLabel.snp.remakeConstraints { make in
            make.leading.equalTo(self.divider)
            make.top.equalTo(self.divider.snp.bottom).offset(2)
            make.trailing.equalTo(self.trackingButton.snp.leading)
        }
        statusLabel.snp.remakeConstraints { make in
            make.leading.equalTo(self.divider)
            make.top.equalTo(self.statusLabel.snp.bottom).offset(2)
            make.trailing.equalTo(self.trackingButton.snp.leading)
        }
    }
    func style() {
        titleLabel.numberOfLines = 8
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 2.0
        titleLabel.font = .header
        titleLabel.textAlignment = .center
        
        statusLabel.font = .body
        statusLabel.textColor = UIColor.lightGray
        
        statusDateLabel.font = .body
        statusDateLabel.textColor = UIColor.lightGray
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
