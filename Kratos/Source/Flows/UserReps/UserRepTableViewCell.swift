//
//  RepresentativeView.swift
//  Kratos
//
//  Created by Dylan Straughan on 3/30/17.
//  Copyright © 2017 Kratos, Inc. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

protocol RepViewDelegate: class {
    func repViewTapped(at position: Int, personID: Int, image: UIImage, initialImageViewPosition: CGRect)
}

class UserRepTableViewCell: UITableViewCell {
    
    static let identifier = String(describing: UserRepTableViewCell.self)
    
    var disposeBag = DisposeBag()
    
    var viewModel = UserRepTableViewCellModel()
    
    let partyIndicatorView = UIView()
    let representativeImageView = RepImageView()
    let nameLabel = UILabel()
    let representativeLabel = UILabel()
    
    var representative = Variable<Person?>(nil)
    var viewPosition: Int = 0
    
    weak var repViewDelegate: RepViewDelegate?
    
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
        
    func update(with person: Person) {
        self.viewModel.update(with: person)
    }
    
    func configureForSingleRep() {
        representativeImageView.snp.remakeConstraints { make in
            make.width.equalToSuperview().offset(-100)
            make.height.equalTo(representativeImageView.snp.width)
            make.top.equalToSuperview().inset(10)
            make.centerX.equalToSuperview()
        }
        nameLabel.snp.remakeConstraints { make in
            make.top.equalTo(representativeImageView.snp.bottom).offset(10)
            make.centerX.equalTo(representativeImageView)
        }
        representativeLabel.snp.remakeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(10)
            make.centerX.equalTo(representativeImageView)
            make.bottom.equalToSuperview().inset(10)
        }
        layoutIfNeeded()
    }
}

extension UserRepTableViewCell: ViewBuilder {
    func addSubviews() {
        contentView.addSubview(representativeImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(representativeLabel)
        contentView.addSubview(partyIndicatorView)
    }
    func constrainViews() {
        representativeImageView.snp.makeConstraints { make in
            make.height.equalToSuperview().offset(-50)
            make.width.equalTo(representativeImageView.snp.height)
            make.centerY.equalToSuperview()
            make.leading.equalTo(self).offset(10)
        }
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(representativeImageView.snp.top)
            make.leading.equalTo(representativeImageView.snp.trailing).offset(10)
        }
        representativeLabel.snp.makeConstraints { make in
            make.bottom.equalTo(representativeImageView.snp.bottom)
            make.leading.equalTo(representativeImageView.snp.trailing).offset(10)
        }
        partyIndicatorView.snp.makeConstraints { make in
            make.leading.trailing.top.equalTo(self)
            make.height.equalTo(3)
        }
    }
    
    func styleViews() {
        selectionStyle = .none
        nameLabel.style(with: .font(.h2))
        representativeLabel.style(with: .font(.h4))
    }
}

extension UserRepTableViewCell: RxBinder {
    func bind() {
        viewModel.name
            .bind(to:nameLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.chamber
            .map { $0.representativeType.rawValue }
            .bind(to:representativeLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.party
            .map { $0.color }
            .distinctUntilChanged()
            .subscribe(onNext: { [unowned self] in self.partyIndicatorView.backgroundColor = $0.value })
            .disposed(by: disposeBag)
        
        viewModel.url
            .asObservable()
            .bind(to: self.representativeImageView.rx.setImage())
            .disposed(by: disposeBag)
    }
}
