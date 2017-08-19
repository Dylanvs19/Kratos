//
//  SearchController.swift
//  Kratos
//
//  Created by Dylan Straughan on 8/16/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import Foundation
import UIKit
import RxCocoa
import RxSwift
import RxDataSources
import SnapKit

protocol SearchPresentable { }

class SearchController: UIViewController {
    
    // MARK: - Variables -
    // Standard
    let client: Client
    let viewModel: SearchViewModel
    let disposeBag = DisposeBag()
    
    // UIElements
    let searchView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    let searchField = KratosTextField()
    let searchTableView = UITableView()
    let searchDataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, SearchPresentable>>()
    
    // MARK: - Initializers -
    init(client: Client) {
        self.client = client
        self.viewModel = SearchViewModel(client: client)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    func configure() {
        view.alpha = 0.1
        view.addSubview(searchView)
        searchView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func configureSearchTableView() {
        
    }
    
}
