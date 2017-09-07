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

    let tableView = UITableView()
    let headerView = UIView()
    
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
        edgesForExtendedLayout = [.top, .right, .left, .bottom]
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
        view.addSubview(tableView)
        view.addSubview(headerView)
    }
    
    func constrainViews() {
        headerView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(44)
        }
        tableView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom).offset(10)
            make.trailing.leading.equalToSuperview().inset(10)
            make.bottom.equalToSuperview().offset(-5)
        }
    }
    
    func styleViews() {
        view.style(with: .backgroundColor(.slate))
        headerView.style(with: .backgroundColor(.white))
    }
}

// MARK: - Binds  -
extension SubjectSelectionController: RxBinder {
    func bind() {
        viewModel.subjects
            .asObservable()
            .bind(to: self.tableView.rx.items(cellIdentifier: "Cell")) {
                row, model, cell in
                    cell.textLabel?.style(with: [.font(.header),
                                                 .titleColor(.gray),
                                                 .numberOfLines(5)])
                    cell.separatorInset = .zero
                    cell.textLabel?.text = model.name
                }
            .disposed(by: disposeBag)
        
        viewModel.selectedSubjects
            .asObservable()
            .take(1)
            .delay(0.2, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] subjects in
                Array(0..<subjects.count).forEach { index in
                    self?.tableView.selectRow(at: IndexPath(item: index, section: 0), animated: true, scrollPosition: .middle)
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
