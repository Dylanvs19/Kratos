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

class DistrictChangeController: UIViewController {
    // MARK: - Variables -
    let client: Client
    let viewModel: DistrictChangeViewModel
    let disposeBag = DisposeBag()
    
    // Internal Data
    let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<State, District>>(configureCell: {ds, tv, ip, element in
        guard let cell = tv.dequeueReusableCell(withIdentifier: StateCell.identifier, for: ip) as? StateCell else { fatalError() }
        cell.update(with: element)
        return cell})
    
    // Internal
    let topView = UIView()
    let stateTitle = UILabel()
    let districtTitle = UILabel()
    let returnToHomeButton = UIButton()
    let descriptionLabel = UILabel()
    let searchField = TextField(style: .standard, type: .text, placeholder: localize(.textFieldSearchTitle))
    let submitButton = UIButton()
    let tableView = UITableView()
    
    // MARK: - Initializer -
    init(client: Client) {
        self.client = client
        self.viewModel = DistrictChangeViewModel(client: client)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        styleViews()
        addSubviews()
        constrainViews()
        
        bind()
        localizeStrings()
        configureTableView()
        configureNavigationBar()
    }
    
    func configureNavigationBar() {
        setDefaultNavVC()
        setDefaultClearButton()
    }
    
    // MARK: - Configuration -
    func configureTableView() {
        tableView.register(StateCell.self, forCellReuseIdentifier: StateCell.identifier)
        tableView.register(StateHeaderView.self, forHeaderFooterViewReuseIdentifier: StateHeaderView.identifier)
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        tableView.tableFooterView = UIView()
    }
    
    func updateReturnHomeButton(with shouldShow: Bool) {
        let height = shouldShow ? Dimension.largeButtonHeight : 0
        returnToHomeButton.snp.updateConstraints { make in
            make.height.equalTo(height)
        }
    }
}

// MARK: - Localizer -
extension DistrictChangeController: Localizer {
    func localizeStrings() {
        submitButton.setTitle(localize(.submit), for: .normal)
        returnToHomeButton.setTitle(localize(.districtSelectionReturnHomeButtonTitle), for: .normal)
        descriptionLabel.text = localize(.districtSelectionSearchInfoLabel)
        title = localize(.districtSelectionTitle)
    }
}

// MARK: - UITableViewDelegate -
extension DistrictChangeController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let state = dataSource[section].model
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: StateHeaderView.identifier) as? StateHeaderView else { fatalError() }
        header.update(with: state)
        return header
    }
}

// MARK: - ViewBuilder-
extension DistrictChangeController: ViewBuilder {
    func addSubviews() {
        view.addSubview(topView)
        topView.addSubview(stateTitle)
        topView.addSubview(districtTitle)
        view.addSubview(returnToHomeButton)
        view.addSubview(descriptionLabel)
        view.addSubview(searchField)
        view.addSubview(tableView)
        view.addSubview(submitButton)
    }
    func constrainViews() {
        topView.snp.makeConstraints { make in
            make.top.trailing.leading.equalToSuperview()
        }
        stateTitle.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(Dimension.navBarInset)
            make.leading.trailing.equalToSuperview().inset(Dimension.defaultMargin)
        }
        districtTitle.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(Dimension.navBarInset)
            make.leading.trailing.bottom.equalToSuperview().inset(Dimension.defaultMargin)
        }
        returnToHomeButton.snp.makeConstraints { make in
            make.top.equalTo(topView.snp.bottom)
            make.leading.trailing.equalToSuperview().inset(-1)
            make.height.equalTo(Dimension.largeButtonHeight)
        }
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(returnToHomeButton.snp.bottom).offset(Dimension.defaultMargin)
            make.leading.trailing.equalToSuperview().inset(Dimension.defaultMargin)
        }
        searchField.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(Dimension.defaultMargin)
            make.leading.trailing.equalToSuperview().inset(Dimension.defaultMargin)
            make.height.equalTo(25)
        }
        submitButton.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(40)
        }
        tableView.snp.makeConstraints { make in
            make.top.equalTo(searchField.snp.bottom).offset(Dimension.defaultMargin * 2)
            make.leading.trailing.equalToSuperview().inset(Dimension.defaultMargin)
            make.bottom.equalTo(submitButton.snp.top).offset(-Dimension.defaultMargin)
        }
    }
    func styleViews() {
        view.style(with: .backgroundColor(.white))
        submitButton.style(with: [.backgroundColor(.kratosRed),
                                  .titleColor(.white),
                                  .font(.subHeader)])
        stateTitle.style(with: [.font(.subHeader),
                                .textAlignment(.left),
                                .titleColor(.white)])
        districtTitle.style(with: [.font(.subHeader),
                                .textAlignment(.right),
                                .titleColor(.white)])
        returnToHomeButton.style(with: [.borderWidth(1),
                                        .borderColor(.gray),
                                        .titleColor(.kratosRed),
                                        .font(.cellTitle)])
        topView.style(with: .backgroundColor(.kratosRed))
        descriptionLabel.style(with: [.font(.body),
                                      .titleColor(.gray),
                                      .numberOfLines(4),
                                      .textAlignment(.center)])
        searchField.clipsToBounds = false
        returnToHomeButton.clipsToBounds = true
    }
}

// MARK: - RxBinder -
extension DistrictChangeController: RxBinder {
    func bind() {
        bindTableview()
        bindCurrentlySelectedDistrict()
        adjustForKeyboard()
        
        searchField.text
            .map { $0 ?? "" }
            .bind(to: viewModel.query)
            .disposed(by: disposeBag)
        submitButton.rx.tap
            .subscribe(
                onNext: { [weak self] in
                    self?.viewModel.updateDistrict()
                }
            )
            .disposed(by: disposeBag)
        viewModel.showReturnHomeButton
            .asObservable()
            .subscribe(
            onNext: { [weak self] shouldShow in
                guard let `self` = self else { return }
                    self.updateReturnHomeButton(with: shouldShow)
                }
            )
            .disposed(by: disposeBag)
    }
    
    private func bindTableview() {
        viewModel.districtModels
            .asObservable()
            .map { $0.map{ SectionModel(model: $0.first?.state ?? .puertoRico, items: $0) }}
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        tableView.rx.modelSelected(District.self)
            .bind(to: viewModel.selectedDistrict)
            .disposed(by: disposeBag)
    }
    
    private func bindCurrentlySelectedDistrict() {
        viewModel.presentedDistrict
            .asObservable()
            .filterNil()
            .map { $0.state.fullName}
            .bind(to: stateTitle.rx.text)
            .disposed(by: disposeBag)
        viewModel.presentedDistrict
            .asObservable()
            .filterNil()
            .map { "District \($0.district)"}
            .bind(to: districtTitle.rx.text)
            .disposed(by: disposeBag)
    }
    
    private func adjustForKeyboard() {
        keyboardHeight
            .subscribe(
                onNext: { [weak self] height in
                    guard let `self` = self else { return }
                    UIView.animate(withDuration: 0.2, animations: {
                        self.submitButton.snp.updateConstraints{ make in
                            make.bottom.equalToSuperview().inset(height)
                        }
                        self.view.layoutIfNeeded()
                    })
                }
            )
            .disposed(by: disposeBag)
    }
}
