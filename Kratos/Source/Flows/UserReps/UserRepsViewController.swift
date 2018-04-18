//
//  YourRepsViewController.swift
//  Kratos
//
//  Created by Dylan Straughan on 5/31/17.
//  Copyright © 2017 Kratos, Inc. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class UserRepsViewController: UIViewController, CurtainPresenter {
    
    // MARK: - Variables -
    let client: Client
    let viewModel: UserRepsViewModel
    let disposeBag = DisposeBag()
    let loadStatus = Variable<LoadStatus>(.none)
    
    var curtain: Curtain = Curtain()
    
    //TopImage
    let stateImageView = UIImageView(image: #imageLiteral(resourceName: "Image_WashingtonDC"))
    let topShadeView = UIView()
    let districtLabel = UILabel()
    let stateButton = UIButton()
    
    let tableView = UITableView()
    let dataSource: RxTableViewSectionedReloadDataSource<SectionModel<String, Person>>
    
    // MARK: - Initialization -
    init(client: Client) {
        self.client = client
        self.viewModel = UserRepsViewModel(client: client)
        self.dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, Person>>(configureCell: { dataSource, tableView, indexPath, item in
            let basicCell = tableView.dequeueReusableCell(withIdentifier: UserRepTableViewCell.identifier, for: indexPath)
            guard let cell = basicCell as? UserRepTableViewCell else { fatalError() }
            cell.configure(with: client, person: item)
            return cell
        })
        super.init(nibName: nil, bundle: nil)
        client.fetchUser()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        edgesForExtendedLayout = [.top, .right, .left]
        view.layoutIfNeeded()
        addSubviews()
        constrainViews()
        styleViews()
        bind()
        configureTableView()
        addCurtain()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setDefaultNavVC()
        stateImageView.addShadow()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        setDefaultNavVC()
    }
    
    // MARK: - Configuration -
    func configureTableView() {

        tableView.backgroundColor = .clear
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 5))
        tableView.register(UserRepTableViewCell.self, forCellReuseIdentifier: UserRepTableViewCell.identifier)
        tableView.isScrollEnabled = false
        tableView.rowHeight = (self.tableView.frame.height/CGFloat(3)) - 20
        tableView.sectionHeaderHeight = 5
        tableView.allowsSelection = true
        
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
    }
    
    func configureForOneRep() {
        tableView.rowHeight = self.tableView.frame.height - 20
        guard let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? UserRepTableViewCell else { return }
        cell.configureForSingleRep()
        tableView.layoutIfNeeded()
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
        topShadeView.addSubview(districtLabel)
        view.addSubview(stateButton)
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
        stateButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(10)
            make.centerY.equalTo(topShadeView)
        }
        districtLabel.snp.makeConstraints { make in
            make.top.bottom.leading.equalToSuperview().inset(10)
        }
        tableView.snp.makeConstraints { make in
            make.top.equalTo(stateImageView.snp.bottom).offset(5)
            make.bottom.trailing.leading.equalToSuperview().inset(10)
        }
    }
    
    func styleViews() {
        view.clipsToBounds = false
        stateImageView.contentMode = .scaleToFill
        topShadeView.style(with: .backgroundColor(.black))
        topShadeView.alpha = 0.8
        
        view.style(with: .backgroundColor(.slate))
        districtLabel.style(with: [.font(.subTitle),
                                   .titleColor(.white)])
        stateButton.contentEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5)
        stateButton.style(with: [.font(.tab),
                                 .cornerRadius(4),
                                 .backgroundColor(.kratosGreen)])
        tableView.clipsToBounds = false
        stateImageView.addShadow()
    }
}

// MARK: - Binds -
extension UserRepsViewController: RxBinder {
    func bind() {
        bindLoadStatus()
        bindTopView()
        bindRepsTableView()
    }
    func bindLoadStatus() {
        viewModel.loadStatus
            .asObservable()
            .bind(to: curtain.loadStatus)
            .disposed(by: disposeBag)
    }
    func bindTopView() {
        viewModel.url
            .asObservable()
            .filterNil()
            .map { URL(string: $0) }
            .bind(to: stateImageView.rx.setImage(with: #imageLiteral(resourceName: "Image_WashingtonDC")))
            .disposed(by: disposeBag)
        viewModel.state
            .asObservable()
            .map { State(rawValue: $0)?.fullName }
            .filterNil()
            .bind(to: stateButton.rx.title(for: .normal))
            .disposed(by: disposeBag)
        viewModel.district
            .asObservable()
            .filterNil()
            .map { $0.district != 0 ? $0.district.ordinal + " District" : "At Large" }
            .bind(to: districtLabel.rx.text)
            .disposed(by: disposeBag)
        stateButton.rx.tap
            .subscribe(
                onNext: { [weak self] in
                    guard let `self` = self else { return }
                    let vc = DistrictChangeController(client: self.client)
                    let navVC = UINavigationController(rootViewController: vc)
                    self.present(navVC, animated: true, completion: nil)
                }
            )
            .disposed(by: disposeBag)
    }
    func bindRepsTableView() {
        viewModel.representatives
            .asObservable()
            .map { $0.map {SectionModel(model: "", items: [$0]) } }
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        viewModel.representatives
            .asObservable()
            .filter { $0.count == 1 }
            .subscribe(
                onNext: { [weak self] _ in
                    self?.configureForOneRep()
                }
            )
            .disposed(by: disposeBag)
        tableView.rx.itemSelected
            .map { self.dataSource[$0] }
            .subscribe(
                onNext: { [weak self] model in
                    guard let client = self?.client else { return }
                    self?.navigationController?.pushViewController(RepresentativeController(client: client, representative: model), animated: true)
                }
            )
            .disposed(by: disposeBag)
    }
}

