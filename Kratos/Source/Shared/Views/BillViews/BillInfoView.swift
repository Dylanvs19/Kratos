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
    
    // MARK: - Enum -
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
    // Votes
    let votesTableView = UITableView()
    // Sponsors
    let sponsorsTableView = UITableView()
    // Details
    let detailsScrollView = UIScrollView()
    let committeesStackView = UIStackView()
    let actionsTableView = UITableView()
    
    let sponsorDataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, LightPerson>>()
    let voteDataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, Vote>>()
    
    convenience init(with client: Client, bill: Bill, contentOffset: Variable<CGFloat>) {
        self.init(frame: .zero)
        viewModel = BillInfoViewModel(with: bill)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func build() {
        style()
        addSubviews()
        constrainViews()
        configureVotesTableView()
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
    
    func updateVotesTableView() {
        votesTableView.snp.updateConstraints { make in
            make.width.equalTo(self.frame.width)
            make.height.equalTo(self.votesTableView.contentSize.height)
        }
        summaryScrollView.layoutIfNeeded()
    }
    
    func configureVotesTableView() {
        votesTableView.isScrollEnabled = false
        votesTableView.register(TermTableViewCell.self, forCellReuseIdentifier: TermTableViewCell.identifier)
        votesTableView.rowHeight = 30
        votesTableView.separatorInset = .zero
        votesTableView.tableFooterView = UIView()
        votesTableView.backgroundColor = .clear
        votesTableView.allowsSelection = false
        
        sponsorDataSource.configureCell = { dataSource, tableView, indexPath, item in
            let basicCell = tableView.dequeueReusableCell(withIdentifier: TermTableViewCell.identifier, for: indexPath)
            guard let cell = basicCell as? TermTableViewCell else { fatalError() }
//            cell.configure(with: item)
            return cell
        }
        
        sponsorDataSource.titleForHeaderInSection = { ds, index in
            return ds.sectionModels[index].model
        }
    }
}

extension BillInfoView: ViewBuilder {
    func addSubviews() {
        addSubview(managerStackView)
        managerStackView.addSubview(managerIndicatorView)
        addSubview(scrollView)
        scrollView.addSubview(stackView)
        stackView.addArrangedSubview(summaryScrollView)
        summaryScrollView.addSubview(summaryStackView)
        summaryStackView.addArrangedSubview(summaryView)
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
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        summaryScrollView.snp.makeConstraints { make in
            make.width.equalTo(self.scrollView.frame.width)
            make.height.equalTo(self.scrollView.frame.height)
        }
        summaryStackView.snp.makeConstraints { make in
            make.width.equalTo(self.frame.width)
            make.edges.equalToSuperview()
        }
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
    }
    
    func bindDetailsView() {
        guard let viewModel = viewModel else { return }
    }
    
    func bindSponsorsView() {
        guard let viewModel = viewModel else { return }
    }
    
    func bindVotesView() {
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
