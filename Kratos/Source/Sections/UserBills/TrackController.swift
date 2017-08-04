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

class TrackController: UIViewController {
    let client: Client
    let viewModel: TrackViewModel
    let disposeBag = DisposeBag()
    let loadStatus = Variable<LoadStatus>(.none)
    
    //TopImage
    let kratosImageView = UIImageView(image: #imageLiteral(resourceName: "Kratos"))
    
    let tableView = UITableView()
    let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, Bill>>()
    
    init(client: Client) {
        self.client = client
        self.viewModel = TrackViewModel(client: client)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        edgesForExtendedLayout = [.top, .right, .left]
        addSubviews()
        constrainViews()
        style()
    }
}

extension TrackController: ViewBuilder {
    func addSubviews() {
        view.addSubview(kratosImageView)
        view.addSubview(tableView)
    }
    
    func constrainViews() {
        kratosImageView.snp.makeConstraints { make in
            make.width.equalTo(50)
            make.height.equalTo(kratosImageView.snp.width)
            make.top.equalToSuperview().offset(10)
            make.centerX.equalToSuperview()
        }
        tableView.snp.makeConstraints { make in
            make.top.equalTo(kratosImageView.snp.bottom).offset(5)
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.bottom.equalToSuperview().offset(-5)
        }
    }
    
    func style() {
        view.style(with: .backgroundColor(.slate))
    }
}
