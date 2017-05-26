//
//  ConfirmationViewController.swift
//  Kratos
//
//  Created by Dylan Straughan on 3/25/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import UIKit

class ConfirmationViewController: UIViewController {
    
    let client: Client
    let viewModel: ConfirmationViewModel
    
    init(client: Client) {
        self.client = client
        self.viewModel = ConfirmationViewModel(client: client)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
}
