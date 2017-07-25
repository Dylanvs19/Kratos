//
//  BillViewController.swift
//  Kratos
//
//  Created by Dylan Straughan on 7/12/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class BillViewController: UIViewController {
    
    // MARK: - Properties - 
    
    // Standard
    let client: Client
    let viewModel: BillViewModel
    let disposeBag = DisposeBag()
    let loadStatus = Variable<LoadStatus>(.none)

    // UIElements
    let scrollView = UIScrollView()
    let stackView = UIStackView()
    
    // MARK: - Initialization -
    init(client: Client, billID: Int) {
        self.client = client
        self.viewModel = BillViewModel(client: client, billID: billID)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - View Builder -
extension BillViewController: ViewBuilder {
    func addSubviews() {
        
    }
    func constrainViews() {
        
    }
    func style() {
        
    }
}

// MARK: - Binds -
extension BillViewController: RxBinder {
    func bind() {
        
    }
}
