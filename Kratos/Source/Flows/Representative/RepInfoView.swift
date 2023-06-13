//
//  RepInfoView.swift
//  Kratos
//
//  Created by Dylan Straughan on 1/13/17.
//  Copyright © 2017 Kratos, Inc. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxDataSources
import SnapKit

class RepInfoView: UIView {
    
    // MARK: - Enums -
    enum State: Int, Equatable {
    case bio = 0
    case votes = 1
    case bills = 2
        
        static let allValues: [State] = [.bio, .votes, .bills]
        
        var title: String {
            switch self {
            case .bio:
                return localize(.repInfoViewBioTitle)
            case .votes:
                return localize(.monospaceVotes)
            case .bills:
                return localize(.repInfoViewBillsTitle)
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
            let button = Button(style: .tab)
            button.setTitle(title, for: .normal)
            button.tag = self.rawValue
            return button
        }
    }
    
    // MARK: - Properties -
    var contentOffset = PublishSubject<CGFloat>()
    var selectedLightTally = PublishSubject<LightTally>()
    var selectedBill = PublishSubject<Bill>()
    var selectedState = PublishSubject<State>()
    
    fileprivate var viewModel: RepInfoViewModel
    fileprivate let disposeBag = DisposeBag()
    
    fileprivate let managerView = UIView()
    fileprivate let slideView = UIView()
    
    fileprivate let scrollView = UIScrollView()
    fileprivate let stackView = UIStackView()
    
    fileprivate let bioViewView = UIView()
    fileprivate let bioScrollView = UIScrollView()
    fileprivate let bioView = ExpandableTextFieldView(forceCollapseToggleButton: false)
    fileprivate let termsTableView = UITableView()
    
    fileprivate let termsDataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, Term>>()
    fileprivate let votesDataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, [LightTally]>>()
    fileprivate let billsDataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, Bill>>()
    
    fileprivate let votesTableView = UITableView(frame: .zero, style: .grouped)
    fileprivate let billsTableView = UITableView(frame: .zero, style: .grouped)
    
    fileprivate let buttons = State.allValues.map{ $0.button }
    
