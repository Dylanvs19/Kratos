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
    enum State {
        case house
        case senate
        case executive
        
        static let allValues: [State] = [.house, .senate, .executive]
        
        var title: String {
            switch self {
            case .house:
                return localize(.repInfoViewBioTitle)
            case .senate:
                return localize(.repInfoViewVotesTitle)
            case .executive:
                return localize(.repInfoViewBillsTitle)
            }
        }
        
        func scrollViewXPosition(in view: UIView) -> CGFloat {
            let width = view.frame.size.width
            return CGFloat(State.allValues.index(of: self)!) * width
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
    let senateButton = UIButton()
    let titleLabel = UILabel()
    
    // RecessView
    let recessView = UIView()
    let recessLabel = UILabel()
    
    let scrollView = UIScrollView()
    
    // TableViews
    let tableViewView = UIView()
    
    let senateTableView = UITableView()
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
        
        senateDataSource.configureCell = { dataSource, tableView, indexPath, item in
            let basicCell = tableView.dequeueReusableCell(withIdentifier: BillCell.identifier, for: indexPath)
            guard let cell = basicCell as? BillCell else { fatalError() }
            cell.configure(with: item)
            return cell
        }
    }
    
    func configureHouseTableView() {
        houseTableView.backgroundColor = .clear
        houseTableView.register(BillCell.self, forCellReuseIdentifier: BillCell.identifier)
        houseTableView.estimatedRowHeight = 200
        houseTableView.rowHeight = UITableViewAutomaticDimension
        houseTableView.allowsSelection = true
        houseTableView.tableFooterView = UIView()
        houseTableView.showsVerticalScrollIndicator = false
        
        houseDataSource.configureCell = { dataSource, tableView, indexPath, item in
            let basicCell = tableView.dequeueReusableCell(withIdentifier: BillCell.identifier, for: indexPath)
            guard let cell = basicCell as? BillCell else { fatalError() }
            cell.configure(with: item)
            return cell
        }
    }
    
    // MARK: - Animations -
    func configure(for state: State) {
        switch state {
        case .house:
            UIView.animate(withDuration: 0.4, animations: { 
                self.slideView.snp.remakeConstraints { make in
                    make.leading.equalTo(self.houseButton.snp.leading)
                    make.centerY.equalToSuperview()
                    make.width.equalTo(self.buttonWidth)
                    make.height.equalTo(self.buttonHeight)
                }
                self.houseButton.style(with: .titleColor(.white))
                self.senateButton.style(with: .titleColor(.kratosRed))
                self.view.layoutIfNeeded()
            })
            
        case .senate:
            UIView.animate(withDuration: 0.4, animations: {
                self.slideView.snp.remakeConstraints { make in
                    make.leading.equalTo(self.senateButton.snp.leading)
                    make.centerY.equalToSuperview()
                    make.width.equalTo(self.buttonWidth)
                    make.height.equalTo(self.buttonHeight)
                }
                self.houseButton.style(with: .titleColor(.kratosRed))
                self.senateButton.style(with: .titleColor(.white))
                self.view.layoutIfNeeded()
            })
        case .executive:
            break
        }
        
        updateScrollView(with: state)
    }
    
    func configure(for inRecess: Bool) {
        UIView.animate(withDuration: 0.4) {
            self.recessLabel.isHidden = inRecess ? false : true
            self.recessView.snp.remakeConstraints { make in
                make.leading.trailing.top.equalToSuperview()
                if !inRecess {
                    make.height.equalTo(0)
                }
            }
            self.recessLabel.snp.remakeConstraints { make in
                if inRecess {
                    make.edges.equalToSuperview().inset(10)
                } else {
                    make.edges.equalToSuperview()
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
        topView.addSubview(titleLabel)
        topView.addSubview(slideView)
        topView.addSubview(houseButton)
        topView.addSubview(senateButton)
        
        view.addSubview(recessView)
        recessView.addSubview(recessLabel)
        
        view.addSubview(scrollView)
        
        scrollView.addSubview(tableViewView)
        tableViewView.addSubview(senateTableView)
        tableViewView.addSubview(houseTableView)
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
        }
        titleLabel.snp.remakeConstraints { make in
            make.leading.top.bottom.equalToSuperview().inset(10)
        }
        senateButton.snp.remakeConstraints { make in
            make.trailing.equalToSuperview().inset(10)
            make.centerY.equalToSuperview()
            make.width.equalTo(buttonWidth)
            make.height.equalTo(buttonHeight)
        }
        houseButton.snp.remakeConstraints { make in
            make.trailing.equalTo(senateButton.snp.leading).offset(1)
            make.centerY.equalToSuperview()
            make.width.equalTo(buttonWidth)
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
            make.width.equalTo(scrollView.snp.width).multipliedBy(2)
            make.height.equalTo(scrollView.snp.height)
            make.edges.equalToSuperview()
        }
        houseTableView.snp.remakeConstraints { make in
            make.top.bottom.leading.equalToSuperview()
            make.width.equalTo(scrollView.snp.width)
        }
        senateTableView.snp.remakeConstraints { make in
            make.leading.equalTo(houseTableView.snp.trailing)
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
        
        titleLabel.style(with: [.font(.header)])
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
        titleLabel.text = localize(.exploreTitle)
        senateButton.setTitle(localize(.exploreSenateButtonTitle), for: .normal)
        houseButton.setTitle(localize(.exploreHouseButtonTitle), for: .normal)
        recessLabel.text = localize(.exploreRecessLabelTitle)
    }
}

// MARK: - Binds -
extension ExploreController: RxBinder {
    func bind() {
        viewModel.state.asObservable()
            .subscribe(onNext: { [weak self] state in
                self?.configure(for: state)
            })
            .disposed(by: disposeBag)
        viewModel.inRecess.asObservable()
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
        viewModel.senateBills.asObservable()
            .map { [SectionModel(model: "", items: $0)] }
            .bind(to: senateTableView.rx.items(dataSource: senateDataSource))
            .disposed(by: disposeBag)
        viewModel.houseBills.asObservable()
            .map { [SectionModel(model: "", items: $0)] }
            .bind(to: houseTableView.rx.items(dataSource: houseDataSource))
            .disposed(by: disposeBag)
    }
}
