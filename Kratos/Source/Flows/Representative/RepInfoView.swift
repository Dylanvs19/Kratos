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
    
    // MARK: - Enums -
    enum State: Equatable {
    case bio
    case votes
    case bills
        
        static let allValues: [State] = [.bio, .votes, .bills]
        
        var title: String {
            switch self {
            case .bio:
                return localize(.repInfoViewBioTitle)
            case .votes:
                return localize(.repInfoViewVotesTitle)
            case .bills:
                return localize(.repInfoViewBillsTitle)
            }
        }
        
        var button: UIButton {
            let button = UIButton()
            button.setTitle(title, for: .normal)
            button.style(with: [.font(.cellTitle),
                                .titleColor(.kratosRed),
                                .highlightedTitleColor(.red),
                                .backgroundColor(.white)])
            button.addShadow()
            return button
        }
        
        func scrollViewXPosition(in view: UIView) -> CGFloat {
            let width = view.frame.size.width
            return CGFloat(State.allValues.index(of: self)!) * width
        }
        
        func indicatorXPosition(in view: UIView) -> CGFloat {
            let width = view.frame.size.width / CGFloat(State.allValues.count)
            return CGFloat(State.allValues.index(of: self)!) * width
        }
    }
    
    // MARK: - Properties -
    
    var viewModel: RepInfoViewModel?
    let disposeBag = DisposeBag()
    
    let managerStackView = UIStackView()
    let managerIndicatorView = UIView()
    
    let scrollView = UIScrollView()
    let stackView = UIStackView()
    
    let bioViewView = UIView()
    let bioScrollView = UIScrollView()
    let bioView = ExpandableTextFieldView(forceCollapseToggleButton: false)
    let termsTableView = UITableView()
    
    let termsDataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, Term>>()
    let votesDataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, [LightTally]>>()
    let billsDataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, Bill>>()
    
    let votesTableView = UITableView()
    let billsTableView = UITableView()
    
    var contentOffset = PublishSubject<CGFloat>()
    var selectedBillID = PublishSubject<Int>()
    
    // MARK: - Initializers -
    convenience init(with client: Client, representative: Person) {
        self.init(frame: .zero)
        self.viewModel = RepInfoViewModel(with: client, representative: representative)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers -
    func buildViews() {
        
        configureTermsTableView()
        configureBillsTableView()
        configureVotesTableView()
        addSubviews()
        constrainViews()
        styleViews()
        
        layoutIfNeeded()
        bioView.build()
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
        self.scrollView.scrollRectToVisible(CGRect(x: state.scrollViewXPosition(in: self),
                                                   y: 0,
                                                   width: self.frame.width,
                                                   height: 1), animated: true)
    }
    
    // MARK: - Configuration -
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
        
        termsTableView.rx.setDelegate(self)
            .addDisposableTo(disposeBag)
    }
    
    func configureVotesTableView() {
        votesTableView.register(RepVoteTableViewCell.self, forCellReuseIdentifier: RepVoteTableViewCell.identifier)
        votesTableView.estimatedRowHeight = 500
        votesTableView.rowHeight = UITableViewAutomaticDimension
        votesTableView.separatorInset = .zero
        votesTableView.tableFooterView = UIView()
        votesTableView.backgroundColor = .clear
        
        
        votesDataSource.configureCell = { dataSource, tableView, indexPath, item in
            let basicCell = tableView.dequeueReusableCell(withIdentifier: RepVoteTableViewCell.identifier, for: indexPath)
            guard let cell = basicCell as? RepVoteTableViewCell else { fatalError() }
            cell.configure(with: item)
            return cell
        }
        
        votesDataSource.titleForHeaderInSection = { ds, index in
            return ds.sectionModels[index].model
        }
        
        votesTableView.showsVerticalScrollIndicator = false
    }
    
    func configureBillsTableView() {
        billsTableView.register(RepInfoBillSponsorTableViewCell.self, forCellReuseIdentifier: RepInfoBillSponsorTableViewCell.identifier)
        billsTableView.estimatedRowHeight = 45
        billsTableView.rowHeight = UITableViewAutomaticDimension
        billsTableView.separatorInset = .zero
        billsTableView.tableFooterView = UIView()
        billsTableView.backgroundColor = .clear
        
        billsDataSource.configureCell = { dataSource, tableView, indexPath, item in
            let basicCell = tableView.dequeueReusableCell(withIdentifier: RepInfoBillSponsorTableViewCell.identifier, for: indexPath)
            guard let cell = basicCell as? RepInfoBillSponsorTableViewCell else { fatalError() }
            cell.configure(with: item)
            return cell
        }
        
        billsDataSource.titleForHeaderInSection = { ds, index in
            return ds.sectionModels[index].model
        }
        
        votesTableView.showsVerticalScrollIndicator = false
    }
}

