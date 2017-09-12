//
//  YourRepsViewController.swift
//  Kratos
//
//  Created by Dylan Straughan on 5/31/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import RxDataSources


class UserRepsViewController: UIViewController {
    
    // MARK: - Variables -
    let client: Client
    let viewModel: UserRepsViewModel
    let disposeBag = DisposeBag()
    let loadStatus = Variable<LoadStatus>(.none)
    
    //TopImage
    let topImage = UIImageView()
    let topShadeView = UIView()
    let stateImageView = UIImageView()
    let stateLabel = UILabel()
    let districtLabel = UILabel()
    
    let tableView = UITableView()
    let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, Person>>()
    
    // MARK: - Initialization -
    init(client: Client) {
        self.client = client
        self.viewModel = UserRepsViewModel(client: client)
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
        bind()
        configureTableView()
        styleViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setDefaultNavVC()
        configureNavVC()
        topImage.addShadow()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        setDefaultNavVC()
    }
    
    // MARK: - Configuration -
    func configureNavVC() {
        navigationItem.titleView = UIImageView(image: #imageLiteral(resourceName: "kratosSelectedIcon"))
    }
    
    func configureTableView() {

        tableView.backgroundColor = .clear
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 5))
        tableView.register(UserRepTableViewCell.self, forCellReuseIdentifier: UserRepTableViewCell.identifier)
        tableView.isScrollEnabled = false
        tableView.rowHeight = (self.tableView.frame.height/CGFloat(3)) - 20
        tableView.sectionHeaderHeight = 5
        tableView.allowsSelection = true
        
        dataSource.configureCell = { dataSource, tableView, indexPath, item in
            let basicCell = tableView.dequeueReusableCell(withIdentifier: UserRepTableViewCell.identifier, for: indexPath)
            guard let cell = basicCell as? UserRepTableViewCell else { fatalError() }
            cell.configure(with: self.client, person: item)
            return cell
        }
        
        tableView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
        
    }
}

// MARK: - UITableViewDelegate -
extension UserRepsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 5))
    }
}

// MARK: - ViewBuilder -
extension UserRepsViewController: ViewBuilder {
    func addSubviews() {        
        view.addSubview(stateImageView)
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
        topShadeView.snp.makeConstraints { make in
            make.leading.bottom.trailing.equalToSuperview()
        }
        stateLabel.snp.makeConstraints { make in
            make.top.bottom.trailing.equalToSuperview().inset(10)
        }
        districtLabel.snp.makeConstraints { make in
            make.top.bottom.leading.equalToSuperview().inset(10)
        }
        tableView.snp.makeConstraints { make in
            make.top.equalTo(stateImageView.snp.bottom).offset(5)
            make.trailing.leading.equalToSuperview().inset(10)
            make.bottom.equalToSuperview().inset(10)
        }
    }
    
    func styleViews() {
        view.clipsToBounds = false
        stateImageView.contentMode = .scaleToFill
        topShadeView.style(with: .backgroundColor(.black))
        topShadeView.alpha = 0.8
        
        view.style(with: .backgroundColor(.slate))
        stateLabel.style(with: [.font(.subTitle),
                                .titleColor(.white)])
        districtLabel.style(with: [.font(.subTitle),
                                   .titleColor(.white)])
        tableView.clipsToBounds = false
        topImage.addShadow()
    }
}

// MARK: - Binds -
extension UserRepsViewController: RxBinder {
    func bind() {
        
        //Assumption of having 3 representatives.
        viewModel.representatives
            .asObservable()
            .map { $0.map {SectionModel(model: "", items: [$0]) } }
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        tableView.rx.itemSelected
            .map { self.dataSource[$0] }
            .subscribe(onNext: { [weak self] model in
                guard let client = self?.client else { return }
                self?.navigationController?.pushViewController(RepresentativeController(client: client, representative: model), animated: true)
            })
            .disposed(by: disposeBag)
        
        viewModel.stateImage
            .asObservable()
            .bind(to: stateImageView.rx.image)
            .disposed(by: disposeBag)
        
        viewModel.state
            .asObservable()
            .map { State(rawValue: $0)?.fullName }
            .filterNil()
            .bind(to: stateLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.district
            .asObservable()
            .filterNil()
            .map { $0 != 0 ? $0.ordinal + " District" : "At Large" }
            .bind(to: districtLabel.rx.text)
            .disposed(by: disposeBag)
        
        //Bind loadStatus to loadStatus
    }
}
