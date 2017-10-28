//
//  UserBillsController.swift
//  Kratos
//
//  Created by Dylan Straughan on 8/1/17.
//  Copyright © 2017 Kratos, Inc. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxDataSources
import SnapKit

class UserController: UIViewController, CurtainPresenter {
    
    // MARK: - Variables - 
    // Standard
    let client: Client
    let viewModel: UserViewModel
    let disposeBag = DisposeBag()
    
    // UIElements
    let header = UIView()
    let topView = UIView()
    let collectionView: UICollectionView
    let addMoreSubjectsButton = UIButton()
    let clearSelectedSubjectButton = UIButton()
    
    let tableViewView = UIView()
    let tableView = UITableView()
    let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, Bill>>()
    let emptyStateLabel = UILabel()
    
    var curtain: Curtain = Curtain()

    let headerHeight: CGFloat = 64
    let buttonWidth: CGFloat = 35
    
    // MARK: - Initializers -
    init(client: Client) {
        self.client = client
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.estimatedItemSize = CGSize(width: 100, height: 40)
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumLineSpacing = 4
        flowLayout.minimumInteritemSpacing = 4
        flowLayout.sectionInset = UIEdgeInsetsMake(2, 5, 2, 0)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        self.collectionView = collectionView
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
        configureCollectionView()
        configureTableView()
        addSubviews()
        constrainViews()
        bind()
        styleViews()
        view.layoutIfNeeded()
        addCurtain()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavVC()
        view.layoutIfNeeded()
        header.addShadow()
        topView.addShadow()
        tableViewView.addShadow()
        viewModel.fetchTrackedSubjects()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        setDefaultNavVC()
    }
    
