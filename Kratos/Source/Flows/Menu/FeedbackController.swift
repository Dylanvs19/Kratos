//
//  FeedbackController.swift
//  Kratos
//
//  Created by Dylan Straughan on 9/28/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class FeedbackController: UIViewController {
    
    let client: Client
    let scrollview = UIScrollView()
    let contentView = UIView()
    
    init(client: Client) {
        self.client = client
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
}

extension FeedbackController: ViewBuilder {
    func addSubviews() {
        
    }
    func constrainViews() {
        
    }
    func styleViews() {
        
    }
}

extension FeedbackController: RxBinder {
    func bind() {
        
    }
}
