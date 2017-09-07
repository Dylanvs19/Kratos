//
//  ExploreViewController.swift
//  Kratos
//
//  Created by Dylan Straughan on 3/23/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxDataSources
import SnapKit

class ExploreController: UIViewController {
    
    // MARK: - Enums -
    enum State: Int {
        case executive = 0
        case house = 1
        case senate = 2
        
        
        static let allValues: [State] = [.house, .executive, .senate]
        
        var title: String {
            switch self {
            case .house:
                return localize(.exploreHouseButtonTitle)
            case .senate:
                return localize(.exploreSenateButtonTitle)
            case .executive:
                return localize(.exploreExecutiveButtonTitle)
            }
        }
        
        func scrollViewXPosition(in view: UIView) -> CGFloat {
            let width = view.frame.size.width
            return CGFloat(State.allValues.index(of: self)!) * width
        }
        
        func indicatorXPosition(in view: UIView) -> CGFloat {
            let width = view.frame.size.width / CGFloat(State.allValues.count)
            return CGFloat(self.rawValue) * width
        }
        
        var button: UIButton {
            let button = UIButton()
            button.style(with: [.font(.title),
                                .titleColor(.kratosRed),
                                .borderColor(.gray),
                                .borderWidth(1)
                                ])
            button.setTitle(title, for: .normal)
            button.tag = self.rawValue
            return button
        }
    }
    
    // MARK: - Variables -
    let client: Client
    let viewModel: ExploreViewModel
    let disposeBag = DisposeBag()
    
    // TopView
    let topView = UIView()
    let slideView = UIView()
    let houseButton = UIButton()
    let executiveButton = UIButton()
    let senateButton = UIButton()
    let buttons: [UIButton] = State.allValues.map { $0.button }
    
    // RecessView
    let recessView = UIView()
    let recessLabel = UILabel()
    
    let scrollView = UIScrollView()
    
    // TableViews
    let tableViewView = UIView()
    
    let senateTableView = UITableView()
    let executiveTableView = UITableView()
    let senateDataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, Bill>>()
    
    let houseTableView = UITableView()
    let houseDataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, Bill>>()

    let buttonWidth: CGFloat = 80
    let buttonHeight: CGFloat = 25
    
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
        super.viewDidLoad()
        edgesForExtendedLayout = [.right, .left]
        addSubviews()
        constrainViews()
        styleViews()
        localizeStrings()
        configureHouseTableView()
        configureSenateTableView()
        configureExecutiveTableView()
        configureScrollView()
        bind()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        configureNavVC()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setDefaultNavVC()
    }
    
    // MARK: - Helpers -
    func updateScrollView(with state: State) {
        let width = scrollView.frame.width
        self.scrollView.scrollRectToVisible(CGRect(x: state.scrollViewXPosition(in: scrollView),
                                                   y: 0,
                                                   width: width,
                                                   height: 1), animated: true)
    }
    
    // MARK: - Configuration -
    func configureNavVC() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "searchIcon").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(presentSearch))
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
    
    func configureExecutiveTableView() {
        executiveTableView.backgroundColor = .clear
        executiveTableView.register(BillCell.self, forCellReuseIdentifier: BillCell.identifier)
        executiveTableView.estimatedRowHeight = 200
        executiveTableView.rowHeight = UITableViewAutomaticDimension
        executiveTableView.allowsSelection = true
        executiveTableView.tableFooterView = UIView()
        executiveTableView.showsVerticalScrollIndicator = false
    }
    
    func configureScrollView() {
        scrollView.isScrollEnabled = false 
    }
    
    // MARK: - Animations -
    func configure(for state: State) {
        switch state {
        case .house:
            UIView.animate(withDuration: 0.4, animations: { 
                self.slideView.snp.remakeConstraints { make in
                    make.leading.equalTo(self.houseButton.snp.leading)
                    make.centerY.equalToSuperview()
                    make.width.equalTo(self.houseButton.snp.width)
                    make.height.equalTo(self.buttonHeight)
                }
                self.houseButton.style(with: .titleColor(.white))
                self.senateButton.style(with: .titleColor(.kratosRed))
                self.executiveButton.style(with: .titleColor(.kratosRed))
                self.view.layoutIfNeeded()
            })
        case .executive:
            UIView.animate(withDuration: 0.4, animations: {
                self.slideView.snp.remakeConstraints { make in
                    make.leading.equalTo(self.executiveButton.snp.leading)
                    make.centerY.equalToSuperview()
                    make.width.equalTo(self.executiveButton.snp.width)
                    make.height.equalTo(self.buttonHeight)
                }
                self.houseButton.style(with: .titleColor(.kratosRed))
                self.executiveButton.style(with: .titleColor(.white))
                self.senateButton.style(with: .titleColor(.kratosRed))
                self.view.layoutIfNeeded()
            })
        case .senate:
            UIView.animate(withDuration: 0.4, animations: {
                self.slideView.snp.remakeConstraints { make in
                    make.leading.equalTo(self.senateButton.snp.leading)
                    make.centerY.equalToSuperview()
                    make.width.equalTo(self.senateButton.snp.width)
                    make.height.equalTo(self.buttonHeight)
                }
                self.houseButton.style(with: .titleColor(.kratosRed))
                self.senateButton.style(with: .titleColor(.white))
                self.executiveButton.style(with: .titleColor(.kratosRed))
                self.view.layoutIfNeeded()
            })
        }
        
        updateScrollView(with: state)
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
                make.leading.trailing.top.equalToSuperview()
                if !inRecess {
                    make.height.equalTo(0)
                }
            }
            self.view.layoutIfNeeded()
        }
    }
    
    func presentSearch() {
        let vc = SearchController(client: client)
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: true, completion: nil)
    }
}

