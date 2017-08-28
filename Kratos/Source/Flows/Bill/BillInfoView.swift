//
//  BillInfoView.swift
//  Kratos
//
//  Created by Dylan Straughan on 7/12/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//


import UIKit
import RxCocoa
import RxSwift
import RxDataSources
import SnapKit

class BillInfoView: UIView {
    
    // MARK: - Enums -
    enum State: Int, Equatable {
        case summary = 0
        case votes = 1
        case sponsors = 2
        case details = 3

        
        static let allValues: [State] = [.summary, .votes, .sponsors, .details]
        
        var displayName: String {
            switch self {
            case .summary:
                return localize(.billInfoViewSummaryTitle)
            case .votes:
                return localize(.billInfoViewVotesTitle)
            case .sponsors:
                return localize(.billInfoViewSponsorsTitle)
            case .details:
                return localize(.billInfoViewDetailsTitle)
            }
        }
        
        var button: UIButton {
            let button = UIButton()
            button.style(with: [.font(.cellTitle),
                                .titleColor(.kratosRed),
                                .highlightedTitleColor(.red),
                                .backgroundColor(.white)])
            button.setTitle(displayName, for: .normal)
            button.addShadow()
            return button
        }
        
        func scrollViewXPosition(in view: UIView) -> CGFloat {
            let width = view.frame.size.width
            return CGFloat(self.rawValue) * width
        }
        
        func indicatorXPosition(in view: UIView) -> CGFloat {
            let width = view.frame.size.width / CGFloat(State.allValues.count)
            return CGFloat(self.rawValue) * width
        }
    }
    
    // MARK: - Properties -
    // Standard
    var viewModel: BillInfoViewModel?
    let contentOffset = Variable<CGFloat>(0)
    let disposeBag = DisposeBag()
    
    // UIElements
    // Manager
    let managerStackView = UIStackView()
    let managerIndicatorView = UIView()
    // Base
    let stackView = UIStackView()
    // Summary
    let summaryScrollView = UIScrollView()
    let summaryViewView = UIView()
    let summaryView = ExpandableTextFieldView()
    let committeeStackView = UIStackView()
    // Votes
    let votesTableView = UITableView()
    // Sponsors
    let sponsorsTableView = UITableView()
    // Details
    let detailsScrollView = UIScrollView()
    let detailsContentView = UIView()
    let committeesStackView = UIStackView()
    let actionsTableView = UITableView()
    
    // DataSources
    let sponsorsDatasource = RxTableViewSectionedReloadDataSource<SectionModel<String, Person>>()
    let votesDatasource = RxTableViewSectionedReloadDataSource<SectionModel<String, Tally>>()
    
    // MARK: - Initializers -
    convenience init() {
        self.init(frame: .zero)
        viewModel = BillInfoViewModel()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Mark: - Update Method -
    func update(with bill: Bill) {
        viewModel?.update(with: bill)
    }
    
    // MARK: - Helpers -
    func build() {
        styleViews()
        configureVotesTableView()
        configureSponsorsTableView()
        addSubviews()
        constrainViews()
        
        layoutIfNeeded()
        summaryView.build()
        bind()
    }
    
    // MARK - Animations -
    func updateIndicatorView(with state: State) {
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
            self.managerIndicatorView.snp.remakeConstraints { make in
                make.bottom.equalToSuperview()
                make.width.equalTo(self.frame.width / CGFloat(State.allValues.count))
                make.height.equalTo(1)
                make.leading.equalToSuperview().offset(state.indicatorXPosition(in: self))
            }
            self.managerStackView.layoutIfNeeded()
        }, completion: nil)
    }
    
    func updateScrollView(with state: State) {
        UIView.animate(withDuration: 0.4) { 
            self.stackView.snp.updateConstraints { make in
                make.leading.equalToSuperview().offset(-state.scrollViewXPosition(in: self))
            }
            self.layoutIfNeeded()
        }
    }
    
    // MARK: - Configuration -
    func configureVotesTableView() {
        votesTableView.isScrollEnabled = false
        votesTableView.register(TallyCell.self, forCellReuseIdentifier: TallyCell.identifier)
        votesTableView.estimatedRowHeight = 100
        votesTableView.rowHeight = UITableViewAutomaticDimension
        votesTableView.separatorInset = .zero
        votesTableView.tableFooterView = UIView()
        votesTableView.backgroundColor = .clear
        votesTableView.allowsSelection = false
        
        votesDatasource.configureCell = { dataSource, tableView, indexPath, item in
            let basicCell = tableView.dequeueReusableCell(withIdentifier: TallyCell.identifier, for: indexPath)
            guard let cell = basicCell as? TallyCell else { fatalError() }
            cell.configure(with: item)
            return cell
        }
        
        votesDatasource.titleForHeaderInSection = { ds, index in
            return ds.sectionModels[index].model
        }
    }
    
    // MARK: - Configuration -
    func configureSponsorsTableView() {
        sponsorsTableView.isScrollEnabled = false
        sponsorsTableView.register(RepresentativeCell.self, forCellReuseIdentifier: RepresentativeCell.identifier)
        sponsorsTableView.estimatedRowHeight = 100
        sponsorsTableView.rowHeight = UITableViewAutomaticDimension
        sponsorsTableView.separatorInset = .zero
        sponsorsTableView.tableFooterView = UIView()
        sponsorsTableView.backgroundColor = .clear
        sponsorsTableView.allowsSelection = false
        
        sponsorsDatasource.configureCell = { dataSource, tableView, indexPath, item in
            let basicCell = tableView.dequeueReusableCell(withIdentifier: RepresentativeCell.identifier, for: indexPath)
            guard let cell = basicCell as? RepresentativeCell else { fatalError() }
            cell.update(with: item)
            return cell
        }
    }
}

