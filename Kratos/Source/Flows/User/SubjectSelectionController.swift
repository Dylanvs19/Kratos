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

class SubjectSelectionController: UIViewController, CurtainPresenter, AnalyticsEnabled {
    
    // MARK: - Variables -
    // Standard
    let client: Client
    let viewModel: SubjectSelectionViewModel
    let disposeBag = DisposeBag()
    
    let headerView = UIView()
    
    let searchView = UIView()
    let searchTextField = UITextField()
    let searchImageView = UIImageView(image: #imageLiteral(resourceName: "searchIcon").af_imageScaled(to: CGSize(width: 15, height: 15)))
    let clearTextButton = UIButton()
    
    let tableViewView = UIView()
    let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, Subject>>()
    let tableView = UITableView()
    
    let submitButton = UIButton()
    let clearSelectionsButton = UIButton()
    
    var curtain: Curtain = Curtain()
    
    let headerViewHeight: CGFloat = 64
    let textfieldHeight: CGFloat = 45
    
    // MARK: - Initializers -
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
        configureTextField()
        localizeStrings()
        addSubviews()
        constrainViews()
        styleViews()
        bind()
        addCurtain()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavVC()
        view.layoutIfNeeded()
        tableViewView.addShadow()
        searchView.addShadow()
        log(event: .subjectSelection)
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
        tableView.register(SubjectSelectionCell.self, forCellReuseIdentifier: SubjectSelectionCell.identifier)
        tableView.estimatedRowHeight = 100
        tableView.tableHeaderView = nil
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.allowsMultipleSelection = true
        tableView.tableFooterView = UIView()
        tableView.showsVerticalScrollIndicator = false
        tableView.tintColor = Color.gray.value
        tableView.sectionIndexBackgroundColor = Color.white.value
        
        dataSource.configureCell = {(dataSource, tv, indexPath, element) in
            guard let cell = tv.dequeueReusableCell(withIdentifier: SubjectSelectionCell.identifier, for: indexPath) as? SubjectSelectionCell else { return UITableViewCell() }
            cell.configure(with: element)
            return cell
        }
        
        dataSource.titleForHeaderInSection = { ds, index in
            return ds[index].model
        }
        
        dataSource.sectionForSectionIndexTitle = { ds, title, index in
            return index
        }
        
        dataSource.sectionIndexTitles = { ds in
            return ds.sectionModels.map { $0.model.firstLetter }
        }
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
    }
    
    func configureTextField() {
        searchTextField.delegate = self
    }
    
    func animateClearSubject(shouldShow: Bool) {
        UIView.animate(withDuration: 0.2) {
            let height: CGFloat = shouldShow ? 50 : 0
            self.submitButton.snp.remakeConstraints { make in
                make.bottom.leading.trailing.equalToSuperview()
                make.height.equalTo(height)
            }
            self.view.layoutIfNeeded()
        }
    }
}

// MARK: - ViewBuilder -
extension SubjectSelectionController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard dataSource.sectionModels.count > section else { return nil }

        let view = UIView()
        let label = UILabel()
        let divider = UIView()
        view.addSubview(label)
        view.addSubview(divider)
        label.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(10)
            make.top.bottom.equalToSuperview().inset(10)
            make.trailing.equalToSuperview()
        }
        divider.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.leading.trailing.bottom.equalToSuperview()
        }
        label.text = dataSource.sectionModels[section].model
        label.style(with: [.font(.title),
                           .backgroundColor(.white)])
        view.style(with: .backgroundColor(.white))
        divider.style(with: .backgroundColor(.gray))
        
        return view
    }
}

// MARK: - ViewBuilder -
extension SubjectSelectionController: ViewBuilder {
    func addSubviews() {
        view.addSubview(headerView)
        view.addSubview(searchView)
        searchView.addSubview(searchTextField)
        searchView.addSubview(searchImageView)
        searchView.addSubview(clearTextButton)
        
        view.addSubview(tableViewView)
        tableViewView.addSubview(tableView)
        view.addSubview(submitButton)
        
    }
    
