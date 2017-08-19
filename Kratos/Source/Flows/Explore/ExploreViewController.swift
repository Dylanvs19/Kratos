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
    
    // MARK: - Configuration -
    func configureNavVC() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "searchIcon").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(presentSearch))
    }
    
    func configureSenateTableView() {
        senateTableView.backgroundColor = .clear
        senateTableView.register(BillCell.self, forCellReuseIdentifier: BillCell.identifier)
        senateTableView.isScrollEnabled = false
        senateTableView.estimatedRowHeight = 200
        senateTableView.rowHeight = UITableViewAutomaticDimension
        senateTableView.allowsSelection = true
        
        senateDataSource.configureCell = { dataSource, tableView, indexPath, item in
            let basicCell = tableView.dequeueReusableCell(withIdentifier: BillCell.identifier, for: indexPath)
            guard let cell = basicCell as? BillCell else { fatalError() }
            cell.configure(with: item)
            return cell
        }
    }
    
    func configureTableView() {
        houseTableView.backgroundColor = .clear
        houseTableView.register(BillCell.self, forCellReuseIdentifier: BillCell.identifier)
        houseTableView.isScrollEnabled = false
        houseTableView.estimatedRowHeight = 200
        houseTableView.rowHeight = UITableViewAutomaticDimension
        houseTableView.allowsSelection = true
        
        houseDataSource.configureCell = { dataSource, tableView, indexPath, item in
            let basicCell = tableView.dequeueReusableCell(withIdentifier: BillCell.identifier, for: indexPath)
            guard let cell = basicCell as? BillCell else { fatalError() }
            cell.configure(with: item)
            return cell
        }
    }
    
    func configure(for chamber: Chamber) {
        switch chamber {
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
        }
    }
    
    func presentSearch() {
        let vc = SearchController(client: client)
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: true, completion: nil)
    }
}

extension ExploreController: ViewBuilder {
    func addSubviews() {
        
        view.addSubview(topView)
        topView.addSubview(titleLabel)
        topView.addSubview(slideView)
        topView.addSubview(houseButton)
        topView.addSubview(senateButton)
        
        view.addSubview(tableViewView)
        tableViewView.addSubview(senateTableView)
        tableViewView.addSubview(houseTableView)
    }
    
    func constrainViews() {
        
        topView.snp.remakeConstraints { make in
            make.leading.trailing.top.equalToSuperview().inset(10)
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
        tableViewView.snp.remakeConstraints { make in
            make.top.equalTo(topView.snp.bottom).offset(10)
            make.trailing.leading.equalToSuperview().inset(10)
            make.bottom.equalTo(bottomLayoutGuide.snp.top).inset(10)
        }
        houseTableView.snp.remakeConstraints { make in
            make.edges.equalToSuperview()
        }
        senateTableView.snp.remakeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func styleViews() {
        view.style(with: .backgroundColor(.slate))
        topView.style(with: .backgroundColor(.white))
        topView.addShadow()
        
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
        
    }
}
extension ExploreController: Localizer {
    func localizeStrings() {
        titleLabel.text = localize(.exploreTitle)
        senateButton.setTitle(localize(.exploreSenateButtonTitle), for: .normal)
        houseButton.setTitle(localize(.exploreHouseButtonTitle), for: .normal)
    }
}

extension ExploreController: RxBinder {
    func bind() {
        viewModel.state.asObservable()
            .subscribe(onNext: { [weak self] state in
                self?.configure(for: state)
            })
            .disposed(by: disposeBag)
        houseButton.rx.tap
            .map { _ in Chamber.house }
            .bind(to: viewModel.state)
            .disposed(by: disposeBag)
        senateButton.rx.tap
            .map { _ in Chamber.senate }
            .bind(to: viewModel.state)
            .disposed(by: disposeBag)
    }
}