extension RepInfoView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if tableView == votesTableView {
            let view = UIView()
            let label = UILabel()
            view.addSubview(label)
            label.snp.makeConstraints { make in
                make.leading.equalToSuperview().offset(5)
                make.top.bottom.trailing.equalToSuperview()
            }
            label.text = votesDataSource.sectionModels[section].model
            label.style(with: [.font(.subheader)])
            return view
        }
        return nil 
    }
}

extension RepInfoView: ViewBuilder {
    func addSubviews() {
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(managerStackView)
        addSubview(scrollView)
        scrollView.addSubview(stackView)
        managerStackView.addSubview(managerIndicatorView)

        stackView.addArrangedSubview(bioScrollView)
        bioScrollView.addSubview(bioViewView)
        bioViewView.addSubview(bioView)
        bioViewView.addSubview(termsTableView)
        
        stackView.addArrangedSubview(votesTableView)
        stackView.addArrangedSubview(billsTableView)

    }
    func constrainViews() {
        managerStackView.snp.remakeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(25)
        }
        managerIndicatorView.snp.remakeConstraints { make in
            make.bottom.equalToSuperview()
            make.width.equalTo(self.frame.width / 3)
            make.height.equalTo(1)
            make.leading.equalToSuperview().offset(0)
        }
        
        scrollView.snp.remakeConstraints { make in
            make.top.equalTo(self.managerStackView.snp.bottom).offset(3)
            make.leading.trailing.bottom.equalToSuperview()
        }
        scrollView.layoutIfNeeded()

        stackView.snp.remakeConstraints { make in
            make.edges.equalToSuperview()
        }
        stackView.layoutIfNeeded()

        bioScrollView.snp.remakeConstraints { make in
            make.width.height.equalTo(self.scrollView)
        }
        bioScrollView.layoutIfNeeded()
        
        bioViewView.snp.remakeConstraints { make in
            make.edges.equalToSuperview()
        }
        bioView.snp.remakeConstraints { make in
            make.width.equalTo(self.frame.width)
            make.top.leading.trailing.equalToSuperview()
        }
        termsTableView.snp.remakeConstraints { make in
            make.width.equalTo(self.frame.width)
            make.top.equalTo(bioView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
            make.height.greaterThanOrEqualTo(5)
            make.height.equalTo(termsTableView.contentSize.height).priority(999)
        }
        
        layoutIfNeeded()
    }

    func styleViews() {
        managerStackView.axis = .horizontal
        managerStackView.alignment = .fill
        managerStackView.distribution = .fillEqually
        
        managerIndicatorView.backgroundColor = .kratosRed
        
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        
        scrollView.isScrollEnabled = false
        bioScrollView.showsVerticalScrollIndicator = false
    }
}

extension RepInfoView: RxBinder {
    func bind() {
        bindManagerView()
        bindMainScrollView()
        bindBioView()
        bindBillsView()
        bindVotesView()
    }
    
    func bindManagerView() {
        guard  let viewModel = viewModel else { return }
        State.allValues.forEach { state in
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
                self?.bioView.update(with: bio)
            })
            .disposed(by: disposeBag)
        
        viewModel.terms.asObservable()
            .map { [SectionModel(model: localize(.repInfoViewTermsSectionTitle), items: $0)] }
            .bind(to: termsTableView.rx.items(dataSource: termsDataSource))
            .disposed(by: disposeBag)
        viewModel.terms.asObservable()
            .delay(0.01, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.constrainViews()
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
        
        billsTableView.rx.itemSelected.asObservable()
            .map { self.billsDataSource[$0].id }
            .bind(to: selectedBillID)
            .disposed(by: disposeBag)
    }
    
    func bindVotesView() {
        guard let viewModel = viewModel else { return }
        viewModel.formattedTallies.asObservable()
            .map { $0.map { SectionModel(model: "\(DateFormatter.presentation.string(from: $0.key))", items: $0.value) } }
            .bind(to: votesTableView.rx.items(dataSource: votesDataSource))
            .disposed(by: disposeBag)
        
        votesTableView.rx.contentOffset.asObservable()
            .map { $0.y > (self.billsTableView.contentSize.height - self.billsTableView.frame.height - 100) }
            .distinctUntilChanged()
            .filter { $0 == true }
            .map { _ in () }
            .bind(to: viewModel.fetchAction)
            .disposed(by: disposeBag)
        
        votesTableView.rx.itemSelected.asObservable()
            .map { self.votesDataSource[$0].first?.billID }
            .filterNil()
            .bind(to: selectedBillID)
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
