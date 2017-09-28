//
//  TallyController.swift
//  Kratos
//
//  Created by Dylan Straughan on 9/5/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import SnapKit

class TallyController: UIViewController {
    
    // MARK: - Enums -
    enum State: Int {
        case votes = 0
        case details = 1
        
        static let allValues: [State] = [.votes, .details]
        
        var title: String {
            switch self {
            case .votes:
                return localize(.tallyVotesTitle)
            case .details:
                return localize(.tallyDetailsTitle)
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
            button.style(with: [.font(.tab),
                                .titleColor(.kratosRed),
                                .highlightedTitleColor(.red),
                                ])
            button.setTitle(title, for: .normal)
            button.tag = self.rawValue
            return button
        }
    }
    
    // MARK: - Variables -
    // Standard
    let client: Client
    let viewModel: TallyViewModel
    let disposeBag = DisposeBag()

    let topView = UIView()
    
    let pieChartView = PieChartView()
    let titleLabel = UILabel()
    let statusLabel = UILabel()
    let statusDateLabel = UILabel()
    
    // TopView
    let managerView = UIView()
    let slideView = UIView()
    let buttons: [UIButton] = State.allValues.map { $0.button }
    
    // Base
    let infoView = UIView()
    let scrollView = UIScrollView()
    let scrollViewView = UIView()
    
    let votesTableView = UITableView()
    let detailsTableView = UITableView()
    
    // MARK: - Initializers -
    init(client: Client, tally: LightTally) {
        self.client = client
        self.viewModel = TallyViewModel(client: client, lightTally: tally)
        super.init(nibName: nil, bundle: nil)
    }
    
    init(client: Client, tally: Tally) {
        self.client = client
        self.viewModel = TallyViewModel(client: client, tally: tally)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        edgesForExtendedLayout = [.top, .right, .left]
        configureVotesTableView()
        configureDetailsTableView()
        addSubviews()
        constrainViews()
        styleViews()
        bind()
        view.layoutIfNeeded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setDefaultNavVC()
        self.title = ""
        topView.addShadow()
        managerView.addShadow()
        infoView.addShadow()
        view.layoutIfNeeded()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // MARK: - Configuration -
    fileprivate func configureVotesTableView() {
        votesTableView.register(RepresentativeCell.self, forCellReuseIdentifier: RepresentativeCell.identifier)
        votesTableView.estimatedRowHeight = 100
        votesTableView.rowHeight = UITableViewAutomaticDimension
        votesTableView.separatorInset = .zero
        votesTableView.tableFooterView = UIView()
        votesTableView.backgroundColor = .clear
    }
    
    fileprivate func configureDetailsTableView() {
        detailsTableView.register(DetailCell.self, forCellReuseIdentifier: DetailCell.identifier)
        detailsTableView.estimatedRowHeight = 100
        detailsTableView.rowHeight = UITableViewAutomaticDimension
        detailsTableView.separatorInset = .zero
        detailsTableView.tableFooterView = UIView()
        detailsTableView.backgroundColor = .clear
    }
    
    // MARK: - Animations -
    fileprivate func update(with state: State, animate: Bool = true) {
        if animate {
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
            self.slideView.snp.remakeConstraints { make in
                make.bottom.equalToSuperview()
                make.width.equalTo(self.managerView.frame.width / CGFloat(State.allValues.count))
                make.height.equalTo(2)
                make.leading.equalToSuperview().offset(state.indicatorXPosition(in: self.managerView))
            }
            self.view.layoutIfNeeded()
        }, completion: nil)
        } else {
            self.slideView.snp.remakeConstraints { make in
                make.bottom.equalToSuperview()
                make.width.equalTo(self.managerView.frame.width / CGFloat(State.allValues.count))
                make.height.equalTo(2)
                make.leading.equalToSuperview().offset(state.indicatorXPosition(in: self.managerView))
            }
            self.view.layoutIfNeeded()
        }
        updateScrollView(with: state)
    }
    
    // MARK: - Helpers -
    fileprivate func updateScrollView(with state: State) {
        let width = scrollView.frame.width
        self.scrollView.scrollRectToVisible(CGRect(x: state.scrollViewXPosition(in: scrollView),
                                                   y: 0,
                                                   width: width,
                                                   height: 1), animated: true)
    }
}

