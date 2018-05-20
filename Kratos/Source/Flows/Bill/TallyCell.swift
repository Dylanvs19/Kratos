//
//  TallyCell.swift
//  Kratos
//
//  Created by Dylan Straughan on 8/4/17.
//  Copyright © 2017 Kratos, Inc. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import RxSwift
import RxCocoa

class TallyCell: UITableViewCell {
    
    // MARK: - Variables -
    // Identifier
    static let identifier = String(describing: TallyCell.self)
    
    // Standard
    let viewModel = TallyCellViewModel()
    let disposeBag = DisposeBag()
    
    // UIElements
    let pieChartView = PieChartView()
    let titleLabel = UILabel()
    let statusLabel = UILabel()
    let statusDateLabel = UILabel()
    
    let pieChartHeight: CGFloat = 75
    
    // MARK: - Initializer -
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        bind()
        addSubviews()
        constrainViews()
        styleViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Configuration - 
    func configure(with tally: Tally) {
        viewModel.update(with: tally)
        layoutIfNeeded()
    }
}

extension TallyCell: ViewBuilder {
    func addSubviews() {
        translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(pieChartView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(statusLabel)
        contentView.addSubview(statusDateLabel)
    }
    func constrainViews() {
        pieChartView.snp.remakeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(5)
            make.height.width.equalTo(pieChartHeight)
        }
        titleLabel.snp.remakeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.equalToSuperview().inset(5)
            make.trailing.equalToSuperview().inset(pieChartHeight + 2).priority(999)
        }
        statusLabel.snp.remakeConstraints { make in
            make.top.greaterThanOrEqualTo(titleLabel.snp.bottom).offset(2)
            make.leading.equalToSuperview().inset(5)
            make.trailing.equalToSuperview().inset(pieChartHeight + 2).priority(999)
        }
        statusDateLabel.snp.remakeConstraints { make in
            make.top.equalTo(statusLabel.snp.bottom).offset(2)
            make.leading.equalToSuperview().inset(5)
            make.bottom.equalToSuperview().inset(5)
            make.trailing.equalToSuperview().inset(pieChartHeight + 2).priority(999)
        }
    }
    
    func styleViews() {
        titleLabel.style(with: [.font(.h5),
                                .numberOfLines(5)])
        statusLabel.style(with: [.font(.body),
                                 .titleColor(.gray)])
        statusDateLabel.style(with: [.font(.body),
                                     .titleColor(.gray)])
        selectionStyle = .none
    }
}

extension TallyCell: RxBinder {
    func bind() {
        viewModel.pieChartData.asObservable()
            .filterNil()
            .filter { !$0.isEmpty }
            .subscribe(
                onNext: { [weak self] data in
                    self?.pieChartView.configure(with: data)
                }
            )
            .disposed(by: disposeBag)
        viewModel.name.asObservable()
            .bind(to: titleLabel.rx.text)
            .disposed(by: disposeBag)
        viewModel.status.asObservable()
            .bind(to: statusLabel.rx.text)
            .disposed(by: disposeBag)
        viewModel.statusDate.asObservable()
            .bind(to: statusDateLabel.rx.text)
            .disposed(by: disposeBag)
    }
}