    // MARK: - Configuration -
    func configureNavVC() {
        self.navigationItem.title = localize(.userTitle)
        var rightBarButtonItems: [UIBarButtonItem] = []
        if let user = client.user.value {
            let button = UIButton()
            button.snp.remakeConstraints { make in
                make.height.width.equalTo(30).priority(1000)
            }
            button.style(with: .font(.monospaced))
            button.setTitle(user.firstName.firstLetter, for: .normal)
            button.backgroundColor = user.party?.color.value ?? .gray
            button.layer.cornerRadius = CGFloat(30/2)
            button.clipsToBounds = false
            button.addTarget(self, action: #selector(presentMenu), for: .touchUpInside)
            let item = UIBarButtonItem(customView: button)
            rightBarButtonItems.append(item)
        }
        self.navigationItem.rightBarButtonItems = rightBarButtonItems
        self.navigationController?.navigationBar.setNeedsLayout()
    }
    
    func configureCollectionView() {
        collectionView.allowsMultipleSelection = true
        collectionView.register(SubjectCell.self, forCellWithReuseIdentifier: SubjectCell.identifier)
        collectionView.backgroundColor = Color.white.value
        collectionView.showsHorizontalScrollIndicator = false
    }
    
    func configureTableView() {
        self.automaticallyAdjustsScrollViewInsets = false
        tableView.contentInset = .zero
        tableView.backgroundColor = .clear
        tableView.register(BillCell.self, forCellReuseIdentifier: BillCell.identifier)
        tableView.estimatedRowHeight = 100
        tableView.tableHeaderView = nil
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.allowsSelection = true
        tableView.tableFooterView = UIView()
        tableView.showsVerticalScrollIndicator = false
    }
    // MARK - Animations -
    func animateClearSubjectButton(for clearable: Bool) {
        UIView.animate(withDuration: 0.2) {
            let width: CGFloat = clearable ? 35 : 0
            self.clearSelectedSubjectButton.snp.remakeConstraints { make in
                make.top.bottom.leading.equalToSuperview()
                make.width.equalTo(width)
            }
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK - Navigation -
    func presentSearch() {
        let vc = SearchController(client: client)
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    func presentMenu() {
        let vc = MenuController(client: client).embedInNavVC()
        self.present(vc, animated: true, completion: nil)
    }
}

// MARK: - View Builder -
extension UserController: ViewBuilder {
    func addSubviews() {
        view.addSubview(header)
        view.addSubview(tableViewView)
        tableViewView.addSubview(tableView)
        tableViewView.addSubview(emptyStateLabel)
        view.addSubview(topView)
        topView.addSubview(clearSelectedSubjectButton)
        topView.addSubview(addMoreSubjectsButton)
        topView.addSubview(collectionView)
    }
    
    func constrainViews() {
        header.snp.remakeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(headerHeight)
        }
        topView.snp.remakeConstraints { make in
            make.top.equalTo(header.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(10)
            make.height.equalTo(44)
        }
        addMoreSubjectsButton.snp.remakeConstraints { make in
            make.top.bottom.trailing.equalToSuperview()
            make.width.equalTo(buttonWidth)
        }
        clearSelectedSubjectButton.snp.remakeConstraints { make in
            make.top.bottom.leading.equalToSuperview()
            make.width.equalTo(buttonWidth)
        }
        collectionView.snp.remakeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.trailing.equalTo(addMoreSubjectsButton.snp.leading)
            make.leading.equalTo(clearSelectedSubjectButton.snp.trailing)
        }
        tableViewView.snp.remakeConstraints { make in
            make.top.equalTo(topView.snp.bottom).offset(10)
            make.trailing.leading.equalToSuperview().inset(10)
            make.bottom.equalToSuperview()
        }
        emptyStateLabel.snp.remakeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.width.equalToSuperview().offset(-40)
        }
        tableView.snp.remakeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func styleViews() {
        view.style(with: .backgroundColor(.slate))
        tableView.style(with: .backgroundColor(.white))
        header.style(with: .backgroundColor(.white))
        addMoreSubjectsButton.style(with: [.titleColor(.kratosRed),
                                           .font(.tab),
                                           .backgroundColor(.white)])
        clearSelectedSubjectButton.style(with: .backgroundColor(.white))
        let image = #imageLiteral(resourceName: "clearIcon").af_imageScaled(to: CGSize(width: 15, height: 15))
        clearSelectedSubjectButton.setImage(image, for: .normal)
        addMoreSubjectsButton.setImage(#imageLiteral(resourceName: "chevronRedRightIcon"), for: .normal)
        addMoreSubjectsButton.addShadow(shadowColor: .black, shadowOffset: CGSize(width: 1, height: 0) , shadowOpacity: 0.2, shadowRadius: 1)
        clearSelectedSubjectButton.addShadow(shadowColor: .black, shadowOffset: CGSize(width: 1, height: 0) , shadowOpacity: 0.2, shadowRadius: 1)
        emptyStateLabel.style(with: [.font(.subHeader),
                                     .titleColor(.gray),
                                     .numberOfLines(4),
                                     .textAlignment(.center)])
    }
}

// MARK: - Interaction Responder -
extension UserController: InteractionResponder {
    func setupInteractions() { }
}

// MARK: - Binds  -
extension UserController: RxBinder {
    func bind() {
        viewModel.trackedSubjects
            .asObservable()
            .bind(to: self.collectionView.rx.items(cellIdentifier: SubjectCell.identifier, cellType: SubjectCell.self)) { row, data, cell in
                cell.configure(with: data)
                cell.label.preferredMaxLayoutWidth = 100
            }
            .disposed(by: disposeBag)
        viewModel.presentedBills
            .asObservable()
            .do(onNext: { (bills) in
                print("Presented Bills - \(bills.count)")
            })
            .bind(to: tableView.rx.items(cellIdentifier: BillCell.identifier, cellType: BillCell.self)) { row, data, cell in
                cell.configure(with: data)
            }
            .disposed(by: disposeBag)
        viewModel.trackedSubjects
            .asObservable()
            .skip(1)
            .delay(0.2, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] subjects in
                
                Array(0..<subjects.count).reversed().forEach { index in
                    self?.collectionView.selectItem(at: IndexPath(item: index, section: 0), animated: true, scrollPosition: .left)
                }
            })
            .disposed(by: disposeBag)
        viewModel.clearable
            .asObservable()
            .subscribe(onNext: { [weak self] clearable in
                self?.animateClearSubjectButton(for: clearable)
            })
            .disposed(by: disposeBag)
        collectionView.rx.itemSelected
            .map { _ in self.collectionView.indexPathsForSelectedItems ?? [] }
            .map { $0.map { self.viewModel.trackedSubjects.value[$0.row] }}
            .bind(to: viewModel.selectedSubjects)
            .disposed(by: disposeBag)
        collectionView.rx.itemDeselected
            .map { _ in self.collectionView.indexPathsForSelectedItems ?? [] }
            .map { $0.map { self.viewModel.trackedSubjects.value[$0.row] }}
            .bind(to: viewModel.selectedSubjects)
            .disposed(by: disposeBag)
        tableView.rx.modelSelected(Bill.self)
            .subscribe(onNext: { [weak self] bill in
                 guard let `self` = self else { fatalError("self deallocated before it was accessed") }
                let vc = BillController(client: self.client, bill: bill)
                self.navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: disposeBag)
        tableView.rx.contentOffset
            .map { $0.y > (self.tableView.contentSize.height - self.tableView.frame.height - 100) }
            .distinctUntilChanged()
            .filter { $0 == true }
            .map { _ in () }
            .bind(to: viewModel.fetchAction)
            .disposed(by: disposeBag)
        addMoreSubjectsButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let `self` = self else { fatalError("self deallocated before it was accessed") }
                let vc = SubjectSelectionController(client: self.client)
                self.navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: disposeBag)
        clearSelectedSubjectButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let indexPaths = self?.collectionView.indexPathsForSelectedItems else { return }
                indexPaths.forEach {
                    self?.collectionView.deselectItem(at: $0, animated: true)
                    self?.collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .left, animated: true)
                    self?.viewModel.resetBills()
                    self?.viewModel.clearSelectedSubjects()
                }
            })
            .disposed(by: disposeBag)
        viewModel.emptyState
            .asObservable()
            .map { $0.title }
            .bind(to: emptyStateLabel.rx.text)
            .disposed(by: disposeBag)
        viewModel.loadStatus
            .asObservable()
            .bind(to: curtain.loadStatus)
            .disposed(by: disposeBag)
    }
}