// MARK: - ViewBuilder -
extension ExploreController: ViewBuilder {
    func addSubviews() {
        
        view.addSubview(topView)
        topView.addSubview(slideView)
        topView.addSubview(houseButton)
        topView.addSubview(executiveButton)
        topView.addSubview(senateButton)
        
        view.addSubview(recessView)
        recessView.addSubview(recessLabel)
        
        view.addSubview(scrollView)
        
        scrollView.addSubview(tableViewView)
        tableViewView.addSubview(senateTableView)
        tableViewView.addSubview(houseTableView)
        tableViewView.addSubview(executiveTableView)
    }
    
    func constrainViews() {
        recessView.snp.remakeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.height.equalTo(0)
        }
        recessLabel.snp.remakeConstraints { make in
            make.edges.equalToSuperview()
        }
        topView.snp.remakeConstraints { make in
            make.top.equalTo(recessView.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(10)
            make.height.equalTo(45)
        }
        houseButton.snp.remakeConstraints { make in
            make.leading.equalToSuperview().inset(10)
            make.centerY.equalToSuperview()
            make.width.equalTo(self.topView.snp.width).offset(-20).dividedBy(3)
            make.height.equalTo(buttonHeight)
        }
        executiveButton.snp.remakeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(houseButton.snp.trailing).offset(-1)
            make.trailing.equalTo(senateButton.snp.leading).offset(1)
            make.height.equalTo(buttonHeight)
        }
        senateButton.snp.remakeConstraints { make in
            make.trailing.equalToSuperview().inset(10)
            make.centerY.equalToSuperview()
            make.width.equalTo(self.topView.snp.width).offset(-20).dividedBy(3)
            make.height.equalTo(buttonHeight)
        }
        slideView.snp.remakeConstraints { make in
            make.leading.equalTo(houseButton.snp.leading)
            make.centerY.equalToSuperview()
            make.width.equalTo(buttonWidth)
            make.height.equalTo(buttonHeight)
        }
        scrollView.snp.remakeConstraints { make in
            make.top.equalTo(topView.snp.bottom).offset(10)
            make.trailing.leading.equalToSuperview().inset(10)
            make.bottom.equalTo(bottomLayoutGuide.snp.top).offset(-10)
        }
        tableViewView.snp.remakeConstraints { make in
            make.width.equalTo(scrollView.snp.width).multipliedBy(3)
            make.height.equalTo(scrollView.snp.height)
            make.edges.equalToSuperview()
        }
        houseTableView.snp.remakeConstraints { make in
            make.top.bottom.leading.equalToSuperview()
            make.width.equalTo(scrollView.snp.width)
        }
        executiveTableView.snp.remakeConstraints { make in
            make.leading.equalTo(houseTableView.snp.trailing)
            make.top.bottom.equalToSuperview()
            make.width.equalTo(scrollView.snp.width)
        }
        senateTableView.snp.remakeConstraints { make in
            make.leading.equalTo(executiveTableView.snp.trailing)
            make.top.bottom.trailing.equalToSuperview()
            make.width.equalTo(scrollView.snp.width)
        }
    }
    
    func styleViews() {
        view.style(with: .backgroundColor(.slate))
        topView.style(with: .backgroundColor(.white))
        topView.addShadow()
        
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isDirectionalLockEnabled = true
        
        
        slideView.style(with: [.backgroundColor(.kratosRed)])
        houseButton.style(with: [.font(.title),
                                 .titleColor(.kratosRed),
                                 .borderColor(.gray),
                                 .borderWidth(1)
                                ])
        senateButton.style(with: [.font(.title),
                                 .titleColor(.kratosRed),
                                 .borderColor(.gray),
                                 .borderWidth(1)
                                ])
        executiveButton.style(with: [.font(.title),
                                  .titleColor(.kratosRed),
                                  .borderColor(.gray),
                                  .borderWidth(1)
                                ])
        recessView.style(with: .backgroundColor(.kratosRed))
        recessLabel.style(with: [.font(.cellTitle),
                                 .titleColor(.white),
                                 .textAlignment(.center)
                                ])
        recessLabel.numberOfLines = 4
    }
}