// MARK: - View Builder -
extension TallyController: ViewBuilder {
    func addSubviews() {
        view.addSubview(topView)
        topView.addSubview(titleLabel)
        topView.addSubview(statusLabel)
        topView.addSubview(statusDateLabel)
        topView.addSubview(pieChartView)
        
        view.addSubview(managerView)
        buttons.forEach { managerView.addSubview($0) }
        managerView.addSubview(slideView)
        
        view.addSubview(infoView)
        infoView.addSubview(scrollView)
        scrollView.addSubview(scrollViewView)
        
        scrollViewView.addSubview(votesTableView)
        scrollViewView.addSubview(detailsTableView)
    }
    
    func constrainViews() {
        topView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        titleLabel.snp.remakeConstraints { make in
            make.top.equalToSuperview().inset(25)
            make.leading.trailing.equalToSuperview().inset(40)
        }
        pieChartView.snp.remakeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(5)
            make.height.width.equalTo(100)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(5)
        }
        
        managerView.snp.remakeConstraints { make in
            make.top.equalTo(topView.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(10)
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
            make.leading.bottom.equalToSuperview()
            make.width.equalToSuperview().dividedBy(3)
            make.height.equalTo(2)
        }
        infoView.snp.remakeConstraints { make in
            make.top.equalTo(managerView.snp.bottom).offset(10)
            make.trailing.leading.equalToSuperview().inset(10)
            make.bottom.equalTo(bottomLayoutGuide.snp.top)
        }
        scrollView.snp.remakeConstraints { make in
            make.edges.equalToSuperview()
        }
        scrollViewView.snp.remakeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView.snp.width).multipliedBy(2)
            make.height.equalTo(scrollView.snp.height)
        }
        votesTableView.snp.remakeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.width.equalTo(scrollView.snp.width)
        }
        detailsTableView.snp.remakeConstraints { make in
            make.leading.equalTo(votesTableView.snp.trailing)
            make.trailing.top.bottom.equalToSuperview()
            make.width.equalTo(scrollView.snp.width)
        }
    }
    
    func styleViews() {
        view.style(with: .backgroundColor(.slate))
        infoView.style(with: .backgroundColor(.white))
        topView.style(with: .backgroundColor(.white))
        managerView.style(with: .backgroundColor(.white))
        slideView.style(with: .backgroundColor(.kratosRed))
        titleLabel.style(with: [.font(.cellTitle),
                                .numberOfLines(5),
                                .textAlignment(.center)])
        statusLabel.style(with: [.font(.body),
                                 .titleColor(.gray)])
        statusDateLabel.style(with: [.font(.body),
                                     .titleColor(.gray)])
    }
}

// MARK: - Binds  -
extension TallyController: RxBinder {
    func bind() {
        buttons.forEach { button in
            button.rx.tap
                .map { _ in State(rawValue: button.tag) }
                .filterNil()
                .bind(to: viewModel.state)
                .disposed(by: disposeBag)
        }
        viewModel.state
            .asObservable()
            .take(1)
            .subscribe(
                onNext: { [weak self] state in
                    self?.update(with: state, animate: false)
                }
            )
            .disposed(by: disposeBag)
        viewModel.state
            .asObservable()
            .skip(1)
            .subscribe(
                onNext: { [weak self] state in
                    self?.update(with: state)
                }
            )
            .disposed(by: disposeBag)
        viewModel.votes
            .asObservable()
            .bind(to: votesTableView.rx.items(cellIdentifier: RepresentativeCell.identifier, cellType: RepresentativeCell.self)) { row, data, cell in
                cell.update(with: data)
            }
            .disposed(by: disposeBag)
        viewModel.details
            .asObservable()
            .bind(to: detailsTableView.rx.items(cellIdentifier: DetailCell.identifier, cellType: DetailCell.self)) { row, data, cell in
                cell.configure(with: data)
            }
            .disposed(by: disposeBag)
        votesTableView.rx.modelSelected(Vote.self)
            .asObservable()
            .map { $0.person }
            .filterNil()
            .subscribe(onNext: { [weak self] rep in
                guard let `self` = self else { fatalError("self deallocated before it was accessed") }
                let vc = RepresentativeController(client: self.client, representative: rep)
                self.navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: disposeBag)
        viewModel.pieChartData
            .asObservable()
            .filterNil()
            .filter { !$0.isEmpty }
            .bind(to: pieChartView.rx.data)
            .disposed(by: disposeBag)
        viewModel.title
            .asObservable()
            .bind(to: titleLabel.rx.text)
            .disposed(by: disposeBag)
        viewModel.status
            .asObservable()
            .bind(to: statusLabel.rx.text)
            .disposed(by: disposeBag)
        viewModel.statusDate
            .asObservable()
            .bind(to: statusDateLabel.rx.text)
            .disposed(by: disposeBag)
    }
}
