//
//  SubjectSelectionController.swift
//  Kratos
//
//  Created by Dylan Straughan on 9/6/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxDataSources
import SnapKit

class SubjectSelectionController: UIViewController {
    
    // MARK: - Variables -
    // Standard
    let client: Client
    let viewModel: SubjectSelectionViewModel
    let disposeBag = DisposeBag()
    
    let searchView = UIView()
    let searchTextField = UITextField()
    let searchImageView = UIImageView(image: #imageLiteral(resourceName: "searchIcon"))
    let clearButton = UIButton()
    let tableViewView = UIView()
    let tableView = UITableView()
    let headerView = UIView()
    
    let headerViewHeight: CGFloat = 64
    let textfieldHeight: CGFloat = 45
    
    // MARK: - Initializers -\
    init(client: Client) {
        self.client = client
        self.viewModel = SubjectSelectionViewModel(client: client)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        edgesForExtendedLayout = [.top, .right, .left]
        configureTableView()
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
        self.title = localize(.subjectSelectionTitle)
    }
    
    func configureTableView() {
        self.automaticallyAdjustsScrollViewInsets = false
        tableView.contentInset = .zero
        tableView.backgroundColor = .clear
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.estimatedRowHeight = 100
        tableView.tableHeaderView = nil
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.allowsSelection = true
        tableView.tableFooterView = UIView()
        tableView.showsVerticalScrollIndicator = false
    }
}

extension SubjectSelectionController: ViewBuilder {
    func addSubviews() {
        view.addSubview(tableViewView)
        view.addSubview(searchView)
        searchView.addSubview(searchTextField)
        searchView.addSubview(searchImageView)
        searchView.addSubview(clearButton)
        tableViewView.addSubview(tableView)
        view.addSubview(headerView)
    }
    
    func constrainViews() {
        headerView.snp.remakeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(headerViewHeight)
        }
        searchView.snp.remakeConstraints { make in
            make.top.equalTo(headerView.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(10)
            make.height.equalTo(45)
        }
        searchImageView.snp.remakeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.width.equalTo(searchImageView.snp.height)
        }
        clearButton.snp.remakeConstraints { make in
            make.trailing.top.bottom.equalToSuperview()
            make.width.equalTo(clearButton.snp.height)
        }
        searchTextField.snp.remakeConstraints { make in
            make.leading.equalTo(searchImageView.snp.trailing)
            make.top.bottom.equalToSuperview()
            make.trailing.equalTo(clearButton.snp.leading)
        }
        tableViewView.snp.remakeConstraints { make in
            make.top.equalTo(searchView.snp.bottom).offset(10)
            make.bottom.trailing.leading.equalToSuperview().inset(10)
        }
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func styleViews() {
        view.style(with: .backgroundColor(.slate))
        headerView.style(with: .backgroundColor(.white))
        clearButton.setImage(#imageLiteral(resourceName: "clearIcon"), for: .normal)
    }
}

// MARK: - Binds  -
extension SubjectSelectionController: RxBinder {
    func bind() {
        viewModel.presentedSubjects
            .asObservable()
            .bind(to: self.tableView.rx.items(cellIdentifier: SubjectSelectionCell.identifier, cellType: SubjectSelectionCell.self)) { row, model, cell in
                cell.configure(with: model)
            }
            .disposed(by: disposeBag)
        
        viewModel.selectedIndexes
            .asObservable()
            .filter { !$0.isEmpty }
            .take(1)
            .subscribe(onNext: { [weak self] subjects in
                Array(0..<subjects.count).forEach { index in
                    self?.tableView.selectRow(at: IndexPath(item: index, section: 0), animated: false, scrollPosition: .middle)
                }
            })
            .disposed(by: disposeBag)
        
//        tableView.rx.itemSelected
//            .map { _ in self.tableView.indexPathsForSelectedRows ?? [] }
//            .map { $0.map { self.viewModel.selectedSubjects.value[$0.row] }}
//            .bind(to: viewModel.selectedSubjects)
//            .disposed(by: disposeBag)
//        
//        tableView.rx.itemDeselected
//            .map { _ in self.tableView.indexPathsForSelectedRows ?? [] }
//            .map { $0.map { self.viewModel.selectedSubjects.value[$0.row] }}
//            .bind(to: viewModel.selectedSubjects)
//            .disposed(by: disposeBag)
    }
}
