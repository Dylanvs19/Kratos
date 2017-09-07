//
//  TallyController.swift
//  Kratos
//
//  Created by Dylan Straughan on 9/5/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import SnapKit

class TallyController: UIViewController {
    
    // Standard
    let client: Client
    let viewModel: TallyViewModel
    let disposeBag = DisposeBag()

    let headerView = UIView()
    let topView = UIView()
    
    let pieChartView = PieChartView()
    let titleLabel = UILabel()
    let statusLabel = UILabel()
    let statusDateLabel = UILabel()
    
    init(client: Client, tally: LightTally) {
        self.client = client
        self.viewModel = TallyViewModel(client: client, lightTally: tally)
        super.init(nibName: nil, bundle: nil)
    }
    
    init(client: Client, tally: Tally) {
        self.client = client
        self.viewModel = TallyViewModel(client: client, tally: tally)
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        edgesForExtendedLayout = [.top, .right, .left, .bottom]
        addSubviews()
        constrainViews()
        styleViews()
        bind()
    }
}

// MARK: - View Builder -
extension TallyController: ViewBuilder {
    func addSubviews() {
        view.addSubview(topView)
    }
    
    func constrainViews() {
        headerView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(44)
        }
        topView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(10)
            make.height.equalTo(100)
        }
    }
    
    func styleViews() {
        view.style(with: .backgroundColor(.slate))
        headerView.style(with: .backgroundColor(.white))
        titleLabel.style(with: [.font(.cellTitle),
                                .numberOfLines(5)])
        statusLabel.style(with: [.font(.body),
                                 .titleColor(.gray)])
        statusDateLabel.style(with: [.font(.body),
                                     .titleColor(.gray)])

    }
}

// MARK: - Binds  -
extension TallyController: RxBinder {
    func bind() {
        viewModel.pieChartData.asObservable()
            .filterNil()
            .filter { !$0.isEmpty }
            .bind(to: pieChartView.rx.data)
            .disposed(by: disposeBag)
        viewModel.name.asObservable()
            .bind(to: titleLabel.rx.text)
            .disposed(by: disposeBag)
        viewModel.status.asObservable()
            .bind(to: statusLabel.rx.text)
            .disposed(by: disposeBag)
        viewModel.statusDate.asObservable()
            .bind(to: statusDateLabel.rx.text)
            .disposed(by: disposeBag)
    }
}
