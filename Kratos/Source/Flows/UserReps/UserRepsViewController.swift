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
    
    let popView = UIView()
    let shade = UIView()
    let stateButton = UIButton()
    let testButton = UIButton()
    let statesTableView = UITableView()
    let statesTitle = UILabel()
    let statesResetButton = UIButton()
    let statesSubmitButton = UIButton()
    
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
        styleViews()
        bind()
        configureTableView()
        addCurtain()
        view.layoutIfNeeded()
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
        
        dataSource.configureCell = { dataSource, tableView, indexPath, item in
            let basicCell = tableView.dequeueReusableCell(withIdentifier: UserRepTableViewCell.identifier, for: indexPath)
            guard let cell = basicCell as? UserRepTableViewCell else { fatalError() }
            cell.configure(with: self.client, person: item)
            return cell
        }
        
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
    }
    
    func configureStatesTableView() {
        statesTableView.backgroundColor = .clear
        statesTableView.tableFooterView = UIView()
        statesTableView.register(StateCell.self, forCellReuseIdentifier: StateCell.identifier)
        statesTableView.estimatedRowHeight = 500
        statesTableView.rowHeight = UITableViewAutomaticDimension
        statesTableView.allowsSelection = true
        statesTableView.allowsMultipleSelection = false
        
        statesTableView.rx.setDelegate(self)
            .addDisposableTo(disposeBag)
    }
    
    func configureForOneRep() {
        tableView.rowHeight = self.tableView.frame.height - 20
        guard let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? UserRepTableViewCell else { return }
        cell.configureForSingleRep()
        tableView.layoutIfNeeded()
    }
    
    func animateInPopView() {
        UIView.animate(withDuration: 0.3) {
            self.popView.snp.updateConstraints { make in
                make.trailing.equalToSuperview().offset(0)
            }
            self.shade.alpha = 1
            self.view.layoutIfNeeded()
        }
    }
    
    func dismissPopView() {
        UIView.animate(withDuration: 0.3) {
            self.popView.snp.updateConstraints { make in
                make.trailing.equalToSuperview().offset(100)
            }
            self.shade.alpha = 0
            self.view.layoutIfNeeded()
        }
    }
    
    func configureGestureRecogniers() {
        shade.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissPopView)))
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
        view.addSubview(shade)
        view.addSubview(popView)
        popView.addSubview(statesTitle)
        popView.addSubview(statesResetButton)
        popView.addSubview(statesTableView)
        popView.addSubview(statesSubmitButton)
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
        shade.snp.remakeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        popView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(100)
            make.top.bottom.equalToSuperview()
            make.width.equalTo(100)
        }
        statesTitle.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        statesResetButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(statesTitle.snp.bottom)
        }
        statesSubmitButton.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(50)
        }
        statesTableView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(statesResetButton.snp.bottom)
            make.bottom.equalTo(statesSubmitButton.snp.top)
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
        shade.alpha = 0
        shade.style(with: .backgroundColor(.black))
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
            .map { $0 != 0 ? $0.ordinal + " District" : "At Large" }
            .bind(to: districtLabel.rx.text)
            .disposed(by: disposeBag)
        stateButton.rx.controlEvent([.touchUpInside])
            .debug("Statebutton Tap", trimOutput: false)
            .subscribe(
                onNext: { [weak self] in
                    guard let `self` = self else { return }
                    self.animateInPopView()
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
    func bindStatesTableView() {
        viewModel.stateDistrictModels
            .asObservable()
            .bind(to: statesTableView.rx.items(cellIdentifier: StateCell.identifier, cellType: StateCell.self)) { tv, model, cell in
                
            }
            .disposed(by: disposeBag)
        
    }
}

