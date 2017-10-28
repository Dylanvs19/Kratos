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
//        case notification
        case feedback
        case about
        case logout
        
        static let allValues: [Category] = [.accountDetails, .about, .feedback, .logout]
        
        var title: String {
            switch self {
            case .accountDetails:
                return localize(.menuAccountDetailsButtonTitle)
//            case .notification:
//                return "Preferences"
            case .feedback:
                return localize(.menuFeedbackButtonTitle)
            case .about:
                return "Privacy Policy"
            case .logout:
                return localize(.menuLogoutButtonTitle)
            }
        }
    }
    
    // MARK: - Variables -
    var client: Client
    let disposeBag = DisposeBag()
    
    let header = UIView()
    let label = UILabel()
    let nameLabel = UILabel()
    let locationLabel = UILabel()
    let dividerView = UIView()
    let tableView = UITableView()
        
    // MARK: - Intialization -
    init(client: Client) {
        self.client = client
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        automaticallyAdjustsScrollViewInsets = false
        addSubviews()
        constrainViews()
        configureTableView()
        configureNavVC()
        styleViews()
        bind()
        localizeStrings()
        view.layoutIfNeeded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        log(event: .mainController)
    }
    
    // MARK: - Configuration -
    func configureNavVC() {
        setDefaultNavVC()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "clearIcon").withRenderingMode(.alwaysOriginal).af_imageAspectScaled(toFill: CGSize(width: 25, height: 25)), style: .plain, target: self, action: #selector(clearPressed))
        self.view.layoutIfNeeded()
    }
    
    func configureTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: String(describing: UITableViewCell.self))
        tableView.tableFooterView = UIView()
    }
    
    func clearPressed() {
        self.dismiss(animated: true, completion: nil)
    }
}

    // MARK: - ViewBuilder -
extension MenuController: ViewBuilder {
    func addSubviews() {
        view.addSubview(tableView)
        header.addSubview(label)
        header.addSubview(nameLabel)
        header.addSubview(dividerView)
        header.addSubview(locationLabel)
        tableView.tableHeaderView = header
    }
    func constrainViews() {
        tableView.snp.remakeConstraints { make in
            make.edges.equalToSuperview()
        }
        self.view.layoutIfNeeded()
        header.snp.remakeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalTo(200)
        }
        label.snp.remakeConstraints { make in
            make.height.width.equalTo(100)
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(25)
        }
        nameLabel.snp.remakeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(label.snp.bottom).offset(6)
        }
        locationLabel.snp.remakeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(nameLabel.snp.bottom).offset(2)
        }
        dividerView.snp.remakeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(1)
        }
    }
    func styleViews() {
        let color = client.user.value?.party?.color ?? .gray
        label.style(with: [.backgroundColor(color),
                           .font(.header),
                           .titleColor(.white),
                           .textAlignment(.center)])
        nameLabel.style(with: [.font(.subHeader),
                               .titleColor(.gray)])
        locationLabel.style(with: [.font(.subHeader),
                                   .titleColor(.gray)])
        dividerView.style(with: .backgroundColor(.lightGray))
    }
}

// MARK: - Localize -
extension MenuController: Localizer {
    func localizeStrings() {
        let first = client.user.value?.firstName ?? ""
        let last = client.user.value?.lastName ?? ""
        label.text = first.firstLetter + last.firstLetter
        nameLabel.text = first + " " + last
        
        let city = client.user.value?.address.city ?? ""
        let state = client.user.value?.address.state ?? ""
        locationLabel.text = city + ", " + state
    }
}

// MARK: - Binds -
extension MenuController: RxBinder {
    func bind() {
        Observable.just(Category.allValues)
            .bind(to: tableView.rx.items(cellIdentifier: String(describing: UITableViewCell.self), cellType: UITableViewCell.self)) { row, model, cell in
                cell.textLabel?.text = model.title
                if model != .logout {
                cell.textLabel?.style(with: [.titleColor(.gray),
                                             .font(.header)])
                } else  {
                    cell.textLabel?.style(with: [.titleColor(.kratosRed),
                                                 .font(.header)])
                }
                cell.selectionStyle = .none
                cell.separatorInset = .zero
            }
            .disposed(by: disposeBag)
        tableView.rx.modelSelected(Category.self)
            .subscribe(
                onNext: { [weak self] category in
                    guard let `self` = self else { fatalError("self deallocated before it was accessed")}
                    switch category {
                    case .accountDetails:
                        self.log(event: .menu(.accountDetails))
                        let vc = AccountDetailsController(client: self.client, state: .edit)
                        self.navigationController?.pushViewController(vc, animated: true)
//                    case .notification:
//                        break
                    case .feedback:
                        let vc = FeedbackController(client: self.client)
                        self.navigationController?.pushViewController(vc, animated: true)
                    case .about:
                        self.log(event: .menu(.privacyPolicy))
                        self.navigationController?.pushViewController(TermsController(), animated: true)
                    case .logout:
                        self.log(event: .menu(.logout))
                        self.dismiss(animated: false, completion: {
                            self.client.tearDown()
                        })
                        
                    }
                }
            )
            .disposed(by: disposeBag)
    }
}
