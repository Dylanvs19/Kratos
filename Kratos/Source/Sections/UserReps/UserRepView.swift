//
//  RepresentativeView.swift
//  Kratos
//
//  Created by Dylan Straughan on 3/30/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import RxGesture

protocol RepViewDelegate: class {
    func repViewTapped(at position: Int, personID: Int, image: UIImage, initialImageViewPosition: CGRect)
}

class UserRepView: UIView {
    
    var disposeBag = DisposeBag()
    
    var viewModel: UserRepViewModel?
    var client: Client? {
        didSet {
            if oldValue == nil {
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
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        buildViews()
        style()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    func configure(with client: Client, representative: Person) {
        self.viewModel = UserRepViewModel(client: client, person: representative)
    }
}

extension UserRepView: ViewBuilder {
    func buildViews() {
        setupRepImageView()
        setupLabels()
        setupPartyView()
    }
    
    func setupRepImageView() {
        representativeImageView.snp.makeConstraints { make in
            make.height.equalTo(representativeImageView.snp.width)
            make.height.equalTo(self).inset(-40)
            make.centerX.equalTo(self)
            make.leading.equalTo(self).offset(10)
        }
    }
    
    func setupLabels() {
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(representativeImageView.snp.top)
            make.leading.equalTo(representativeImageView.snp.trailing).offset(10)
        }
        
        representativeLabel.snp.makeConstraints { make in
            make.bottom.equalTo(representativeImageView.snp.bottom)
            make.leading.equalTo(representativeImageView.snp.trailing).offset(10)
        }
    }
    
    func setupPartyView() {
        partyIndicatorView.snp.makeConstraints { make in
            make.leading.trailing.top.equalTo(self)
            make.height.equalTo(3)
        }
    }
    
    func style() {
        nameLabel.font = Font.futura(size: 20).font
        representativeLabel.font = Font.avenirNextDemiBold(size: 15).font
    }
}

extension UserRepView: RxBinder {
    func bind() {
        guard let viewModel = viewModel else { return }
        viewModel.name.asObservable()
            .asDriver(onErrorJustReturn: "")
            .drive(nameLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.chamber.asObservable()
            .map { $0.toRepresentativeType().rawValue }
            .asDriver(onErrorJustReturn: "")
            .drive(representativeLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.partyColor.asObservable()
            .asDriver(onErrorJustReturn: UIColor.kratosLightGray)
            .distinctUntilChanged()
            .drive(onNext: { [weak self] color in
                self?.backgroundColor = color
            })
            .disposed(by: disposeBag)
        
        self.rx.tapGesture()
            .withLatestFrom(representative.asObservable().filterNil())
            .subscribe(onNext: { person in
                
            })
            .disposed(by: disposeBag)
    }
}
