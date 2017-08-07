//
//  RepresentativeCell.swift
//  Kratos
//
//  Created by Dylan Straughan on 8/3/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import SnapKit

class RepresentativeCell: UITableViewCell {
    
    // MARK: - Variables -
    
    // Identifier
    static let identifier = String(describing: RepresentativeCell.self)
    
    // Standard
    let disposeBag = DisposeBag()
    let viewModel = RepresentativeCellViewModel()
    
    // UIElements
    let repImageView = RepImageView()
    let voteImageView = UIImageView()
    let nameLabel = UILabel()
    let stateChamberLabel = UILabel()
    let partyLabel = UILabel()
    
    // Constants
    let imageViewHeight: CGFloat = 50
    let voteViewHeight: CGFloat = 40
    
    // MARK: - Initialization -
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubviews()
        constrainViews()
        styleViews()
        bind()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(with vote: Vote) {
        viewModel.update(with: vote)
    }
    
    func update(with representative: Person) {
        viewModel.update(with: representative)
    }
}

extension RepresentativeCell: ViewBuilder {
    func addSubviews() {
        contentView.addSubview(repImageView)
        contentView.addSubview(voteImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(stateChamberLabel)
        contentView.addSubview(partyLabel)
    }
    
    func constrainViews() {
        repImageView.snp.remakeConstraints { make in
            make.leading.top.bottom.equalToSuperview().inset(5)
            make.height.width.equalTo(imageViewHeight).priority(999)
        }
        voteImageView.snp.remakeConstraints { make in
            make.trailing.equalToSuperview().inset(5)
            make.height.width.equalTo(voteViewHeight)
            make.centerY.equalToSuperview()
        }
        nameLabel.snp.remakeConstraints { make in
            make.top.equalTo(repImageView.snp.top)
            make.leading.equalTo(repImageView.snp.trailing).offset(5)
            make.trailing.equalTo(voteImageView.snp.leading).offset(-5)
        }
        stateChamberLabel.snp.remakeConstraints { make in
            make.bottom.equalTo(repImageView.snp.bottom)
            make.leading.equalTo(repImageView.snp.trailing).offset(5)
        }
        partyLabel.snp.remakeConstraints { make in
            make.centerY.equalTo(stateChamberLabel.snp.centerY)
            make.leading.equalTo(stateChamberLabel.snp.trailing).offset(5)
            make.trailing.lessThanOrEqualTo(voteImageView.snp.leading).offset(-5)
        }
    }
    
    func styleViews() {
        nameLabel.style(with: .font(.cellTitle))
        stateChamberLabel.style(with: [.font(.cellSubTitle),
                                       .titleColor(.gray)])
        partyLabel.style(with: [.font(.cellSubTitle),
                                .textAlignment(.right),
                                .titleColor(.gray)])
    }
}

extension RepresentativeCell: RxBinder {
    func bind() {
        viewModel.imageURL.asObservable()
            .filterNil()
            .bind(to: repImageView.rx.setImage())
            .disposed(by: disposeBag)
        viewModel.voteValue.asObservable()
            .filterNil()
            .map { $0.image }
            .bind(to: voteImageView.rx.image)
            .disposed(by: disposeBag)
        viewModel.name.asObservable()
            .bind(to: nameLabel.rx.text)
            .disposed(by: disposeBag)
        viewModel.stateChamber.asObservable()
            .bind(to: stateChamberLabel.rx.text)
            .disposed(by: disposeBag)
        viewModel.party.asObservable()
            .bind(to: partyLabel.rx.text)
            .disposed(by: disposeBag)
    }
}
