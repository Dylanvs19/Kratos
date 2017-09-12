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
    
    
    // MARK: - Enums -
    enum State: Int {
        case votes = 0
        case details = 1
        
        static let allValues: [State] = [.votes, .details]
        
        var title: String {
            switch self {
            case .votes:
                return localize(.tallyVotesTitle)
            case .details:
                return localize(.tallyDetailsTitle)
            }
        }
        
        func scrollViewXPosition(in view: UIView) -> CGFloat {
            let width = view.frame.size.width
            return CGFloat(self.rawValue) * width
        }
        
        func indicatorXPosition(in view: UIView) -> CGFloat {
            let width = view.frame.size.width / CGFloat(State.allValues.count)
            return CGFloat(self.rawValue) * width
        }
        
        var button: UIButton {
            let button = UIButton()
            button.style(with: [.font(.tab),
                                .titleColor(.kratosRed),
                                .highlightedTitleColor(.red),
                                ])
            button.setTitle(title, for: .normal)
            button.tag = self.rawValue
            return button
        }
    }
    
    // MARK: - Variables -
    // Standard
    let client: Client
    let viewModel: TallyViewModel
    let disposeBag = DisposeBag()

    let topView = UIView()
    
    let pieChartView = PieChartView()
    let titleLabel = UILabel()
    let statusLabel = UILabel()
    let statusDateLabel = UILabel()
    
    // TopView
    let managerView = UIView()
    let slideView = UIView()
    let buttons: [UIButton] = State.allValues.map { $0.button }
    
    // Base
    let scrollView = UIScrollView()
    let stackView = UIStackView()
    
    let sponsorsTableView = UITableView()
    
    let detailsScrollView = UIScrollView()
    let detailsContentView = UIView()
    
    // MARK: - Initializers -
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
        
        view.addSubview(managerView)
        buttons.forEach { managerView.addSubview($0) }
        managerView.addSubview(slideView)
        
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
        
        stackView.addArrangedSubview(sponsorsTableView)
        stackView.addArrangedSubview(detailsScrollView)

        detailsScrollView.addSubview(detailsContentView)
    }
    
    func constrainViews() {
        topView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(135)
        }
        managerView.snp.remakeConstraints { make in
            make.top.equalTo(topView.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(10)
            make.height.equalTo(45)
        }
        managerView.layoutIfNeeded()
        buttons.forEach { button in
            let count = CGFloat(State.allValues.count)
            let width = managerView.frame.width/count
            button.snp.remakeConstraints { make in
                make.leading.equalTo(width * CGFloat(button.tag))
                make.top.bottom.equalToSuperview()
                make.width.equalToSuperview().dividedBy(count)
            }
        }
        slideView.snp.remakeConstraints { make in
            make.leading.bottom.equalToSuperview()
            make.width.equalToSuperview().dividedBy(3)
            make.height.equalTo(2)
        }
        scrollView.snp.remakeConstraints { make in
            make.top.equalTo(managerView.snp.bottom).offset(10)
            make.trailing.leading.equalToSuperview().inset(10)
            make.bottom.equalTo(bottomLayoutGuide.snp.top).offset(-10)
        }
    }
    
    func styleViews() {
        view.style(with: .backgroundColor(.slate))
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
        viewModel.pieChartData
            .asObservable()
            .filterNil()
            .filter { !$0.isEmpty }
            .bind(to: pieChartView.rx.data)
            .disposed(by: disposeBag)
        viewModel.name
            .asObservable()
            .bind(to: titleLabel.rx.text)
            .disposed(by: disposeBag)
        viewModel.status
            .asObservable()
            .bind(to: statusLabel.rx.text)
            .disposed(by: disposeBag)
        viewModel.statusDate
            .asObservable()
            .bind(to: statusDateLabel.rx.text)
            .disposed(by: disposeBag)
    }
}
