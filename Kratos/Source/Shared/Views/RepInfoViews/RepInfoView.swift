//
//  RepInfoView.swift
//  Kratos
//
//  Created by Dylan Straughan on 1/13/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxDataSources
import SnapKit

class RepInfoView: UIView {
    
    enum State: Equatable {
    case bio
    case votes
    case bills
        
        var displayName: String {
            switch self {
            case .bio:
                return "Biography"
            case .votes:
                return "Votes"
            case .bills:
                return "Sponsored Bills"
            }
        }
        
        var button: UIButton {
            let button = UIButton()
            button.setTitle(displayName, for: .normal)
            button.titleLabel?.font = Font.futura(size: 14).font
            button.setTitleColor(.kratosRed, for: .normal)
            button.setTitleColor(.red, for: .highlighted)
            button.backgroundColor = .white
            button.addShadow()
            return button
        }
        
        func scrollViewXPosition(in view: UIView) -> CGFloat {
            switch self {
            case .bio:
                return 0
            case .votes:
                return view.frame.size.width
            case .bills:
                return view.frame.size.width * 2
            }
        }
        func indicatorXPosition(in view: UIView) -> CGFloat {
            let width = view.frame.size.width / 3
            switch self {
            case .bio:
                return 0
            case .votes:
                return width
            case .bills:
                return width * 2
            }
        }
    }
    
    let managerStackView = UIStackView()
    let managerIndicatorView = UIView()
    
    let scrollView = UIScrollView()
    let stackView = UIStackView()
    
    let bioScrollView = UIScrollView()
    let bioStackView = UIStackView()
    let bioView = ExpandableTextFieldView()
    let termsTableView = UITableView()
    
    let termsDataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, Term>>()
    let votesDataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, LightTally>>()
    let billsDataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, Bill>>()
    
    let votesTableView = UITableView()
    let billsTableView = UITableView()
    
    var viewModel: RepInfoViewModel?
    let contentOffset = Variable<CGFloat>(0)
    let disposeBag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with client: Client, representative: Person, contentOffset: Variable<CGFloat>) {
        viewModel = RepInfoViewModel(with: client, representative: representative, contentOffset: contentOffset)
    }
    
    func build() {
        style()
        buildViews()
        configureTermsTableView()
        configureBillsTableView()
        bind()
    }
    
    func updateIndicatorView(with state: State) {
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: { 
            self.managerIndicatorView.snp.updateConstraints { make in
                make.leading.equalToSuperview().offset(state.indicatorXPosition(in: self))
                make.width.equalTo(self.frame.width / 3)
            }
            self.managerStackView.layoutIfNeeded()
        }, completion: nil)
    }
    
    func updateScrollView(with state: State) {
        self.scrollView.scrollRectToVisible(CGRect(x: state.scrollViewXPosition(in: self), y: 0, width: self.frame.width, height: 1), animated: true)
    }
    
    func updateTermsTableView() {
        termsTableView.snp.updateConstraints { make in
            make.width.equalTo(self.frame.width)
            make.height.equalTo(self.termsTableView.contentSize.height)
        }
        bioScrollView.layoutIfNeeded()
    }
    
    func configureTermsTableView() {
        termsTableView.isScrollEnabled = false
        termsTableView.register(TermTableViewCell.self, forCellReuseIdentifier: TermTableViewCell.identifier)
        termsTableView.rowHeight = 30
        termsTableView.separatorInset = .zero
        termsTableView.tableFooterView = UIView()
        termsTableView.backgroundColor = .clear
        termsTableView.allowsSelection = false
        
        termsDataSource.configureCell = { dataSource, tableView, indexPath, item in
            let basicCell = tableView.dequeueReusableCell(withIdentifier: TermTableViewCell.identifier, for: indexPath)
            guard let cell = basicCell as? TermTableViewCell else { fatalError() }
            cell.configure(with: item)
            return cell
        }
        
        termsDataSource.titleForHeaderInSection = { ds, index in
            return ds.sectionModels[index].model
        }
    }
    
    func configureVotesTableView() {
        votesTableView.register(TermTableViewCell.self, forCellReuseIdentifier: TermTableViewCell.identifier)
        votesTableView.rowHeight = 30
        votesTableView.separatorInset = .zero
        votesTableView.tableFooterView = UIView()
        votesTableView.backgroundColor = .clear
        votesTableView.allowsSelection = false
        
        votesDataSource.configureCell = { dataSource, tableView, indexPath, item in
            let basicCell = tableView.dequeueReusableCell(withIdentifier: TermTableViewCell.identifier, for: indexPath)
            guard let cell = basicCell as? TermTableViewCell else { fatalError() }
            //cell.configure(with: item)
            return cell
        }
        
        votesDataSource.titleForHeaderInSection = { ds, index in
            return ds.sectionModels[index].model
        }
        bioScrollView.showsVerticalScrollIndicator = false
    }
    
    func configureBillsTableView() {
        billsTableView.register(RepInfoBillSponsorTableViewCell.self, forCellReuseIdentifier: RepInfoBillSponsorTableViewCell.identifier)
        billsTableView.estimatedRowHeight = 45
        billsTableView.rowHeight = UITableViewAutomaticDimension
        billsTableView.separatorInset = .zero
        billsTableView.tableFooterView = UIView()
        billsTableView.backgroundColor = .clear
        billsTableView.allowsSelection = false
        
        billsDataSource.configureCell = { dataSource, tableView, indexPath, item in
            let basicCell = tableView.dequeueReusableCell(withIdentifier: RepInfoBillSponsorTableViewCell.identifier, for: indexPath)
            guard let cell = basicCell as? RepInfoBillSponsorTableViewCell else { fatalError() }
            cell.configure(with: item)
            return cell
        }
        
        billsDataSource.titleForHeaderInSection = { ds, index in
            return ds.sectionModels[index].model
        }
    }
}

