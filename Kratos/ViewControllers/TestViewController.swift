//
//  TestViewController.swift
//  Kratos
//
//  Created by Dylan Straughan on 12/1/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import UIKit

class TestViewController: UIViewController {

    @IBOutlet weak var textField: KratosTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textField.configureWith(validationFunction: validate, text: nil, textlabelText: "A D D R E S S")
    }
    
    func validate(with string: String) -> Bool {
        return string.isEmpty ? false : true
    }
    
}
