//
//  ExploreViewController.swift
//  Kratos
//
//  Created by Dylan Straughan on 3/23/17.
//  Copyright © 2017 Kratos, Inc. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxDataSources
import SnapKit

class ExploreController: UIViewController, CurtainPresenter, AnalyticsEnabled {
    
    // MARK: - Enums -
    enum State: Int {
        case trending = 0
        case house = 1
        case senate = 2
        
        static let allValues: [State] = [.trending, .house, .senate]
        
        var title: String {
            switch self {
            case .trending:
                return localize(.exploreTrendingButtonTitle)
            case .house:
                return localize(.exploreHouseButtonTitle)
            case .senate:
                return localize(.exploreSenateButtonTitle)
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
    var client: Client
    let viewModel: ExploreViewModel
    let disposeBag = DisposeBag()
    var curtain = Curtain()
    
    // Header View
    let header = UIView()
    
    // TopView
    let managerView = UIView()
    let slideView = UIView()
    let buttons: [UIButton] = State.allValues.map { $0.button }
    
    // RecessView
    let recessView = UIView()
    let recessLabel = UILabel()
    
    let scrollViewView = UIView()
    let scrollView = UIScrollView()
    
    // TableViews
    let tableViewView = UIView()
    
    let trendingTableView = UITableView()
    let senateTableView = UITableView()
    let houseTableView = UITableView()

    let emptyTrendingDescriptionLabel = UILabel()
    let emptySenateDescriptionLabel = UILabel()
    let emptyHouseDescriptionLabel = UILabel()
    
    let headerMargin: CGFloat = 64
    
    // MARK: - Initializers -
    init(client: Client) {
        self.client = client
        self.viewModel = ExploreViewModel(client: client)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle -
    override func viewDidLoad() {
        // TODO: Delete this code when fonts have been set
//        UIFont.familyNames.forEach{ UIFont.fontNames(forFamilyName: $0).forEach { print($0) } }
        
        super.viewDidLoad()
        edgesForExtendedLayout = [.top, .right, .left]
        addSubviews()
        constrainViews()
        localizeStrings()
        bind()
        configureHouseTableView()
        configureSenateTableView()
        configureTrendingTableView()
        configureScrollView()
        styleViews()
        addCurtain()
        view.layoutIfNeeded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.layoutIfNeeded()
        scrollViewView.addShadow()
        log(event: .exploreController)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setDefaultNavVC()
        configureNavVC()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setDefaultNavVC()
    }
    
    // MARK: - Configuration -
    func configureNavVC() {
        self.navigationItem.title = localize(.exploreTitle)
        var rightBarButtonItems: [UIBarButtonItem] = []
        if let user = client.user.value {
            let button = UIButton()
            button.snp.remakeConstraints { make in
                make.height.width.equalTo(30).priority(1000)
            }
            button.style(with: .font(.monospaced))
            button.setTitle(user.firstName.firstLetter, for: .normal)
            button.backgroundColor = user.party?.color.value ?? .gray
            button.layer.cornerRadius = CGFloat(30/2)
            button.clipsToBounds = false
            button.addTarget(self, action: #selector(presentMenu), for: .touchUpInside)
            let item = UIBarButtonItem(customView: button)
            rightBarButtonItems.append(item)
        }
        self.navigationItem.rightBarButtonItems = rightBarButtonItems
        self.navigationController?.navigationBar.setNeedsLayout()
    }
    
    func configureSenateTableView() {
        senateTableView.backgroundColor = .clear
        senateTableView.register(BillCell.self, forCellReuseIdentifier: BillCell.identifier)
        senateTableView.estimatedRowHeight = 200
        senateTableView.rowHeight = UITableViewAutomaticDimension
        senateTableView.allowsSelection = true
        senateTableView.tableFooterView = UIView()
        senateTableView.showsVerticalScrollIndicator = false
    }
    
    func configureHouseTableView() {
        houseTableView.backgroundColor = .clear
        houseTableView.register(BillCell.self, forCellReuseIdentifier: BillCell.identifier)
        houseTableView.estimatedRowHeight = 200
        houseTableView.rowHeight = UITableViewAutomaticDimension
        houseTableView.allowsSelection = true
        houseTableView.tableFooterView = UIView()
        houseTableView.showsVerticalScrollIndicator = false
    }
    
    func configureTrendingTableView() {
        trendingTableView.backgroundColor = .clear
        trendingTableView.register(BillCell.self, forCellReuseIdentifier: BillCell.identifier)
        trendingTableView.estimatedRowHeight = 200
        trendingTableView.rowHeight = UITableViewAutomaticDimension
        trendingTableView.allowsSelection = true
        trendingTableView.tableFooterView = UIView()
        trendingTableView.showsVerticalScrollIndicator = false
    }
    
    func configureScrollView() {
        scrollView.isScrollEnabled = false
    }
    
    func configure(for inRecess: Bool) {
        UIView.animate(withDuration: 0.4) {
            self.recessLabel.isHidden = inRecess ? false : true
            self.recessView.snp.remakeConstraints { make in
                self.recessLabel.snp.remakeConstraints { make in
                    if inRecess {
                        make.edges.equalToSuperview().inset(10)
                    } else {
                        make.edges.equalToSuperview()
                    }
                }
                make.top.equalTo(self.header.snp.bottom)
                make.leading.trailing.equalToSuperview()
                if !inRecess {
                    make.height.equalTo(0)
                }
            }
            self.view.layoutIfNeeded()
        }
        scrollViewView.addShadow()
        view.layoutIfNeeded()
    }
    
    @objc func presentMenu() {
        let vc = MenuController(client: client).embedInNavVC()
        self.present(vc, animated: true, completion: nil)
    }
    
    // MARK: - Animations -
    func update(with state: State) {
        log(event: .explore(.exploreTabSelected(state)))
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
            self.slideView.snp.remakeConstraints { make in
                make.bottom.equalToSuperview()
                make.width.equalTo(self.managerView.frame.width / CGFloat(State.allValues.count))
                make.height.equalTo(2)
                make.leading.equalToSuperview().offset(state.indicatorXPosition(in: self.managerView))
            }
            self.view.layoutIfNeeded()
        }, completion: nil)
        updateScrollView(with: state)
    }
    
    // MARK: - Helpers -
    func updateScrollView(with state: State) {
        let width = scrollView.frame.width
        self.scrollView.scrollRectToVisible(CGRect(x: state.scrollViewXPosition(in: scrollView),
                                                   y: 0,
                                                   width: width,
                                                   height: 1), animated: true)
    }
}

// MARK: - ViewBuilder -
extension ExploreController: ViewBuilder {
    func addSubviews() {
        view.addSubview(header)
        view.addSubview(managerView)
        managerView.addSubview(slideView)
        
        buttons.forEach { managerView.addSubview($0) }
        
        view.addSubview(recessView)
        recessView.addSubview(recessLabel)
        
        view.addSubview(scrollViewView)
        scrollViewView.addSubview(scrollView)
        
        scrollView.addSubview(tableViewView)
        tableViewView.addSubview(senateTableView)
        tableViewView.addSubview(houseTableView)
        tableViewView.addSubview(trendingTableView)
        
        tableViewView.addSubview(emptyHouseDescriptionLabel)
        tableViewView.addSubview(emptyTrendingDescriptionLabel)
        tableViewView.addSubview(emptySenateDescriptionLabel)
    }
    
    func constrainViews() {
        header.snp.remakeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.height.equalTo(headerMargin)
        }
        recessView.snp.remakeConstraints { make in
            make.top.equalTo(header.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(0)
        }
        recessLabel.snp.remakeConstraints { make in
            make.edges.equalToSuperview()
        }
        managerView.snp.remakeConstraints { make in
            make.top.equalTo(recessView.snp.bottom).offset(10)
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
        scrollViewView.snp.remakeConstraints { make in
            make.top.equalTo(managerView.snp.bottom).offset(10)
            make.trailing.leading.equalToSuperview().inset(10)
            make.bottom.equalToSuperview()
        }
        scrollView.snp.remakeConstraints { make in
            make.edges.equalToSuperview()
        }
        tableViewView.snp.remakeConstraints { make in
            make.width.equalTo(scrollView.snp.width).multipliedBy(3)
            make.height.equalTo(scrollView.snp.height)
            make.edges.equalToSuperview()
        }
        trendingTableView.snp.remakeConstraints { make in
            make.top.bottom.leading.equalToSuperview()
            make.width.equalTo(scrollView.snp.width)
        }
        houseTableView.snp.remakeConstraints { make in
            make.leading.equalTo(trendingTableView.snp.trailing)
            make.top.bottom.equalToSuperview()
            make.width.equalTo(scrollView.snp.width)
        }
        senateTableView.snp.remakeConstraints { make in
            make.leading.equalTo(houseTableView.snp.trailing)
            make.top.bottom.trailing.equalToSuperview()
            make.width.equalTo(scrollView.snp.width)
        }
        view.layoutIfNeeded()
        emptyTrendingDescriptionLabel.snp.remakeConstraints { make in
            make.centerX.centerY.equalTo(trendingTableView)
            make.width.equalTo(scrollView.snp.width).offset(-40)
        }
        emptyHouseDescriptionLabel.snp.remakeConstraints { make in
            make.centerX.centerY.equalTo(houseTableView)
            make.width.equalTo(scrollView.snp.width).offset(-40)
        }
        emptySenateDescriptionLabel.snp.remakeConstraints { make in
            make.centerX.centerY.equalTo(senateTableView)
            make.width.equalTo(scrollView.snp.width).offset(-40)
        }
        viewModel.loadStatus
            .asObservable()
            .bind(to: curtain.loadStatus)
            .disposed(by: disposeBag)
    }
    
    func styleViews() {
        header.style(with: .backgroundColor(.white))
        header.addShadow()
        
        view.style(with: .backgroundColor(.slate))
        managerView.style(with: .backgroundColor(.white))
        managerView.addShadow()
        
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isDirectionalLockEnabled = true
        
        slideView.style(with: [.backgroundColor(.kratosRed)])
        recessView.style(with: .backgroundColor(.kratosRed))
        recessLabel.style(with: [.font(.cellTitle),
                                 .titleColor(.white),
                                 .textAlignment(.center)
                                ])
        recessLabel.numberOfLines = 4
        tableViewView.style(with: .backgroundColor(.white))
        emptyHouseDescriptionLabel.style(with: [.font(.subHeader),
                                                .titleColor(.gray),
                                                .numberOfLines(4),
                                                .textAlignment(.center)])
        emptySenateDescriptionLabel.style(with: [.font(.subHeader),
                                                 .titleColor(.gray),
                                                 .numberOfLines(4),
                                                 .textAlignment(.center)])
        emptyTrendingDescriptionLabel.style(with: [.font(.subHeader),
                                                   .titleColor(.gray),
                                                   .numberOfLines(4),
                                                   .textAlignment(.center)])
    }
}

// MARK: - Localizer -
extension ExploreController: Localizer {
    func localizeStrings() {
        recessLabel.text = localize(.exploreRecessLabelTitle)
        emptyHouseDescriptionLabel.text = localize(.exploreHouseEmptyLabel)
        emptySenateDescriptionLabel.text = localize(.exploreSenateEmptyLabel)
        emptyTrendingDescriptionLabel.text = localize(.exploreTrendingEmptyLabel)
    }
}

// MARK: - Binds -
extension ExploreController: RxBinder {
    func bind() {
        viewModel.state
            .asObservable()
            .subscribe(onNext: { [weak self] state in
                self?.update(with: state)
            })
            .disposed(by: disposeBag)
        viewModel.inRecess
            .asObservable()
            .delay(2, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] inRecess in
                self?.configure(for: inRecess)
            })
            .disposed(by: disposeBag)
        
        buttons.forEach { button in
            button.rx.tap
                .map { _ in State(rawValue: button.tag) }
                .filterNil()
                .bind(to: viewModel.state)
                .disposed(by: disposeBag)
        }
        viewModel.senateBills
            .asObservable()
            .bind(to: senateTableView.rx.items(cellIdentifier: BillCell.identifier, cellType: BillCell.self)) { row, data, cell in
                cell.configure(with: data)
            }
            .disposed(by: disposeBag)
        viewModel.houseBills
            .asObservable()
            .bind(to: houseTableView.rx.items(cellIdentifier: BillCell.identifier, cellType: BillCell.self)) { row, data, cell in
                cell.configure(with: data)
            }
            .disposed(by: disposeBag)
        viewModel.trendingBills
            .asObservable()
            .bind(to: trendingTableView.rx.items(cellIdentifier: BillCell.identifier, cellType: BillCell.self)) { row, data, cell in
                cell.configure(with: data)
            }
            .disposed(by: disposeBag)
        viewModel.senateBills
            .asObservable()
            .map { !$0.isEmpty }
            .bind(to: emptySenateDescriptionLabel.rx.isHidden)
            .disposed(by: disposeBag)
        viewModel.houseBills
            .asObservable()
            .map { !$0.isEmpty }
            .bind(to: emptyHouseDescriptionLabel.rx.isHidden)
            .disposed(by: disposeBag)
        viewModel.trendingBills
            .asObservable()
            .map { !$0.isEmpty }
            .bind(to: emptyTrendingDescriptionLabel.rx.isHidden)
            .disposed(by: disposeBag)
        houseTableView.rx.modelSelected(Bill.self)
            .asObservable()
            .subscribe(onNext: { [weak self] bill in
                guard let `self` = self else { fatalError("self deallocated before it was accessed") }
                self.log(event: .explore(.billSelected(id: bill.id)))
                let vc = BillController(client: self.client, bill: bill)
                self.navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: disposeBag)
        trendingTableView.rx.modelSelected(Bill.self)
            .asObservable()
            .subscribe(onNext: { [weak self] bill in
                guard let `self` = self else { fatalError("self deallocated before it was accessed") }
                self.log(event: .explore(.billSelected(id: bill.id)))
                let vc = BillController(client: self.client, bill: bill)
                self.navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: disposeBag)
        senateTableView.rx.modelSelected(Bill.self)
            .asObservable()
            .subscribe(onNext: { [weak self] bill in
                guard let `self` = self else { fatalError("self deallocated before it was accessed") }
                self.log(event: .explore(.billSelected(id: bill.id)))
                let vc = BillController(client: self.client, bill: bill)
                self.navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: disposeBag)
        
    }
}
