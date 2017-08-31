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
    
    let interactor = Interactor()
    
    // UIElements
    let headerView = UIView()
    let topView = UIView()
    let collectionView: UICollectionView
    let collectionViewDatasource = RxCollectionViewSectionedReloadDataSource<SectionModel<String, Subject>>()
    let addMoreSubjectsButton = UIButton()
    
    let tableView = UITableView()
    let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, Bill>>()

    // MARK: - Initializers -
    init(client: Client) {
        self.client = client
        let layout = UICollectionViewLayout()
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.estimatedItemSize = CGSize(width: 100, height: 30)
        flowLayout.minimumLineSpacing = 1000
        flowLayout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.collectionViewLayout = flowLayout
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
        addSubviews()
        constrainViews()
        styleViews()
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavVC()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        setDefaultNavVC()
    }
    
    // MARK: - Configuration -
    func configureNavVC() {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 27, height: 27))
        button.setImage(#imageLiteral(resourceName: "gearIcon").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(gearIconSelected), for: .touchUpInside)
        let barButton = UIBarButtonItem(customView: button)
        navigationItem.rightBarButtonItem = barButton
    }
    
    func configureCollectionView() {
        collectionView.allowsMultipleSelection = true
        collectionView.register(SubjectCell.self, forCellWithReuseIdentifier: SubjectCell.identifier)
        collectionView.rx.setDelegate(self).addDisposableTo(disposeBag)
        collectionView.backgroundColor = Color.white.value
        collectionView.showsHorizontalScrollIndicator = false
    }
}

// MARK: - View Builder -
extension UserController: ViewBuilder {
    func addSubviews() {
        view.addSubview(tableView)
        view.addSubview(headerView)
        view.addSubview(topView)
        topView.addSubview(addMoreSubjectsButton)
        topView.addSubview(collectionView)
    }
    
    func constrainViews() {
        headerView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(44)
        }
        topView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(10)
            make.height.equalTo(35)
        }
        addMoreSubjectsButton.snp.makeConstraints { make in
            make.top.bottom.trailing.equalToSuperview()
            make.width.equalTo(30)
        }
        collectionView.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.trailing.equalTo(addMoreSubjectsButton.snp.leading)
        }
        tableView.snp.makeConstraints { make in
            make.top.equalTo(topView.snp.bottom).offset(10)
            make.trailing.leading.equalToSuperview().inset(10)
            make.bottom.equalToSuperview().offset(-5)
        }
    }
    
    func styleViews() {
        view.style(with: .backgroundColor(.slate))
        headerView.style(with: .backgroundColor(.white))
        addMoreSubjectsButton.setImage(#imageLiteral(resourceName: "plusIcon"), for: .normal)
        addMoreSubjectsButton.backgroundColor = Color.white.value
    }
}

// MARK: - Interaction Responder -
extension UserController: InteractionResponder {
    func setupInteractions() { }
    
    func gearIconSelected() {
        let vc = MenuController(client: client)
        vc.transitioningDelegate = self
        vc.interactor = interactor
        self.present(vc, animated: true, completion: nil)
    }
}

extension UserController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 4
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(5, 5, 0, 0)
    }
}

// MARK: - Binds  -
extension UserController: RxBinder {
    func bind() {
        viewModel.trackedSubjects.asObservable()
            .debug()
            .bind(to: self.collectionView.rx.items(cellIdentifier: SubjectCell.identifier, cellType: SubjectCell.self)) { row, data, cell in
                cell.configure(with: data)
            }
            .disposed(by: disposeBag)
    }
}

// MARK: - Transitions  -
extension UserController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PresentMenuAnimator()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissMenuAnimator()
        
    }
    
    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactor.hasStarted ? interactor : nil
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactor.hasStarted ? interactor : nil
    }
}
