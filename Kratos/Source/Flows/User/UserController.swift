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
    let emptyStateLabel = UILabel(style: .h3gray)
    
    var curtain: Curtain = Curtain()
    
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
        styleViews()
        addSubviews()
        
        bind()
        configureCollectionView()
        configureTableView()
        view.layoutIfNeeded()
        addCurtain()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        localizeStrings()
        viewModel.fetchTrackedSubjects()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        setDefaultNavVC()
    }
    
    // MARK: - Configuration -
    func configureRightBarButton(with user: User) {
//        self.navigationItem.title = localize(.userTitle)
        var rightBarButtonItems: [UIBarButtonItem] = []
        
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
    @objc func presentMenu() {
        let vc = MenuController(client: client).embedInNavVC()
        self.present(vc, animated: true, completion: nil)
    }
}

fileprivate extension Dimension {
    /// 60px
    static let buttonWidth: CGFloat = 35
}

// MARK: - View Builder -
extension UserController: Localizer {
    func localizeStrings() {
        navigationItem.title = localize(.userTitle)
    }
}

// MARK: - View Builder -
extension UserController: ViewBuilder {
    func styleViews() {
        edgesForExtendedLayout = [.top, .right, .left]
        view.backgroundColor = .slate
    }
    
    func addSubviews() {
        addHeader()
        addTopView()
        addClearButton()
        addAddButton()
        addCollectionView()
        addTableViewView()
        addTableView()
        addEmptyStateLabel()
    }
    
    private func addHeader() {
        view.addSubview(header)
        header.backgroundColor = .white

        header.snp.remakeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(Dimension.topMargin)
        }
    }
    
    private func addTopView() {
        view.addSubview(topView)
        
        topView.snp.remakeConstraints { make in
            make.top.equalTo(header.snp.bottom).offset(Dimension.smallMargin)
            make.leading.trailing.equalToSuperview().inset(Dimension.smallMargin)
            make.height.equalTo(Dimension.tabButtonHeight)
        }
    }
    
    private func addClearButton() {
        topView.addSubview(clearSelectedSubjectButton)
        let image = #imageLiteral(resourceName: "redClearIcon").af_imageScaled(to: CGSize(width: 15, height: 15))
        clearSelectedSubjectButton.setImage(image, for: .normal)
        clearSelectedSubjectButton.backgroundColor = .white

        
        clearSelectedSubjectButton.snp.remakeConstraints { make in
            make.top.bottom.leading.equalToSuperview()
            make.width.equalTo(Dimension.buttonWidth)
        }
    }
    
    private func addAddButton() {
        topView.addSubview(addMoreSubjectsButton)
        addMoreSubjectsButton.setImage(#imageLiteral(resourceName: "chevronRedRightIcon"), for: .normal)
        addMoreSubjectsButton.backgroundColor = Color.white.value
        
        addMoreSubjectsButton.snp.remakeConstraints { make in
            make.top.bottom.trailing.equalToSuperview()
            make.width.equalTo(Dimension.buttonWidth)
        }
    }
    
    private func addCollectionView() {
        topView.addSubview(collectionView)
     
        collectionView.snp.remakeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.trailing.equalTo(addMoreSubjectsButton.snp.leading)
            make.leading.equalTo(clearSelectedSubjectButton.snp.trailing)
        }
    }
    
    private func addTableViewView() {
        view.addSubview(tableViewView)

        tableViewView.snp.remakeConstraints { make in
            make.top.equalTo(topView.snp.bottom).offset(Dimension.smallMargin)
            make.trailing.leading.equalToSuperview().inset(Dimension.smallMargin)
            make.bottom.equalTo(view.snp.bottomMargin).offset(-Dimension.smallMargin)
        }
    }
    
    private func addTableView() {
        tableViewView.addSubview(tableView)
        tableView.backgroundColor = .white

        tableView.snp.remakeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func addEmptyStateLabel() {
        tableViewView.addSubview(emptyStateLabel)
        emptyStateLabel.numberOfLines = 4
        emptyStateLabel.textAlignment = .center

        emptyStateLabel.snp.remakeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.width.equalToSuperview().offset(-Dimension.tabButtonHeight)
        }
    }
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
        
        viewModel.user
            .subscribe(onNext: { [unowned self] user in self.configureRightBarButton(with: user) })
            .disposed(by: disposeBag)
    }
}
