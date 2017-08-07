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
    enum State: Equatable {
        case sponsors
        case summary
        case details
        case votes
        
        static var allValues: [State] = [.summary, .votes, .sponsors, .details]
        
        var displayName: String {
            switch self {
            case .summary:
                return "Summary"
            case .votes:
                return "Votes"
            case .sponsors:
                return "Sponsors"
            case .details:
                return "Details"
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
            switch self {
            case .summary:
                return 0
            case .votes:
                return view.frame.size.width
            case .sponsors:
                return view.frame.size.width * 2
            case .details:
                return view.frame.size.width * 3
            }
        }
        
        func indicatorXPosition(in view: UIView) -> CGFloat {
            let width = view.frame.size.width / CGFloat(State.allValues.count)
            switch self {
            case .summary:
                return 0
            case .votes:
                return width
            case .sponsors:
                return width * 2
            case .details:
                return width * 3
            }
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
    let scrollView = UIScrollView()
    let stackView = UIStackView()
    // Summary
    let summaryScrollView = UIScrollView()
    let summaryStackView = UIStackView()
    let summaryView = ExpandableTextFieldView()
    let committeeStackView = UIStackView()
    // Votes
    let votesTableView = UITableView()
    // Sponsors
    let sponsorsTableView = UITableView()
    // Details
    let detailsScrollView = UIScrollView()
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
        addSubviews()
        constrainViews()
        configureVotesTableView()
        configureSponsorsTableView()
        bind()
    }
    
    func updateIndicatorView(with state: State) {
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
            self.managerIndicatorView.snp.updateConstraints { make in
                make.leading.equalToSuperview().offset(state.indicatorXPosition(in: self))
                make.width.equalTo(self.frame.width / CGFloat(State.allValues.count))
            }
            self.managerStackView.layoutIfNeeded()
        }, completion: nil)
    }
    
    func updateScrollView(with state: State) {
        self.scrollView.scrollRectToVisible(CGRect(x: state.scrollViewXPosition(in: self), y: 0, width: self.frame.width, height: 1), animated: true)
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
        
        sponsorsDatasource.titleForHeaderInSection = { ds, index in
            return ds.sectionModels[index].model
        }
    }
}

extension BillInfoView: ViewBuilder {
    func addSubviews() {
        translatesAutoresizingMaskIntoConstraints = false

        addSubview(managerStackView)
        addSubview(scrollView)
        scrollView.addSubview(stackView)
        managerStackView.addSubview(managerIndicatorView)
        
        stackView.addArrangedSubview(summaryScrollView)
        summaryScrollView.addSubview(summaryStackView)
        
        summaryStackView.addArrangedSubview(summaryView)
        summaryStackView.addSubview(committeeStackView)
        
        stackView.addArrangedSubview(votesTableView)
        stackView.addArrangedSubview(sponsorsTableView)
    }
    func constrainViews() {
        managerStackView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(25)
        }
        managerIndicatorView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.width.equalTo(self.frame.width / 3)
            make.height.equalTo(1)
            make.leading.equalToSuperview().offset(0)
        }
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(self.managerStackView.snp.bottom).offset(3)
            make.leading.trailing.bottom.equalToSuperview()
        }
        scrollView.layoutIfNeeded()
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        stackView.layoutIfNeeded()
        summaryScrollView.snp.remakeConstraints { make in
            make.width.height.equalTo(self.scrollView)
        }
        summaryScrollView.layoutIfNeeded()

        summaryStackView.snp.remakeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(self.frame.width)
        }
        summaryStackView.layoutIfNeeded()
        
        summaryView.snp.remakeConstraints { make in
            make.width.equalTo(self.frame.width)
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
        
        summaryStackView.axis = .vertical
        summaryStackView.alignment = .fill
        summaryStackView.distribution = .fillProportionally
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
