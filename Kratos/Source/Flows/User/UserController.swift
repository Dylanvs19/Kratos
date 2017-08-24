//
//  UserBillsController.swift
//  Kratos
//
//  Created by Dylan Straughan on 8/1/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxDataSources
import SnapKit

class UserController: UIViewController {
    
    // MARK: - Variables - 
    // Standard
    let client: Client
    let viewModel: UserViewModel
    let disposeBag = DisposeBag()
    
    // UIElements
    let tableView = UITableView()
    let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, Bill>>()

    // MARK: - Initializers -
    init(client: Client) {
        self.client = client
        self.viewModel = UserViewModel(client: client)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        edgesForExtendedLayout = [.top, .right, .left]
        addSubviews()
        constrainViews()
        styleViews()
    }
}

    // MARK: - View Builder -
extension UserController: ViewBuilder {
    func addSubviews() {
        view.addSubview(tableView)
    }
    
    func constrainViews() {
        tableView.snp.makeConstraints { make in
            make.top.equalTo(60)
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.bottom.equalToSuperview().offset(-5)
        }
    }
    
    func styleViews() {
        view.style(with: .backgroundColor(.slate))
    }
}

extension UserController: InteractionResponder {
    func setupInteractions() {
        
    }
}
