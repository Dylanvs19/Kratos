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

class BillInfoView: UIView, CurtainPresenter {
    
    // MARK: - Enums -
    enum State: Int, Equatable {
        case summary = 0
        case votes = 1
        case sponsors = 2
        case details = 3

        
        static let allValues: [State] = [.summary, .votes, .sponsors, .details]
        
        var title: String {
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
        
        func scrollViewXPosition(in view: UIView) -> CGFloat {
            let width = view.frame.size.width
            return CGFloat(self.rawValue) * width
        }
        
        func indicatorXPosition(in view: UIView) -> CGFloat {
            let width = view.frame.size.width / CGFloat(State.allValues.count)
            return CGFloat(self.rawValue) * width
        }
        
        var button: UIButton {
            let button = UIButton()
            button.setTitle(title, for: .normal)
            button.style(with: [.font(.tab),
                                .titleColor(.kratosRed),
                                .highlightedTitleColor(.red)
                ])
            button.tag = self.rawValue
            return button
        }
    }
    
    // MARK: - Properties -
    // Standard
    fileprivate var viewModel: BillInfoViewModel?
    fileprivate let disposeBag = DisposeBag()
    var curtain: Curtain = Curtain()
    //Open
    let contentOffset = PublishSubject<CGFloat>()
    let selectedPerson = PublishSubject<Person>()
    let selectedTally = PublishSubject<Tally>()
    let selectedState = PublishSubject<State>()
    
    // UIElements
    // Manager
    fileprivate let managerView = UIView()
    fileprivate let slideView = UIView()
    // Base
    fileprivate let scrollView = UIScrollView()
    fileprivate let scrollViewView = UIView()
    // Summary
    fileprivate let summaryScrollView = UIScrollView()
    fileprivate let summaryViewView = UIView()
    fileprivate let summaryView = ExpandableTextFieldView()
    fileprivate let committeeStackView = UIStackView()
    // Votes
    fileprivate let votesTableView = UITableView()
    fileprivate let votesEmptyLabel = UILabel()
    // Sponsors
    fileprivate let sponsorsTableView = UITableView()
    // Details
    fileprivate let detailsTableView = UITableView()
//    fileprivate let detailsScrollView = UIScrollView()
//    fileprivate let detailsContentView = UIView()
    fileprivate let committeesStackView = UIStackView()
    fileprivate let actionsTableView = UITableView()
    
    fileprivate let buttons = State.allValues.map{ $0.button }
    
    // DataSources
    fileprivate let sponsorsDatasource = RxTableViewSectionedReloadDataSource<SectionModel<String, Person>>()
    fileprivate let votesDatasource = RxTableViewSectionedReloadDataSource<SectionModel<String, Tally>>()
    
    //Constants
    fileprivate var maxSummaryExpansion: CGFloat = 300
    
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
        configureVotesTableView()
        configureSponsorsTableView()
        configureDetailsTableView()
        localizeStrings()
        addSubviews()
        constrainViews()
        styleViews()
        layoutIfNeeded()
        summaryView.set(contractedHeight: 200, expandedHeight: (summaryScrollView.frame.height - 85))
        summaryView.build()
        addCurtain()
        bind()
        layoutIfNeeded()
    }
    