// MARK - UITableViewDelegate -
extension BillInfoView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var labelText = ""
        
        switch tableView {
        case sponsorsTableView:
            labelText = sponsorsDatasource.sectionModels[section].model
        default:
            return nil
        }
        
        let view = UIView()
        let label = UILabel()
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(5)
            make.top.bottom.trailing.equalToSuperview()
        }
        label.text = labelText
        view.style(with: .backgroundColor(.slate))
        label.style(with: [.font(.subTitle)])
        return view
    }
}

extension BillInfoView: ViewBuilder {
    func addSubviews() {
        translatesAutoresizingMaskIntoConstraints = false

        addSubview(managerStackView)
        managerStackView.addSubview(managerIndicatorView)
        
        addSubview(stackView)
        stackView.addArrangedSubview(summaryScrollView)
        stackView.addArrangedSubview(votesTableView)
        stackView.addArrangedSubview(sponsorsTableView)
        stackView.addArrangedSubview(detailsScrollView)
        
        summaryScrollView.addSubview(summaryView)
        detailsScrollView.addSubview(detailsContentView)
    }
    
    func constrainViews() {
        managerStackView.snp.remakeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(25)
        }
        managerIndicatorView.snp.remakeConstraints { make in
            make.bottom.equalToSuperview()
            make.width.equalTo(self.frame.width / CGFloat(State.allValues.count))
            make.height.equalTo(1)
            make.leading.equalToSuperview().offset(0)
        }
        stackView.snp.remakeConstraints { make in
            make.leading.equalToSuperview()
            make.bottom.equalToSuperview()
            make.top.equalTo(managerStackView.snp.bottom).offset(3)
        }
        summaryScrollView.snp.remakeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.width.equalTo(self.snp.width)
        }
        votesTableView.snp.remakeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.width.equalTo(self.snp.width)
        }
        sponsorsTableView.snp.remakeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.width.equalTo(self.snp.width)
        }
        detailsScrollView.snp.remakeConstraints { make in
            make.top.bottom.trailing.equalToSuperview()
            make.width.equalTo(self.snp.width)
        }
        summaryView.snp.remakeConstraints { make in
            make.width.equalTo(self.snp.width)
            make.edges.equalToSuperview()
        }
        detailsContentView.snp.remakeConstraints { make in
            make.edges.equalToSuperview()
        }
        summaryView.layoutIfNeeded()
        summaryScrollView.layoutIfNeeded()
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
        
        summaryScrollView.showsVerticalScrollIndicator = false
        detailsScrollView.showsVerticalScrollIndicator = false
        
        stackView.layoutIfNeeded()
        clipsToBounds = true
    }
}

extension BillInfoView: RxBinder {
    func bind() {
        bindManagerView()
        bindMainScrollView()
        bindSummaryView()
        bindDetailsView()
        bindVotesView()
        bindSponsorsView()
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
    
    func bindSummaryView() {
        guard let viewModel = viewModel else { return }
        viewModel.summary.asObservable()
            .subscribe(onNext: { [weak self] summary in
                self?.summaryView.update(with: summary)
            })
            .disposed(by: disposeBag)
    }
    func bindVotesView() {
        guard let viewModel = viewModel else { return }
        viewModel.tallies.asObservable()
            .map { [SectionModel(model: "", items: $0)] }
            .bind(to: votesTableView.rx.items(dataSource: votesDatasource))
            .disposed(by: disposeBag)
    }
    func bindSponsorsView() {
        guard let viewModel = viewModel else { return }
        viewModel.sponsors.asObservable()
            .map { $0.map { SectionModel(model: $0.key, items: $0.value) } }
            .bind(to: sponsorsTableView.rx.items(dataSource: sponsorsDatasource))
            .disposed(by: disposeBag)
    }
    func bindDetailsView() {
        guard let viewModel = viewModel else { return }
        
    }
}

func ==(lhs: BillInfoView.State, rhs: BillInfoView.State) -> Bool {
    switch (lhs, rhs) {
    case (.summary,  .summary), (.votes, .votes), (.sponsors, .sponsors):
        return true
    default:
        return false
    }
}

func !=(lhs: BillInfoView.State, rhs: BillInfoView.State) -> Bool {
    return !(lhs == rhs)
}