extension RepInfoView: ViewBuilder {
    func buildViews() {
        buildManagerView()
        buildBaseScrollView()
        buildBaseStackView()
        buildBioView()
        buildVotesView()
        buildSponsoredView()
        
    }
    
    func buildManagerView() {
        addSubview(managerStackView)
        managerStackView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(25)
        }
        
        managerStackView.addSubview(managerIndicatorView)
        managerIndicatorView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.width.equalTo(self.frame.width / 3)
            make.height.equalTo(1)
            make.leading.equalToSuperview().offset(0)
        }
    }
    
    func buildBaseScrollView() {
        addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(self.managerStackView.snp.bottom).offset(3)
            make.leading.trailing.bottom.equalToSuperview()
        }
        layoutIfNeeded()
    }
    
    func buildBaseStackView() {
        scrollView.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        layoutIfNeeded()
    }
    
    func buildBioView() {
        stackView.addArrangedSubview(bioScrollView)
        bioScrollView.snp.makeConstraints { make in
            make.width.equalTo(self.scrollView.frame.width)
            make.height.equalTo(self.scrollView.frame.height)
        }
        layoutIfNeeded()
        
        bioScrollView.addSubview(bioStackView)
        bioStackView.snp.makeConstraints { make in
            make.width.equalTo(self.frame.width)
            make.edges.equalToSuperview()
        }
        layoutIfNeeded()
        
        let view = UIView()
        view.snp.makeConstraints { make in
            make.width.equalTo(self.frame.width)
            make.height.equalTo(1)
        }
        
        bioView.snp.makeConstraints { make in
            make.width.equalTo(self.frame.width)
        }

        termsTableView.snp.makeConstraints { make in
            make.width.equalTo(self.frame.width)
            make.height.equalTo(1)
        }

        bioStackView.addArrangedSubview(view)
        bioStackView.addArrangedSubview(bioView)
        bioStackView.addArrangedSubview(termsTableView)
        layoutIfNeeded()
    }
    
    func buildVotesView() {
        stackView.addArrangedSubview(votesTableView)
        layoutIfNeeded()
    }
    
    func buildSponsoredView() {
        stackView.addArrangedSubview(billsTableView)
        layoutIfNeeded()
    }
    
    func style() {
        managerStackView.axis = .horizontal
        managerStackView.alignment = .fill
        managerStackView.distribution = .fillEqually
        
        managerIndicatorView.backgroundColor = .kratosRed
        
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        
        scrollView.isScrollEnabled = false
        
        bioStackView.axis = .vertical
        bioStackView.alignment = .fill
        bioStackView.distribution = .fillProportionally
    }
}

extension RepInfoView: RxBinder {
    func bind() {
        bindManagerView()
        bindMainScrollView()
        bindBioView()
        bindBillsView()
    }
    
    func bindManagerView() {
        guard  let viewModel = viewModel else { return }
        let states = [State.bio, State.votes, State.bills]
        states.forEach { state in
            let button = state.button
            managerStackView.addArrangedSubview(button)
            button.rx.controlEvent(.touchUpInside).asObservable()
                .map { state }
                .bind(to: viewModel.state)
                .disposed(by: disposeBag)
        }
        
        managerStackView.bringSubview(toFront: managerIndicatorView)
        
        viewModel.state.asObservable()
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] state in
                self?.updateIndicatorView(with: state)
            })
            .disposed(by: disposeBag)
    }
    
    func bindMainScrollView() {
        guard  let viewModel = viewModel else { return }
        viewModel.state.asObservable()
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] state in
                self?.updateScrollView(with: state)
            })
            .disposed(by: disposeBag)
    }
    
    func bindBioView() {
        guard let viewModel = viewModel else { return }
        viewModel.bio.asObservable()
            .subscribe(onNext: { [weak self] bio in
                self?.bioView.configure(with:  nil, text: bio, expandedButtonTitle: "Show Less", contractedButtonTitle: "Show More")
            })
            .disposed(by: disposeBag)
        
        viewModel.terms.asObservable()
            .map { [SectionModel(model: "Terms", items: $0)] }
            .bind(to: termsTableView.rx.items(dataSource: termsDataSource))
            .disposed(by: disposeBag)
        
        viewModel.terms.asObservable()
            .subscribe(onNext: { [weak self] terms in
                self?.updateTermsTableView()
            })
            .disposed(by: disposeBag)
    }
    
    func bindBillsView() {
        guard let viewModel = viewModel else { return }
        viewModel.bills.asObservable()
            .map { [SectionModel(model: "", items: $0)] }
            .bind(to: billsTableView.rx.items(dataSource: billsDataSource))
            .disposed(by: disposeBag)
        
        billsTableView.rx.contentOffset.asObservable()
            .map { $0.y > (self.billsTableView.contentSize.height - self.billsTableView.frame.height - 100) }
            .distinctUntilChanged()
            .filter { $0 == true }
            .map { _ in () }
            .bind(to: viewModel.fetchAction)
            .disposed(by: disposeBag)
    }
}

func ==(lhs: RepInfoView.State, rhs: RepInfoView.State) -> Bool {
    switch (lhs, rhs) {
    case (.bio,  .bio), (.votes, .votes), (.bills, .bills):
        return true
    default:
        return false
    }
}

func !=(lhs: RepInfoView.State, rhs: RepInfoView.State) -> Bool {
    return !(lhs == rhs)
}