    // MARK: - Configuration -
    fileprivate func configureVotesTableView() {
        votesTableView.register(TallyCell.self, forCellReuseIdentifier: TallyCell.identifier)
        votesTableView.estimatedRowHeight = 150
        votesTableView.rowHeight = UITableViewAutomaticDimension
        votesTableView.separatorInset = .zero
        votesTableView.tableFooterView = UIView()
        votesTableView.backgroundColor = .clear
        
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
    fileprivate func configureSponsorsTableView() {
        sponsorsTableView.register(RepresentativeCell.self, forCellReuseIdentifier: RepresentativeCell.identifier)
        sponsorsTableView.estimatedRowHeight = 100
        sponsorsTableView.rowHeight = UITableViewAutomaticDimension
        sponsorsTableView.separatorInset = .zero
        sponsorsTableView.tableFooterView = UIView()
        sponsorsTableView.backgroundColor = .clear
        
        sponsorsDatasource.configureCell = { dataSource, tableView, indexPath, item in
            let basicCell = tableView.dequeueReusableCell(withIdentifier: RepresentativeCell.identifier, for: indexPath)
            guard let cell = basicCell as? RepresentativeCell else { fatalError() }
            cell.update(with: item)
            return cell
        }
    }
    
    fileprivate func configureDetailsTableView() {
        detailsTableView.register(DetailCell.self, forCellReuseIdentifier: DetailCell.identifier)
        detailsTableView.estimatedRowHeight = 100
        detailsTableView.rowHeight = UITableViewAutomaticDimension
        detailsTableView.separatorInset = .zero
        detailsTableView.tableFooterView = UIView()
        detailsTableView.backgroundColor = .clear
    }
    
    // MARK - Animations -
    fileprivate func updateIndicatorView(with state: State) {
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
            self.slideView.snp.remakeConstraints { make in
                make.bottom.equalToSuperview()
                make.width.equalTo(self.managerView.frame.width / CGFloat(State.allValues.count))
                make.height.equalTo(2)
                make.leading.equalToSuperview().offset(state.indicatorXPosition(in: self.managerView))
            }
            self.layoutIfNeeded()
        }, completion: nil)
    }
    
    fileprivate func updateScrollView(with state: State) {
        self.scrollView.scrollRectToVisible(CGRect(x: state.scrollViewXPosition(in: self),
                                                   y: 0,
                                                   width: self.frame.width,
                                                   height: 1), animated: true)
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
//        translatesAutoresizingMaskIntoConstraints = false

        addSubview(managerView)
        buttons.forEach { managerView.addSubview($0) }
        managerView.addSubview(slideView)
        
        addSubview(scrollView)
        scrollView.addSubview(scrollViewView)
        
        scrollViewView.addSubview(summaryScrollView)
        scrollViewView.addSubview(votesTableView)
        scrollViewView.addSubview(votesEmptyLabel)
        scrollViewView.addSubview(sponsorsTableView)
        scrollViewView.addSubview(detailsTableView)
        
        summaryScrollView.addSubview(summaryView)
//        detailsScrollView.addSubview(detailsContentView)
    }
    
    func constrainViews() {
        managerView.snp.remakeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(45)
        }
        managerView.layoutIfNeeded()
        buttons.forEach { button in
            let count = CGFloat(State.allValues.count)
            let width = managerView.frame.width/count
            button.snp.remakeConstraints { make in
                make.leading.equalTo(width * CGFloat(button.tag))
                make.top.bottom.equalToSuperview()
                make.width.equalToSuperview().dividedBy(count)
            }
        }
        slideView.snp.remakeConstraints { make in
            make.bottom.equalToSuperview()
            make.width.equalToSuperview().dividedBy(CGFloat(State.allValues.count))
            make.height.equalTo(1)
            make.leading.equalToSuperview().offset(0)
        }
        self.layoutIfNeeded()
        scrollView.snp.remakeConstraints { make in
            make.top.equalTo(self.managerView.snp.bottom).offset(5)
            make.leading.trailing.bottom.equalToSuperview()
        }
        scrollViewView.snp.remakeConstraints { make in
            make.width.equalTo(self.snp.width).multipliedBy(4)
            make.height.equalTo(scrollView.snp.height)
            make.edges.equalToSuperview()
        }
        summaryScrollView.snp.remakeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.width.equalTo(self.snp.width)
        }
        votesTableView.snp.remakeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalTo(summaryScrollView.snp.trailing)
            make.width.equalTo(self.snp.width)
        }
        votesEmptyLabel.snp.remakeConstraints { make in
            make.centerX.centerY.equalTo(votesTableView)
            make.width.equalTo(votesTableView.snp.width).offset(-40)
        }
        sponsorsTableView.snp.remakeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalTo(votesTableView.snp.trailing)
            make.width.equalTo(self.snp.width)
        }
        detailsTableView.snp.remakeConstraints { make in
            make.top.bottom.trailing.equalToSuperview()
            make.leading.equalTo(sponsorsTableView.snp.trailing)
            make.width.equalTo(self.snp.width)
        }
        summaryView.snp.remakeConstraints { make in
            make.width.equalTo(self.snp.width)
            make.edges.equalToSuperview()
        }
