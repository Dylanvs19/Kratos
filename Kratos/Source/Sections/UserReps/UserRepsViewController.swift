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
    
    let client: Client
    let viewModel: UserRepsViewModel
    let disposeBag = DisposeBag()
    let loadStatus = Variable<LoadStatus>(.none)
    
    //TopImage
    let kratosImageView = UIImageView(image: #imageLiteral(resourceName: "Kratos"))
    let topImage = UIImageView()
    let topShadeView = UIView()
    let stateImageView = UIImageView()
    let stateLabel = UILabel()
    let districtLabel = UILabel()
    
    let tableView = UITableView()
    let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, Person>>()
    
    init(client: Client) {
        self.client = client
        self.viewModel = UserRepsViewModel(client: client)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        edgesForExtendedLayout = [.top, .right, .left]
        addSubviews()
        constrainViews()
        style()
        bind()
        configureTableView()
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
    
    func cellSelected(with indexPath: IndexPath) {
        //guard let cell = self.tableView.cellForRow(at: indexPath) as? UserRepTableViewCell else { return }
        //let cellRect = cell.convert(cell.frame, to: self.view)
    }
    
    func presentRepInfoView(with client: Client, person: Person, frame: CGRect, imageRect: CGRect) {}
}

extension UserRepsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 5))
    }
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        print("hi")
//    }
}

extension UserRepsViewController: ViewBuilder {
    func addSubviews() {        
        view.addSubview(stateImageView)
        stateImageView.addSubview(kratosImageView)
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
        kratosImageView.snp.makeConstraints { make in
            make.width.equalTo(50)
            make.height.equalTo(kratosImageView.snp.width)
            make.top.equalToSuperview().offset(10)
            make.centerX.equalToSuperview()
        }
        topShadeView.snp.makeConstraints { make in
            make.leading.bottom.trailing.equalToSuperview()
            make.height.equalTo(50)
        }
        stateLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(5)
        }
        districtLabel.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.leading.equalTo(stateLabel.snp.leading).offset(10)
        }
        tableView.snp.makeConstraints { make in
            make.top.equalTo(stateImageView.snp.bottom).offset(5)
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.bottom.equalToSuperview().offset(-5)
        }
    }
    
    func style() {
        view.backgroundColor = .kratosLightGray
        stateImageView.contentMode = .scaleToFill
        
        topShadeView.backgroundColor = .black
        topShadeView.alpha = 0.5
        
        stateLabel.font = Font.futura(size: 17).font
        stateLabel.textColor = .white
        
        districtLabel.font = Font.futura(size: 15).font
        districtLabel.textColor = .white
    }
}

extension UserRepsViewController: RxBinder {
    func bind() {
        
        //Assumption of having 3 representatives.
        viewModel.representatives.asObservable()
            .map { $0.map {SectionModel(model: "", items: [$0]) } }
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        tableView.rx.itemSelected
            .map { self.dataSource[$0] }
            .subscribe(onNext: { [weak self] model in
                guard let client = self?.client else { return }
                self?.navigationController?.pushViewController(RepresentativeViewController(client: client, representative: model), animated: true)
            })
            .disposed(by: disposeBag)
        
        viewModel.stateImage.asObservable()
            .bind(to: stateImageView.rx.image)
            .disposed(by: disposeBag)
        
        viewModel.state.asObservable()
            .map { Constants.abbreviationToFullStateNameDict[$0] }
            .filterNil()
            .bind(to: stateLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.district.asObservable()
            .filterNil()
            .map { String($0) }
            .bind(to: districtLabel.rx.text)
            .disposed(by: disposeBag)
        
        //Bind loadStatus to loadStatus
    }
}

struct UserRepSection {
    var header: String
    var items: [Person]
}

extension UserRepSection: SectionModelType {
    typealias Item = Person
    
    init(original: UserRepSection, items: [Item]) {
        self = original
        self.items = items
    } 
}
