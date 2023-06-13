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
    let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, Person>>()
    
    // MARK: - Initialization -
    init(client: Client) {
        self.viewModel = UserRepsViewModel(client: client)
        super.init(nibName: nil, bundle: nil)
        client.fetchUser()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        edgesForExtendedLayout = [.top]
        
        styleViews()
        addSubviews()

        bind()
        configureTableView()
        addCurtain()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setDefaultNavVC()
        tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        setDefaultNavVC()
    }
    
    // MARK: - Configuration -
    func configureTableView() {
        let rowHeightOffset: CGFloat = UIScreen.shouldElevateBottomMargin ? 30 : 20
        view.backgroundColor = Color.slate.value
        tableView.backgroundColor = .clear
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 5))
        tableView.register(UserRepTableViewCell.self, forCellReuseIdentifier: UserRepTableViewCell.identifier)
        tableView.isScrollEnabled = false
        tableView.rowHeight = (self.tableView.frame.height/CGFloat(3)) - rowHeightOffset
        tableView.sectionHeaderHeight = 5
        tableView.allowsSelection = true
        
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        dataSource.configureCell = { dataSource, tableView, indexPath, person in
            let basicCell = tableView.dequeueReusableCell(withIdentifier: UserRepTableViewCell.identifier, for: indexPath)
            guard let cell = basicCell as? UserRepTableViewCell else { fatalError() }
            cell.update(with: person)
            return cell
        }
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

fileprivate extension Dimension {
    /// 190px
    static let stateImageViewHeight: CGFloat = 190
}

// MARK: - ViewBuilder -
extension UserRepsViewController: ViewBuilder {
    
    func styleViews() {
        view.clipsToBounds = false
    }
    
    func addSubviews() {        
        addStateImageView()
        addTopShadeView()
        addDistrictLabel()
        addStateButton()
        addTableview()
    }
    
    private func addStateImageView() {
        view.addSubview(stateImageView)
        stateImageView.contentMode = .scaleToFill
        
        stateImageView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(Dimension.stateImageViewHeight)
        }
    }
    
    private func addTopShadeView() {
        stateImageView.addSubview(topShadeView)
        topShadeView.alpha = 0.3
        topShadeView.backgroundColor = Color.black.value
        
        topShadeView.snp.makeConstraints { make in
            make.bottom.leading.trailing.equalToSuperview()
            make.height.equalTo(Dimension.largeButtonHeight)
        }
    }
    
    private func addDistrictLabel() {
        stateImageView.addSubview(districtLabel)
        districtLabel.style(with: [.font(.h4),
                                   .titleColor(.white)])

        districtLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(Dimension.defaultMargin)
            make.centerY.equalTo(topShadeView)
        }
    }
    
    private func addStateButton() {
        view.addSubview(stateButton)
        stateButton.contentEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        stateButton.style(with: [.font(.tab),
                                 .cornerRadius(4),
                                 .backgroundColor(.kratosGreen)])

        stateButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(Dimension.defaultMargin)
            make.centerY.equalTo(topShadeView)
        }
    }
    
    private func addTableview() {
        view.addSubview(tableView)

        tableView.snp.makeConstraints { make in
            make.top.equalTo(stateImageView.snp.bottom).offset(5)
            make.trailing.leading.equalToSuperview().inset(10)
            make.bottom.equalTo(view.snp.bottomMargin).offset(-10)
        }
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
            .bind(to: self.stateImageView.rx.setImage(placeholder: #imageLiteral(resourceName: "Image_WashingtonDC")))
            .disposed(by: disposeBag)
        
        viewModel.state
            .map { $0.fullName }
            .bind(to: stateButton.rx.title(for: .normal))
            .disposed(by: disposeBag)
        
        viewModel.district
            .map { $0.district != 0 ? $0.district.ordinal + " District" : "At Large" }
            .bind(to: districtLabel.rx.text)
            .disposed(by: disposeBag)
        
        stateButton.rx.tap
            .subscribe(
                onNext: { [weak self] in
                    guard let `self` = self else { return }
                    let vc = DistrictChangeController(client: Client.provider())
                    let navVC = UINavigationController(rootViewController: vc)
                    self.present(navVC, animated: true, completion: nil)
                }
            )
            .disposed(by: disposeBag)
    }
    func bindRepsTableView() {
        viewModel.representatives
            .map { $0.map {SectionModel(model: "", items: [$0]) } }
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        viewModel.representatives
            .filter { $0.count == 1 }
            .subscribe(onNext: { [unowned self] _ in self.configureForOneRep() })
            .disposed(by: disposeBag)
        
        tableView.rx.itemSelected
            .map { self.dataSource[$0] }
            .subscribe(
                onNext: { [unowned self] model in
                    let vc = RepresentativeController(client: Client.provider(), representative: model)
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            )
            .disposed(by: disposeBag)
    }
}