    // MARK: - Initializers -
    init(client: CongressService) {
        self.viewModel = RepInfoViewModel(with: client)
        super.init(frame: .zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(with rep: Person) {
        self.viewModel.update(with: rep)
    }
    
    // MARK: - Helpers -
    func build() {
        styleViews()
        addSubviews()
        layoutIfNeeded()
        
        bioView.build()
        
        configureTermsTableView()
        configureBillsTableView()
        configureVotesTableView()
        
        bind()
    }
    
    // MARK: - Configuration -
    func configureTermsTableView() {
        termsTableView.isScrollEnabled = false
        termsTableView.register(TermCell.self, forCellReuseIdentifier: TermCell.identifier)
        termsTableView.rowHeight = 30
        termsTableView.separatorInset = .zero
        termsTableView.tableFooterView = UIView()
        termsTableView.backgroundColor = .clear
        termsTableView.allowsSelection = false
        
        termsDataSource.configureCell = { dataSource, tableView, indexPath, item in
            let basicCell = tableView.dequeueReusableCell(withIdentifier: TermCell.identifier, for: indexPath)
            guard let cell = basicCell as? TermCell else { fatalError() }
            cell.configure(with: item)
            return cell
        }
        
        termsTableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
    }
    
    func configureVotesTableView() {
        votesTableView.register(RepVoteCell.self, forCellReuseIdentifier: RepVoteCell.identifier)
        votesTableView.estimatedRowHeight = 500
        votesTableView.rowHeight = UITableView.automaticDimension
        votesTableView.separatorInset = .zero
        votesTableView.tableFooterView = UIView()
        votesTableView.backgroundColor = .clear
        votesTableView.showsVerticalScrollIndicator = false
        votesTableView.sectionHeaderHeight = 40
        votesTableView.contentInset = UIEdgeInsets(top: -36, left: 0, bottom: 0, right: 0)

        votesDataSource.configureCell = { dataSource, tableView, indexPath, item in
            let basicCell = tableView.dequeueReusableCell(withIdentifier: RepVoteCell.identifier, for: indexPath)
            guard let cell = basicCell as? RepVoteCell else { fatalError() }
            cell.configure(with: item)
            return cell
        }
        
        votesTableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
    }
    
    func configureBillsTableView() {
        billsTableView.register(SponsoredBillCell.self, forCellReuseIdentifier: SponsoredBillCell.identifier)
        billsTableView.estimatedRowHeight = 45
        billsTableView.rowHeight = UITableView.automaticDimension
        billsTableView.separatorInset = .zero
        billsTableView.tableFooterView = UIView()
        billsTableView.backgroundColor = .clear
        billsTableView.showsVerticalScrollIndicator = false
        billsTableView.contentInset = UIEdgeInsets(top: -36, left: 0, bottom: 0, right: 0)

        billsDataSource.configureCell = { dataSource, tableView, indexPath, item in
            let basicCell = tableView.dequeueReusableCell(withIdentifier: SponsoredBillCell.identifier, for: indexPath)
            guard let cell = basicCell as? SponsoredBillCell else { fatalError() }
            cell.configure(with: item)
            return cell
        }
    }
    
    // MARK - Animations -
    func updateIndicatorView(with state: State) {
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
    
    func updateScrollView(with state: State) {
        self.scrollView.scrollRectToVisible(CGRect(x: state.scrollViewXPosition(in: self),
                                                   y: 0,
                                                   width: self.frame.width,
                                                   height: 1), animated: true)
    }
}

// MARK - UITableViewDelegate -
extension RepInfoView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let view = UIView()
        let label = UILabel()
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(10)
            make.top.trailing.bottom.equalToSuperview()
        }

        switch tableView {
        case votesTableView:
            guard votesDataSource.sectionModels.count > section else { return nil }
            label.text = votesDataSource.sectionModels[section].model
            label.style(with: [.font(.tab),
                               .backgroundColor(.white)])
        case termsTableView:
            guard termsDataSource.sectionModels.count > section else { return nil }
            label.text = termsDataSource.sectionModels[section].model
            label.style(with: [.font(.h2)])
        default:
            return nil
        }
        
        view.style(with: .backgroundColor(.white))

        return view
    }
}

// MARK - ViewBuilder -
extension RepInfoView: ViewBuilder {
    func styleViews() {}
    
    func addSubviews() {
        addManagerView()
        addManagerButtons()
        addSlideView()
        addMainScrollView()
        addMainStackView()
        addBioScrollView()
        addBioViewView()
        addBioView()
        addTermsTableView()
        addVotesTableView()
        addBillsTableView()
        layoutSubviews()
    }
    
    private func addManagerView() {
        addSubview(managerView)
        managerView.backgroundColor = .white

        managerView.snp.remakeConstraints { make in
            make.leading.top.trailing.equalToSuperview()
            make.height.equalTo(45)
        }
    }
    
    private func addManagerButtons() {
        buttons.forEach { button in
            managerView.addSubview(button)

            let count = CGFloat(State.allValues.count)
            button.snp.makeConstraints { make in
                switch button.tag {
                case 0: make.leading.equalToSuperview()
                case 1: make.centerX.equalToSuperview()
                default: make.trailing.equalToSuperview()
                }
                make.top.bottom.equalToSuperview()
                make.width.equalToSuperview().dividedBy(count)
                make.height.equalTo(Dimension.tabButtonHeight)
            }
        }
    }
    
    private func addSlideView() {
        managerView.addSubview(slideView)
        slideView.backgroundColor = .kratosRed
        managerView.bringSubviewToFront(slideView)

        slideView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.width.equalToSuperview().dividedBy(CGFloat(State.allValues.count))
            make.height.equalTo(2)
            make.leading.equalToSuperview().offset(0)
        }
    }
    
