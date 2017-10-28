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
    
    var viewModel: UserRepTableViewCellModel?
    var client: Client? {
        didSet {
            if oldValue == nil {
                addSubviews()
                constrainViews()
                styleViews()
                bind()
            }
        }
    }
    let partyIndicatorView = UIView()
    let representativeImageView = RepImageView()
    let nameLabel = UILabel()
    let representativeLabel = UILabel()
    
    var representative = Variable<Person?>(nil)
    var viewPosition: Int = 0
    
    weak var repViewDelegate: RepViewDelegate?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    func configure(with client: Client, person: Person) {
        self.viewModel = UserRepTableViewCellModel(client: client, person: person)
        self.client = client
        selectionStyle = .none
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
        nameLabel.style(with: .font(.title))
        representativeLabel.style(with: .font(.subTitle))
        self.addShadow()
    }
}

extension UserRepTableViewCell: RxBinder {
    func bind() {
        guard let viewModel = viewModel else { return }
        viewModel.name.asObservable()
            .asDriver(onErrorJustReturn: "")
            .drive(nameLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.chamber.asObservable()
            .map { $0.representativeType.rawValue }
            .asDriver(onErrorJustReturn: "")
            .drive(representativeLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.partyColor.asObservable()
            .asDriver(onErrorJustReturn: UIColor.slate)
            .distinctUntilChanged()
            .drive(onNext: { [weak self] color in
                self?.partyIndicatorView.backgroundColor = color
            })
            .disposed(by: disposeBag)
        
        viewModel.url.asObservable()
            .filterNil()
            .bind(to: self.representativeImageView.rx.setImage())
            .disposed(by: disposeBag)
    }
}