// MARK: - Localizer -
extension ExploreController: Localizer {
    func localizeStrings() {
        senateButton.setTitle(localize(.exploreSenateButtonTitle), for: .normal)
        houseButton.setTitle(localize(.exploreHouseButtonTitle), for: .normal)
        executiveButton.setTitle(localize(.exploreExecutiveButtonTitle), for: .normal)
        recessLabel.text = localize(.exploreRecessLabelTitle)
    }
}

// MARK: - Binds -
extension ExploreController: RxBinder {
    func bind() {
        viewModel.state
            .asObservable()
            .subscribe(onNext: { [weak self] state in
                self?.configure(for: state)
            })
            .disposed(by: disposeBag)
        viewModel.inRecess
            .asObservable()
            .delay(2, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] inRecess in
                self?.configure(for: inRecess)
            })
            .disposed(by: disposeBag)
        houseButton.rx.tap
            .map { _ in State.house }
            .bind(to: viewModel.state)
            .disposed(by: disposeBag)
        senateButton.rx.tap
            .map { _ in State.senate }
            .bind(to: viewModel.state)
            .disposed(by: disposeBag)
        executiveButton.rx.tap
            .map { _ in State.executive }
            .bind(to: viewModel.state)
            .disposed(by: disposeBag)
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
        viewModel.executiveBills
            .asObservable()
            .bind(to: executiveTableView.rx.items(cellIdentifier: BillCell.identifier, cellType: BillCell.self)) { row, data, cell in
                cell.configure(with: data)
            }
            .disposed(by: disposeBag)
        houseTableView.rx.modelSelected(Bill.self)
            .asObservable()
            .subscribe(onNext: { [weak self] bill in
                guard let `self` = self else { fatalError("self deallocated before it was accessed") }
                let vc = BillController(client: self.client, bill: bill)
                self.navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: disposeBag)
        executiveTableView.rx.modelSelected(Bill.self)
            .asObservable()
            .subscribe(onNext: { [weak self] bill in
                guard let `self` = self else { fatalError("self deallocated before it was accessed") }
                let vc = BillController(client: self.client, bill: bill)
                self.navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: disposeBag)
        senateTableView.rx.modelSelected(Bill.self)
            .asObservable()
            .subscribe(onNext: { [weak self] bill in
                guard let `self` = self else { fatalError("self deallocated before it was accessed") }
                let vc = BillController(client: self.client, bill: bill)
                self.navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: disposeBag)
    }
}