    private func addMainScrollView() {
        addSubview(scrollView)
        scrollView.isScrollEnabled = false

        scrollView.snp.makeConstraints { make in
            make.top.equalTo(self.managerView.snp.bottom).offset(5)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    private func addMainStackView() {
        scrollView.addSubview(stackView)
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually

        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func addBioScrollView() {
        stackView.addArrangedSubview(bioScrollView)
        bioScrollView.showsVerticalScrollIndicator = false

        bioScrollView.snp.makeConstraints { make in
            make.height.equalTo(self.scrollView)
            make.width.equalTo(self.frame.width)
        }
        bioScrollView.layoutIfNeeded()
    }
    
    private func addBioViewView() {
        bioScrollView.addSubview(bioViewView)

        bioViewView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func addBioView() {
        bioViewView.addSubview(bioView)

        bioView.snp.makeConstraints { make in
            make.width.equalTo(self.frame.width)
            make.top.leading.trailing.equalToSuperview()
        }
    }
    private func addTermsTableView() {
        bioViewView.addSubview(termsTableView)
        termsTableView.isScrollEnabled = false

        termsTableView.snp.makeConstraints { make in
            make.width.equalTo(self.frame.width)
            make.top.equalTo(bioView.snp.bottom).offset(10)
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(100)
        }
    }
    
    private func addVotesTableView() {
        stackView.addArrangedSubview(votesTableView)
        
    }
    
    private func addBillsTableView() {
        stackView.addArrangedSubview(billsTableView)
    }
}

// MARK - Binds -
extension RepInfoView: RxBinder {
    func bind() {
        bindManagerView()
        bindMainScrollView()
        bindBioView()
        bindBillsView()
        bindVotesView()
    }
    
    func bindManagerView() {
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
        
        viewModel.state
            .asObservable()
            .bind(to: selectedState)
            .disposed(by: disposeBag)
    }
    
    func bindMainScrollView() {
        viewModel.state
            .asObservable()
            .distinctUntilChanged()
            .subscribe(onNext: { [unowned self] in self.updateScrollView(with: $0) })
            .disposed(by: disposeBag)
    }
    
    func bindBioView() {
        viewModel.bio
            .asObservable()
            .subscribe(
                onNext: { [weak self] bio in
                    self?.bioView.update(with: bio)
                }
            )
            .disposed(by: disposeBag)
        
        viewModel.terms
            .asObservable()
            .map { [SectionModel(model: localize(.repInfoViewTermsSectionTitle), items: $0)] }
            .bind(to: termsTableView.rx.items(dataSource: termsDataSource))
            .disposed(by: disposeBag)
        
        termsTableView.rx.observe(CGSize.self, "contentSize")
            .filterNil()
            .subscribe(
                onNext: { [unowned self] size in
                    self.termsTableView.snp.updateConstraints{ make in
                        make.height.equalTo(1).offset(size.height)
                    }
                }
            )
            .disposed(by: disposeBag)
    }
    
    func bindBillsView() {
        viewModel.formattedBills.asObservable()
            .map { [SectionModel(model: "", items: $0)] }
            .bind(to: billsTableView.rx.items(dataSource: billsDataSource))
            .disposed(by: disposeBag)
        
        billsTableView.rx.contentOffset
            .asObservable()
            .map { $0.y > (self.billsTableView.contentSize.height - self.billsTableView.frame.height - 100) }
            .distinctUntilChanged()
            .filter { $0 == true }
            .map { _ in () }
            .bind(to: viewModel.fetchAction)
            .disposed(by: disposeBag)
        
        billsTableView.rx.modelSelected(Bill.self)
            .bind(to: selectedBill)
            .disposed(by: disposeBag)
    }
    
    func bindVotesView() {
        viewModel.formattedTallies
            .asObservable()
            .map { arrays in
                return arrays.map { array in
                    return SectionModel(model: DateFormatter.presentation.string(from: (array.first?.first?.date ?? Date())),  items: array) }
            }
            .bind(to: votesTableView.rx.items(dataSource: votesDataSource))
            .disposed(by: disposeBag)
        
        votesTableView.rx.contentOffset
            .asObservable()
            .map { $0.y > (self.votesTableView.contentSize.height - self.billsTableView.frame.height - 100) }
            .distinctUntilChanged()
            .filter { $0 == true }
            .map { _ in () }
            .bind(to: viewModel.fetchAction)
            .disposed(by: disposeBag)
        
        votesTableView.rx.modelSelected([LightTally].self)
            .map { $0.first }
            .filterNil()
            .bind(to: selectedLightTally)
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
