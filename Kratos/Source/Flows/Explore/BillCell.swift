//
//  BillCell.swift
//  Kratos
//
//  Created by Dylan Straughan on 8/6/17.
//  Copyright © 2017 Kratos, Inc. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import SnapKit

class BillCell: UITableViewCell {
    // MARK: - Variables -
    // Identifier
    static let identifier = String(describing: BillCell.self)
    
    // Standard
    let viewModel = BillCellViewModel()
    let disposeBag = DisposeBag()
    
    // UIElements
    let titleLabel = UILabel()
    let subjectLabel = UILabel()
    let lastAction = UILabel()
    
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
    func configure(with bill: Bill) {
        viewModel.update(with: bill)
    }
}

extension BillCell: ViewBuilder {
    func addSubviews() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(subjectLabel)
        contentView.addSubview(lastAction)
    }
    func constrainViews() {
        titleLabel.snp.makeConstraints { make in
            make.leading.top.trailing.equalToSuperview().offset(5)
        }
        lastAction.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(2)
            make.leading.trailing.equalToSuperview().offset(5)
        }
        subjectLabel.snp.makeConstraints { make in
            make.top.equalTo(lastAction.snp.bottom).offset(2)
            make.leading.bottom.equalToSuperview().inset(5)
        }
    }
    
    func styleViews() {
        titleLabel.style(with: [.font(.h5),
                                .titleColor(.black),
                                .numberOfLines(5)])
        lastAction.style(with: [.font(.body),
                                .titleColor(.gray)])
        subjectLabel.style(with: [.font(.body),
                                  .titleColor(.gray)])
        accessoryType = .disclosureIndicator
        separatorInset = .zero
        selectionStyle = .none
    }
}

extension BillCell: RxBinder {
    func bind() {
        viewModel.title
            .asObservable()
            .bind(to: titleLabel.rx.text)
            .disposed(by: disposeBag)
        viewModel.subject
            .asObservable()
            .bind(to: subjectLabel.rx.text)
            .disposed(by: disposeBag)
        viewModel.lastAction
            .asObservable()
            .bind(to: lastAction.rx.text)
            .disposed(by: disposeBag)
    }
}
