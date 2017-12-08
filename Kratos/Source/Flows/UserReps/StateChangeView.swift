//
//  StateChangeView.swift
//  Kratos
//
//  Created by Dylan Straughan on 11/11/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import SnapKit

class StateChangeView: UIView {
    // MARK: - Variables -
    // External
    let query = Variable<String>("")
    let districts = Variable<[[District]]>([])
    let selectedDistrict = Variable<District?>(nil)
    
    // Internal Data
    let currentlySelectedDistrict = Variable<District?>(nil)
    var user: Variable<User?>
    let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<State, District>>()
    let showReturnHomeButton = Variable<Bool>(false)
    
    // Internal
    let topView = UIView()
    let stateTitle = UILabel()
    let districtTitle = UILabel()
    let imageView = UIImageView()
    let returnToHomeButton = UIButton()
    let descriptionLabel = UILabel()
    let searchField = KratosTextField()
    let submitButton = UIButton()
    
    let tableView = UITableView()
    
    let disposeBag = DisposeBag()
    
    // MARK: - Initializer -
    init(user: Variable<User?>) {
        self.user = user
        super.init(frame: .zero)
        addSubviews()
        constrainViews()
        styleViews()
        bind()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configuration -
    func configureTableView() {
        tableView.register(StateCell.self, forCellReuseIdentifier: StateCell.identifier)
        tableView.register(StateHeaderView.self, forHeaderFooterViewReuseIdentifier: StateHeaderView.identifier)
        tableView.rx.setDelegate(self)
            .addDisposableTo(disposeBag)
        
        dataSource.configureCell = { ds, tv, ip, element in
            guard let cell = tv.dequeueReusableCell(withIdentifier: StateCell.identifier, for: ip) as? StateCell else { fatalError() }
            cell.update(with: element)
            return cell
        }
    }
}

// MARK: - Localizer -
extension StateChangeView: Localizer {
    func localizeStrings() {
        
    }
}

// MARK: - UITableViewDelegate -
extension StateChangeView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let state = dataSource[section].model
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: StateHeaderView.identifier) as? StateHeaderView else { fatalError() }
        header.update(with: state)
        return header
    }
}

// MARK: - ViewBuilder-
extension StateChangeView: ViewBuilder {
    func addSubviews() {
        addSubview(topView)
        topView.addSubview(stateTitle)
        topView.addSubview(districtTitle)
        addSubview(imageView)
        addSubview(returnToHomeButton)
        addSubview(descriptionLabel)
        addSubview(searchField)
        addSubview(tableView)
        addSubview(submitButton)
    }
    func constrainViews() {
        topView.snp.makeConstraints { make in
            make.top.trailing.leading.equalToSuperview()
        }
        stateTitle.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(5)
        }
        districtTitle.snp.makeConstraints { make in
            make.top.equalTo(stateTitle.snp.bottom).offset(2)
            make.leading.trailing.bottom.equalToSuperview().inset(5)
        }
        imageView.snp.makeConstraints { make in
            make.top.equalTo(topView.snp.bottom).offset(Dimension.mediumMargin)
            make.centerX.equalToSuperview()
            make.height.equalTo(50)
        }
        returnToHomeButton.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(Dimension.mediumMargin)
            make.leading.trailing.equalToSuperview().inset(-1)
            make.height.equalTo(Dimension.largeButtonHeight)
        }
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(returnToHomeButton.snp.bottom).offset(Dimension.defaultMargin)
            make.leading.trailing.equalToSuperview().inset(Dimension.defaultMargin)
        }
        searchField.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(Dimension.defaultMargin)
        }
        submitButton.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(40)
        }
        tableView.snp.makeConstraints { make in
            make.top.equalTo(searchField.snp.bottom).offset(Dimension.defaultMargin)
            make.leading.trailing.equalToSuperview().inset(Dimension.defaultMargin)
            make.bottom.equalTo(submitButton.snp.top).offset(-Dimension.defaultMargin)
        }
    }
    func styleViews() {
        style(with: .backgroundColor(.white))
    }
}

// MARK: - RxBinder -
extension StateChangeView: RxBinder {
    func bind() {
        bindTableview()
        bindCurrentlySelectedDistrict()
        
        searchField.textField.rx.text
            .map { $0 ?? "" }
            .bind(to: query)
            .disposed(by: disposeBag)
        submitButton.rx.tap
            .withLatestFrom(currentlySelectedDistrict.asObservable())
            .filterNil()
            .bind(to: selectedDistrict)
            .disposed(by: disposeBag)
    }
    
    private func bindTableview() {
        districts
            .asObservable()
            .map { $0.map{ SectionModel(model: $0.first?.state ?? .puertoRico, items: $0) }}
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        tableView.rx.modelSelected(District.self)
            .bind(to: currentlySelectedDistrict)
            .disposed(by: disposeBag)
    }
    
    private func bindCurrentlySelectedDistrict() {
        currentlySelectedDistrict
            .asObservable()
            .filterNil()
            .map { $0.state.grayImage}
            .bind(to: imageView.rx.image)
            .disposed(by: disposeBag)
        currentlySelectedDistrict
            .asObservable()
            .filterNil()
            .map { $0.state.fullName}
            .bind(to: stateTitle.rx.text)
            .disposed(by: disposeBag)
        currentlySelectedDistrict
            .asObservable()
            .filterNil()
            .map { "District \($0.district)"}
            .bind(to: districtTitle.rx.text)
            .disposed(by: disposeBag)
        user
            .asObservable()
            .filterNil()
            .map { $0.visitingDistrict ?? $0.district }
            .bind(to: currentlySelectedDistrict )
            .disposed(by: disposeBag)
        Observable.combineLatest(user.asObservable().filterNil(), currentlySelectedDistrict.asObservable().filterNil()) { (user, current) -> Bool in
                return user.district != current
            }
            .bind(to: showReturnHomeButton)
            .disposed(by: disposeBag)
    }
}
