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
        let client: Client
        let viewModel: ExploreViewModel
        let disposeBag = DisposeBag()
        let loadStatus = Variable<LoadStatus>(.none)
        
        //TopImage
        let kratosImageView = UIImageView(image: #imageLiteral(resourceName: "Kratos"))
        let topImage = UIImageView()
        let topShadeView = UIView()
        let stateImageView = UIImageView()
        let stateLabel = UILabel()
        let districtLabel = UILabel()
        
        let tableView = UITableView()
        let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, Bill>>()
        
        init(client: Client) {
            self.client = client
            self.viewModel = ExploreViewModel(client: client)
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

extension ExploreController: ViewBuilder {
        func addSubviews() {
            view.addSubview(stateImageView)
            stateImageView.addSubview(kratosImageView)
            stateImageView.addSubview(topShadeView)
            topShadeView.addSubview(stateLabel)
            topShadeView.addSubview(districtLabel)
            view.addSubview(tableView)
        }
        
        func constrainViews() {
            stateImageView.snp.makeConstraints { make in
                make.top.equalToSuperview()
                make.leading.trailing.equalToSuperview()
                make.height.equalTo(190)
            }
            kratosImageView.snp.makeConstraints { make in
                make.width.equalTo(50)
                make.height.equalTo(kratosImageView.snp.width)
                make.top.equalToSuperview().offset(10)
                make.centerX.equalToSuperview()
            }
            topShadeView.snp.makeConstraints { make in
                make.leading.bottom.trailing.equalToSuperview()
                make.height.equalTo(50)
            }
            stateLabel.snp.makeConstraints { make in
                make.top.leading.equalToSuperview().offset(5)
            }
            districtLabel.snp.makeConstraints { make in
                make.bottom.equalToSuperview()
                make.leading.equalTo(stateLabel.snp.leading).offset(10)
            }
            tableView.snp.makeConstraints { make in
                make.top.equalTo(stateImageView.snp.bottom).offset(5)
                make.leading.equalToSuperview().offset(10)
                make.trailing.equalToSuperview().offset(-10)
                make.bottom.equalToSuperview().offset(-5)
            }
        }
        
        func style() {
            stateImageView.contentMode = .scaleToFill
            topShadeView.backgroundColor = .black
            topShadeView.alpha = 0.5
            
            view.style(with: .backgroundColor(.slate))
            stateLabel.style(with: [.font(.title), .titleColor(.white)])
            districtLabel.style(with: [.font(.subTitle), .titleColor(.white)])
        }
}
