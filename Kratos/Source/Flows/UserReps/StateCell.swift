//
//  StateCell.swift
//  Kratos
//
//  Created by Dylan Straughan on 10/14/17.
//  Copyright © 2017 Kratos, Inc. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import SnapKit

class StateCell: UITableViewCell {
    // MARK: - Variables -
    static let identifier = String(describing: StateCell.self)
    
    let selectedStateDistrict = PublishSubject<StateDistrictModel>()
    
    fileprivate let stateImageView = UIImageView()
    fileprivate let stateTitle = UILabel()
    fileprivate let tableView = UITableView()
    
    fileprivate let state = Variable<State?>(nil)
    fileprivate let districts = Variable<[Int]>([])
    fileprivate let disposeBag = DisposeBag()
    
    
    // MARK: - Initializer -
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubviews()
        constrainViews()
        styleViews()
        bind()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(with model: StateDistrictModel) {
        self.state.value = model.state
        self.districts.value = model.districts
    }
    
    override func prepareForReuse() {
        stateImageView.image = nil
        stateTitle.text = nil
    }
    
    func update(for isSelected: Bool) {
        if isSelected {
            UIView.animate(withDuration: 0.3, animations: {
                self.stateTitle.snp.makeConstraints { make in
                    make.leading.trailing.equalToSuperview().inset(10)
                    make.top.equalTo(self.stateImageView.snp.bottom)
                }
                self.tableView.isHidden = false
                self.tableView.snp.makeConstraints { make in
                    make.leading.trailing.equalToSuperview().inset(10)
                    make.top.equalTo(self.stateTitle.snp.bottom)
                    make.bottom.equalToSuperview()
                }
                self.layoutIfNeeded()
            })
        } else {
            UIView.animate(withDuration: 0.3, animations: {
                self.stateTitle.snp.makeConstraints { make in
                    make.leading.trailing.equalToSuperview().inset(10)
                    make.top.equalTo(self.stateImageView.snp.bottom)
                    make.bottom.equalToSuperview()
                }
                self.tableView.isHidden = true
                self.layoutIfNeeded()
            })
        }
    }
}

extension StateCell: ViewBuilder {
    func addSubviews() {
        contentView.addSubview(stateImageView)
        contentView.addSubview(stateTitle)
        contentView.addSubview(tableView)
    }
    func constrainViews() {
        stateImageView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview().inset(10)
        }
        stateTitle.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(10)
            make.top.equalTo(stateImageView.snp.bottom)
            make.bottom.equalToSuperview()
        }
        tableView.isHidden = true
    }
    func styleViews() {
        
    }
}
extension StateCell: RxBinder {
    func bind() {
        districts
            .asObservable()
            .map { $0.map { $0 != 0 ? $0.ordinal + " District" : "At Large" }}
            .bind(to: tableView.rx.items(cellIdentifier: String(describing: UITableViewCell.self), cellType: UITableViewCell.self)) { tv, model, cell in
                cell.textLabel?.text = model
            }
            .disposed(by: disposeBag)
        tableView.rx.modelSelected(String.self)
            .map { $0 == "At Large" ? 0 : $0.}
    }
}
