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
    let recessLabel = UILabel(style: .h5white)
    
    let scrollViewView = UIView()
    let scrollView = UIScrollView()
    
    // TableViews
    let tableViewView = UIView()
    
    let trendingTableView = UITableView()
    let senateTableView = UITableView()
    let houseTableView = UITableView()

    let emptyTrendingDescriptionLabel = UILabel(style: .h3gray)
    let emptySenateDescriptionLabel = UILabel(style: .h3gray)
    let emptyHouseDescriptionLabel = UILabel(style: .h3gray)
        
    // MARK: - Initializers -
    init(client: CongressService & AuthService & UserService) {
        self.viewModel = ExploreViewModel(client: client)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        styleViews()
        addSubviews()
        
        bind()
        localizeStrings()
        configureHouseTableView()
        configureSenateTableView()
        configureTrendingTableView()
        configureScrollView()
        addCurtain()
        view.layoutIfNeeded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = localize(.exploreTitle)
        log(event: .exploreController)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setDefaultNavVC()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setDefaultNavVC()
    }
    
    // MARK: - Configuration -
    func configureRightBarButton(with user: User) {
        var rightBarButtonItems: [UIBarButtonItem] = []
        
        let button = UIButton()
        button.snp.makeConstraints { make in
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
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isDirectionalLockEnabled = true
    }
    
    func configure(for inRecess: Bool) {
        UIView.animate(withDuration: 0.4) {
            self.recessLabel.isHidden = inRecess ? false : true
            self.recessView.snp.makeConstraints { make in
                self.recessLabel.snp.makeConstraints { make in
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
        view.layoutIfNeeded()
    }
    
    @objc func presentMenu() {
        let vc = MenuController(client: Client.provider()).embedInNavVC()
        self.present(vc, animated: true, completion: nil)
    }
    
    // MARK: - Animations -
    func update(with state: State) {
        log(event: .explore(.exploreTabSelected(state)))
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
            self.slideView.snp.updateConstraints { make in
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
    func styleViews() {
        edgesForExtendedLayout = [.top, .right, .left]
        view.backgroundColor = Color.slate.value
    }
    
    func addSubviews() {
        addHeader()
        addRecessView()
        addRecessLabel()
        addManager()
        addManagerButtons()
        addSlideView()
        addScrollViewView()
        addScrollView()
        addTableViewView()
        addTrendingTableView()
        addHouseTableView()
        addSenateTableView()
        addEmptyTrendingLabel()
        addEmptyHouseLabel()
        addEmptySenateLabel()
    }
    
    private func addHeader() {
        view.addSubview(header)
        header.backgroundColor = Color.white.value

        header.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.height.equalTo(Dimension.topMargin)
        }
    }
    
    private func addRecessView() {
        view.addSubview(recessView)
        recessView.backgroundColor = Color.kratosRed.value
        
        recessView.snp.makeConstraints { make in
            make.top.equalTo(header.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(0)
        }
    }
    
    private func addRecessLabel() {
        recessView.addSubview(recessLabel)
        recessLabel.numberOfLines = 4
        recessLabel.textAlignment = .center

        recessLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func addManager() {
        view.addSubview(managerView)
        managerView.backgroundColor = Color.white.value

        managerView.snp.makeConstraints { make in
            make.top.equalTo(recessView.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(10)
            make.height.equalTo(45)
        }
        managerView.layoutIfNeeded()
    }
    
    private func addSlideView() {
        managerView.addSubview(slideView)
        slideView.backgroundColor = Color.kratosRed.value

        slideView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.bottom.equalToSuperview()
            make.width.equalToSuperview().dividedBy(3)
            make.height.equalTo(2)
        }
    }
    
    private func addManagerButtons() {
        buttons.forEach { managerView.addSubview($0) }

        buttons.forEach { button in
            let count = CGFloat(State.allValues.count)
            let width = managerView.frame.width/count
            button.snp.makeConstraints { make in
                make.leading.equalTo(width * CGFloat(button.tag))
                make.top.bottom.equalToSuperview()
                make.width.equalToSuperview().dividedBy(count)
            }
        }
    }
    
    private func addScrollViewView() {
        view.addSubview(scrollViewView)

        scrollViewView.snp.makeConstraints { make in
            make.top.equalTo(managerView.snp.bottom).offset(10)
            make.trailing.leading.equalToSuperview().inset(10)
            make.bottom.equalTo(view.snp.bottomMargin).offset(-10)
        }
    }
    
    private func addScrollView() {
        scrollViewView.addSubview(scrollView)
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func addTableViewView() {
        scrollView.addSubview(tableViewView)
        tableViewView.backgroundColor = Color.white.value

        tableViewView.snp.makeConstraints { make in
            make.width.equalTo(scrollView.snp.width).multipliedBy(3)
            make.height.equalTo(scrollView.snp.height)
            make.edges.equalToSuperview()
        }
    }
    
    private func addTrendingTableView() {
        tableViewView.addSubview(trendingTableView)
        
        trendingTableView.snp.makeConstraints { make in
            make.top.bottom.leading.equalToSuperview()
            make.width.equalTo(scrollView.snp.width)
        }
    }
    
    private func addHouseTableView() {
        tableViewView.addSubview(houseTableView)
        
        houseTableView.snp.makeConstraints { make in
            make.leading.equalTo(trendingTableView.snp.trailing)
            make.top.bottom.equalToSuperview()
            make.width.equalTo(scrollView.snp.width)
        }
    }
    
    private func addSenateTableView() {
        tableViewView.addSubview(senateTableView)

        senateTableView.snp.makeConstraints { make in
            make.leading.equalTo(houseTableView.snp.trailing)
            make.top.bottom.trailing.equalToSuperview()
            make.width.equalTo(scrollView.snp.width)
        }
        view.layoutIfNeeded()
    }
    
    private func addEmptyTrendingLabel() {
        tableViewView.addSubview(emptyTrendingDescriptionLabel)
        emptyTrendingDescriptionLabel.numberOfLines = 4
        emptyTrendingDescriptionLabel.textAlignment = .center
        
        emptyTrendingDescriptionLabel.snp.makeConstraints { make in
            make.centerX.centerY.equalTo(trendingTableView)
            make.width.equalTo(scrollViewView.snp.width).offset(-40)
        }
    }
    
    private func addEmptyHouseLabel() {
        tableViewView.addSubview(emptyHouseDescriptionLabel)
        emptyHouseDescriptionLabel.numberOfLines = 4
        emptyHouseDescriptionLabel.textAlignment = .center
        
        emptyHouseDescriptionLabel.snp.makeConstraints { make in
            make.centerX.centerY.equalTo(houseTableView)
            make.width.equalTo(scrollViewView.snp.width).offset(-40)
        }
    }
    
    private func addEmptySenateLabel() {
        tableViewView.addSubview(emptySenateDescriptionLabel)
        emptySenateDescriptionLabel.numberOfLines = 4
        emptySenateDescriptionLabel.textAlignment = .center
        
        emptySenateDescriptionLabel.snp.makeConstraints { make in
            make.centerX.centerY.equalTo(senateTableView)
            make.width.equalTo(scrollViewView.snp.width).offset(-40)
        }
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
            .subscribe(onNext: { [unowned self] in self.update(with: $0) })
            .disposed(by: disposeBag)
        
        viewModel.inRecess
            .asObservable()
            .delay(2, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [unowned self] in self.configure(for: $0) })
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
            .subscribe(onNext: { [unowned self] bill in
                self.log(event: .explore(.billSelected(id: bill.id)))
                let vc = BillController(client: Client.provider(), bill: bill)
                self.navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: disposeBag)
        
        trendingTableView.rx.modelSelected(Bill.self)
            .asObservable()
            .subscribe(onNext: { [unowned self] bill in
                self.log(event: .explore(.billSelected(id: bill.id)))
                let vc = BillController(client: Client.provider(), bill: bill)
                self.navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: disposeBag)
        
        senateTableView.rx.modelSelected(Bill.self)
            .asObservable()
            .subscribe(onNext: { [unowned self] bill in
                self.log(event: .explore(.billSelected(id: bill.id)))
                let vc = BillController(client: Client.provider(), bill: bill)
                self.navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: disposeBag)
        
        viewModel.user
            .subscribe(onNext: { [unowned self] user in self.configureRightBarButton(with: user) })
            .disposed(by: disposeBag)
        
        viewModel.loadStatus
            .asObservable()
            .bind(to: curtain.loadStatus)
            .disposed(by: disposeBag)
    }
}