//        detailsContentView.snp.remakeConstraints { make in
//            make.edges.equalToSuperview()
//        }
        summaryView.layoutIfNeeded()
        summaryScrollView.layoutIfNeeded()
        layoutIfNeeded()
    }
    
    func styleViews() {
        managerView.style(with: .backgroundColor(.white))
        managerView.addShadow()
        slideView.style(with: .backgroundColor(.kratosRed))
        managerView.bringSubview(toFront: slideView)
        votesEmptyLabel.style(with: [.font(.subHeader),
                                     .titleColor(.kratosRed),
                                     .numberOfLines(3),
                                     .textAlignment(.center)])
        
        scrollView.isScrollEnabled = false
        votesTableView.translatesAutoresizingMaskIntoConstraints = false 
        summaryScrollView.showsVerticalScrollIndicator = false
        detailsTableView.showsVerticalScrollIndicator = false
        sponsorsTableView.showsVerticalScrollIndicator = false
    }
}


// MARK: - Localize -
extension BillInfoView: Localizer {
    func localizeStrings() {
        votesEmptyLabel.text = localize(.billInfoViewVotesEmptyTitle)
    }
}
// MARK: - Bind -
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
        
        buttons.forEach { button in
            button.rx.tap
                .map { _ in State(rawValue: button.tag) }
                .filterNil()
                .bind(to: viewModel.state)
                .disposed(by: disposeBag)
        }
        
        viewModel.state
            .asObservable()
            .distinctUntilChanged()
            .subscribe(
                onNext: { [weak self] state in
                    self?.updateIndicatorView(with: state)
                }
            )
            .disposed(by: disposeBag)
    }
    
    func bindMainScrollView() {
        guard  let viewModel = viewModel else { return }
        
        viewModel.state
            .asObservable()
            .distinctUntilChanged()
            .subscribe(
                onNext: { [weak self] state in
                    self?.updateScrollView(with: state)
                }
            )
            .disposed(by: disposeBag)
        viewModel.loadStatus
            .asObservable()
            .bind(to: curtain.loadStatus)
            .disposed(by: disposeBag)
    }
    
    func bindSummaryView() {
        guard let viewModel = viewModel else { return }
        
        viewModel.summary
            .asObservable()
            .subscribe(
                onNext: { [weak self] summary in
                    self?.summaryView.update(with: summary)
                }
            )
            .disposed(by: disposeBag)
    }
    
    func bindVotesView() {
        guard let viewModel = viewModel else { return }
        viewModel.tallies
            .asObservable()
            .map { [SectionModel(model: "", items: $0)] }
            .bind(to: votesTableView.rx.items(dataSource: votesDatasource))
            .disposed(by: disposeBag)
        viewModel.tallies
            .asObservable()
            .map { !$0.isEmpty }
            .bind(to: votesEmptyLabel.rx.isHidden)
            .disposed(by: disposeBag)
        votesTableView.rx.modelSelected(Tally.self).asObservable()
            .bind(to: selectedTally)
            .disposed(by: disposeBag)
    }
    
    func bindSponsorsView() {
        guard let viewModel = viewModel else { return }
        
        viewModel.sponsors
            .asObservable()
            .map { $0.map { SectionModel(model: $0.key, items: $0.value) } }
            .bind(to: sponsorsTableView.rx.items(dataSource: sponsorsDatasource))
            .disposed(by: disposeBag)
        sponsorsTableView.rx.modelSelected(Person.self)
            .bind(to: selectedPerson)
            .disposed(by: disposeBag)
    }
    
    func bindDetailsView() {
        guard let viewModel = viewModel else { return }
        viewModel.details
            .asObservable()
            .bind(to: detailsTableView.rx.items(cellIdentifier: DetailCell.identifier, cellType: DetailCell.self)) { row, data, cell in
                cell.configure(with: data)
            }
            .disposed(by: disposeBag)
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

extension Reactive where Base: BillInfoView {
    var bill: UIBindingObserver<Base, Bill> {
        return UIBindingObserver(UIElement: self.base, binding: { (view, bill) in
            view.update(with: bill)
        })
    }
}
