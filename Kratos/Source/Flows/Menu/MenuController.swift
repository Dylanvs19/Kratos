//
//  MenuController.swift
//  Kratos
//
//  Created by Dylan Straughan on 3/22/17.
//  Copyright © 2017 Kratos, Inc. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

class MenuController: UIViewController, AnalyticsEnabled {
    
    // MARK: - Enum -
    enum Category {
        case accountDetails
        case feedback
        case about
        case logout
        
        static let allValues: [Category] = [.accountDetails, .about, .feedback, .logout]
        
        var title: String {
            switch self {
            case .accountDetails:
                return localize(.menuAccountDetailsButtonTitle)
            case .feedback:
                return localize(.feedback)
            case .about:
                return localize(.menuPrivacyPolicyButtonTitle)
            case .logout:
                return localize(.menuLogoutButtonTitle)
            }
        }
    }
    
    // MARK: - Variables -
    let viewModel: MenuViewModel
    let disposeBag = DisposeBag()
    
    let header = UIView()
    let label = UILabel()
    let nameLabel = UILabel(style: .h3gray)
    let locationLabel = UILabel(style: .h3gray)
    let dividerView = UIView()
    let tableView = UITableView()
        
    // MARK: - Intialization -
    init(client: UserService & AuthService) {
        viewModel = MenuViewModel(client: client)
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
        configureTableView()
        configureNavVC()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        log(event: .mainController)
    }
    
    // MARK: - Configuration -
    func configureNavVC() {
        setDefaultNavVC()
        setClearButton(isRed: true)
    }
    
    func configureTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: String(describing: UITableViewCell.self))
        tableView.tableFooterView = UIView()
        tableView.separatorInset = .zero
    }
}

    // MARK: - ViewBuilder -
extension MenuController: ViewBuilder {
    func styleViews() {
        automaticallyAdjustsScrollViewInsets = false
        label.style(with: [.font(.h1),
                           .titleColor(.white),
                           .textAlignment(.center)])
    }
    
    func addSubviews() {
        addTableView()
        addHeader()
        addLabel()
        addNameLabel()
        addDividerView()
        addLocationLabel()
    }
    
    private func addTableView() {
        view.addSubview(tableView)

        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        self.view.layoutIfNeeded()
    }
    
    private func addHeader() {
        tableView.tableHeaderView = header
        
        header.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalTo(200)
        }
    }
    
    private func addLabel() {
        header.addSubview(label)
        
        label.snp.makeConstraints { make in
            make.height.width.equalTo(100)
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(25)
        }
    }
    
    private func addNameLabel() {
        header.addSubview(nameLabel)

        nameLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(label.snp.bottom).offset(6)
        }
    }
    
    private func addDividerView() {
        header.addSubview(dividerView)
        dividerView.backgroundColor = Color.lightGray.value
        
        dividerView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(1)
        }
    }
    
    private func addLocationLabel() {
        header.addSubview(locationLabel)

        locationLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(nameLabel.snp.bottom).offset(2)
        }
    }
}

// MARK: - Binds -
extension MenuController: RxBinder {
    func bind() {
        bindTableView()
        bindLabels()
    }
    
    func bindTableView() {
        Observable.just(Category.allValues)
            .bind(to: tableView.rx.items(cellIdentifier: String(describing: UITableViewCell.self),
                                         cellType: UITableViewCell.self)) { row, model, cell in
                cell.textLabel?.text = model.title
                if model != .logout {
                    cell.textLabel?.style(with: [.titleColor(.gray),
                                                 .font(.h1)])
                } else  {
                    cell.textLabel?.style(with: [.titleColor(.kratosRed),
                                                 .font(.h1)])
                }
                cell.selectionStyle = .none
            }
            .disposed(by: disposeBag)
        
        tableView.rx.modelSelected(Category.self)
            .subscribe(
                onNext: { [unowned self] category in
                    switch category {
                    case .accountDetails:
                        self.log(event: .menu(.accountDetails))
                        let vc = AccountDetailsController(client: Client.provider(), state: .edit)
                        self.navigationController?.pushViewController(vc, animated: true)
                    case .feedback:
                        let vc = FeedbackController(client:  Client.provider())
                        self.navigationController?.pushViewController(vc, animated: true)
                    case .about:
                        self.log(event: .menu(.privacyPolicy))
                        self.navigationController?.pushViewController(TermsController(), animated: true)
                    case .logout:
                        self.log(event: .menu(.logout))
                        self.dismiss(animated: false, completion: {
                            self.viewModel.logOut()
                        })
                    }
                }
            )
            .disposed(by: disposeBag)
    }
    
    private func bindLabels() {
        viewModel.user
            .map { $0.firstName + " " + $0.lastName }
            .bind(to: nameLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.user
            .map { $0.firstName.firstLetter + $0.lastName.firstLetter }
            .bind(to: label.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.user
            .map { $0.address.city + ", " + $0.address.state }
            .bind(to: locationLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.user
            .map { $0.party?.color ?? Color.gray }
            .subscribe(onNext: { [unowned self] color in self.label.backgroundColor = color.value })
            .disposed(by: disposeBag)
    }
}