    func constrainViews() {
        headerView.snp.remakeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(headerViewHeight)
        }
        searchView.snp.remakeConstraints { make in
            make.top.equalTo(headerView.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(10)
            make.height.equalTo(35)
        }
        searchImageView.snp.remakeConstraints { make in
            make.top.bottom.leading.equalToSuperview().inset(5)
            make.width.equalTo(searchImageView.snp.height)
        }
        clearTextButton.snp.remakeConstraints { make in
            make.top.bottom.trailing.equalToSuperview().inset(5)
            make.width.equalTo(clearTextButton.snp.height)
        }
        searchTextField.snp.remakeConstraints { make in
            make.leading.equalTo(searchImageView.snp.trailing).offset(5)
            make.top.bottom.equalToSuperview()
            make.trailing.equalTo(clearTextButton.snp.leading)
        }
        submitButton.snp.remakeConstraints { make in
            make.bottom.leading.trailing.equalToSuperview()
            make.height.equalTo(0)
        }
        tableViewView.snp.remakeConstraints { make in
            make.top.equalTo(searchView.snp.bottom).offset(10)
            make.leading.equalToSuperview().inset(10)
            make.bottom.equalTo(submitButton.snp.top)
            make.trailing.equalToSuperview().inset(10)
        }
        tableView.snp.remakeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func styleViews() {
        view.style(with: .backgroundColor(.slate))
        headerView.style(with: .backgroundColor(.white))
        searchView.style(with: .backgroundColor(.white))
        tableView.style(with: .backgroundColor(.white))
        clearTextButton.setImage(#imageLiteral(resourceName: "clearIcon").af_imageScaled(to: CGSize(width: 15, height: 15)), for: .normal)
        submitButton.style(with: [.backgroundColor(.kratosRed),
                                  .font(.title),
                                  .highlightedTitleColor(.lightGray)])
        submitButton.clipsToBounds = true
        searchTextField.style(with: .font(.tab))
    }
}

// MARK: - Binds  -
extension SubjectSelectionController: Localizer {
    func localizeStrings() {
        searchTextField.placeholder = "Search for Subjects"
        submitButton.setTitle("Update Subjects", for: .normal)
    }
}

// MARK: - Binds  -
extension SubjectSelectionController: RxBinder {
    func bind() {
        viewModel.presentedSubjects
            .asObservable()
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        viewModel.presentedSubjects
            .asObservable()
            .filter { $0.count > 0 }
            .subscribe(
                onNext: { [weak self] subjectModel in
                    guard let `self` = self else { fatalError("self deallocated before it was accessed") }
                    guard subjectModel.first?.model == "☆" else { return }
                    Array(0..<self.dataSource.sectionModels[0].items.count).forEach {
                        let indexPath = IndexPath(row: $0, section: 0)
                        self.tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
                        self.tableView.cellForRow(at: indexPath)?.isSelected = true
                    }
                }
            )
            .disposed(by: disposeBag)
        tableView.rx.itemSelected
            .do(
                onNext: { [weak self] indexPath in
                    guard let `self` = self else { fatalError("self deallocated befor it was accessed") }
                    guard let cell = self.tableView.cellForRow(at: indexPath) else { return }
                    let selected = cell.isSelected
                    cell.isSelected = selected
                    self.searchTextField.resignFirstResponder()
                }
            )
            .map { self.dataSource.sectionModels[$0.section].items[$0.row] }
            .bind(to: viewModel.selectedSubject)
            .disposed(by: disposeBag)
        tableView.rx.itemDeselected
            .do(
                onNext: { [weak self] indexPath in
                    guard let `self` = self else { fatalError("self deallocated befor it was accessed") }
                    guard let cell = self.tableView.cellForRow(at: indexPath) else { return }
                    let selected = cell.isSelected
                    cell.isSelected = selected
                    self.searchTextField.resignFirstResponder()
                }
            )
            .map { self.dataSource.sectionModels[$0.section].items[$0.row] }
            .bind(to: viewModel.selectedSubject)
            .disposed(by: disposeBag)
        searchTextField.rx.text
            .filterNil()
            .bind(to: viewModel.query)
            .disposed(by: disposeBag)
        clearTextButton.rx.tap
            .map { _ in return "" }
            .do(
                onNext: { [weak self] empty in
                    self?.searchTextField.text = empty
                }
            )
            .bind(to: viewModel.query)
            .disposed(by: disposeBag)
        viewModel.enableUpdate
            .asObservable()
            .subscribe(
                onNext: { [weak self] enableUpdate in
                    self?.animateClearSubject(shouldShow: enableUpdate)
                }
            )
            .disposed(by: disposeBag)
        submitButton.rx.tap
            .subscribe(
                onNext: { [weak self] in
                    self?.viewModel.updateSubjects()
                }
            )
            .disposed(by: disposeBag)
        //Load Status handling
        viewModel.updateLoadStatus
            .asObservable()
            .onSuccess { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }
            .disposed(by: disposeBag)
        viewModel.updateLoadStatus
            .asObservable()
            .onError(
                execute: { [weak self] error in
                    self?.showError(KratosError.cast(from: error))
                }
            )
            .disposed(by: disposeBag)
        viewModel.loadStatus
            .asObservable()
            .onError(
                execute: { [weak self] error in
                    self?.showError(KratosError.cast(from: error))
                }
            )
            .disposed(by: disposeBag)
        viewModel.loadStatus
            .asObservable()
            .bind(to: curtain.loadStatus)
            .disposed(by: disposeBag)
        viewModel.updateLoadStatus
            .asObservable()
            .bind(to: curtain.loadStatus)
            .disposed(by: disposeBag)
    }
}

// MARK: - UITextFieldDelegate -
extension SubjectSelectionController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
