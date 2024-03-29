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
    let stateTitle = UILabel(style: .h3white)
    let districtTitle = UILabel(style: .h3white)
    let returnToHomeButton = UIButton()
    let descriptionLabel = UILabel(style: .bodyGray)
    let searchField = TextField(style: .standard, type: .text, placeholder: localize(.textFieldSearchTitle))
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
        
        bind()
        localizeStrings()
        configureTableView()
        configureNavigationBar()
    }
    
    func configureNavigationBar() {
        setDefaultNavVC()
        setClearButton(isRed: false)
    }
    
    // MARK: - Configuration -
    func configureTableView() {
        tableView.register(StateCell.self, forCellReuseIdentifier: StateCell.identifier)
        tableView.register(StateHeaderView.self, forHeaderFooterViewReuseIdentifier: StateHeaderView.identifier)
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        tableView.separatorInset = .zero
        tableView.separatorColor = Color.lightGray.value
        tableView.tableFooterView = UIView()
    }
    
    func updateReturnHomeButton(with shouldShow: Bool) {
        let height = shouldShow ? Dimension.largeButtonHeight : 0
        UIView.animate(withDuration: 0.3) {
            self.returnToHomeButton.snp.updateConstraints { make in
                make.height.equalTo(height)
            }
            self.view.layoutIfNeeded()
        }
    }
}

// MARK: - Localizer -
extension DistrictChangeController: Localizer {
    func localizeStrings() {
        returnToHomeButton.setTitle(localize(.districtSelectionReturnHomeButtonTitle), for: .normal)
        descriptionLabel.text = localize(.districtSelectionSearchInfoLabel)
        title = localize(.districtSelectionTitle)
    }
}

// MARK: - UITableViewDelegate -
extension DistrictChangeController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45
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
    func styleViews() {
        view.style(with: .backgroundColor(.white))
        stateTitle.style(with: [.font(.h3),
                                .textAlignment(.left),
                                .titleColor(.white)])
        
        districtTitle.style(with: [.font(.h3),
                                   .textAlignment(.right),
                                   .titleColor(.white)])
        
        returnToHomeButton.style(with: [.borderWidth(1),
                                        .borderColor(.gray),
                                        .titleColor(.kratosRed),
                                        .font(.h5)])
        
        topView.style(with: .backgroundColor(.kratosRed))
        
        descriptionLabel.style(with: [.font(.body),
                                      .titleColor(.gray),
                                      .numberOfLines(4),
                                      .textAlignment(.center)])
        searchField.clipsToBounds = false
        returnToHomeButton.clipsToBounds = true
    }
    
    func addSubviews() {
        addTopView()
        addStateTitle()
        addDistrictTitle()
        addReturnHomeButton()
        addDescriptionLabel()
        addSearchField()
        addTableView()
    }
    
    private func addTopView() {
        view.addSubview(topView)

        topView.snp.makeConstraints { make in
            make.top.trailing.leading.equalToSuperview()
        }
    }
    
    private func addStateTitle() {
        topView.addSubview(stateTitle)

        stateTitle.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(Dimension.topMargin + 5)
            make.leading.trailing.equalToSuperview().inset(Dimension.defaultMargin)
            make.bottom.equalToSuperview().inset(5)
        }
    }
    
    private func addDistrictTitle() {
        topView.addSubview(districtTitle)

        districtTitle.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(Dimension.topMargin + 5)
            make.leading.trailing.equalToSuperview().inset(Dimension.defaultMargin)
        }
    }
    
    private func addReturnHomeButton() {
        view.addSubview(returnToHomeButton)

        returnToHomeButton.snp.makeConstraints { make in
            make.top.equalTo(topView.snp.bottom)
            make.leading.trailing.equalToSuperview().inset(-1)
            make.height.equalTo(Dimension.largeButtonHeight)
        }
    }
    
    private func addDescriptionLabel() {
        view.addSubview(descriptionLabel)

        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(returnToHomeButton.snp.bottom).offset(Dimension.defaultMargin)
            make.leading.trailing.equalToSuperview().inset(Dimension.defaultMargin)
        }
    }
    
    private func addSearchField() {
        view.addSubview(searchField)

        searchField.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(Dimension.defaultMargin)
            make.leading.trailing.equalToSuperview().inset(Dimension.defaultMargin)
        }
    }
    
    private func addTableView() {
        view.addSubview(tableView)

        tableView.snp.makeConstraints { make in
            make.top.equalTo(searchField.snp.bottom).offset(Dimension.defaultMargin * 2)
            make.leading.trailing.equalToSuperview().inset(Dimension.defaultMargin)
            make.bottom.equalTo(self.view.snp.bottomMargin).offset(-Dimension.iPhoneXMargin)
        }
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
        returnToHomeButton.rx.tap
            .subscribe(onNext: { [unowned self] in self.viewModel.clearVisitingDistrict() })
            .disposed(by: disposeBag)
        viewModel.showReturnHomeButton
            .asObservable()
            .subscribe(onNext: { [unowned self] in self.updateReturnHomeButton(with: $0) })
            .disposed(by: disposeBag)
        viewModel.shouldReturn
            .subscribe(onNext: { [unowned self] in self.dismiss(animated: true, completion: nil) })
            .disposed(by: disposeBag)
    }
    
    private func bindTableview() {
        viewModel.districtModels
            .asObservable()
            .map { $0.map{ SectionModel(model: $0.first?.state ?? .puertoRico, items: $0) }}
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        tableView.rx.modelSelected(District.self)
            .do(onNext: { [unowned self] _ in
                    self.searchField.endEditing(true)
                }
            )
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
                        self.tableView.snp.updateConstraints{ make in
                            make.bottom.equalTo(self.view.snp.bottomMargin).offset(-Dimension.iPhoneXMargin - height)
                        }
                        self.view.layoutIfNeeded()
                    })
                }
            )
            .disposed(by: disposeBag)
    }
}
