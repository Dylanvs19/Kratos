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
    fileprivate let disposeBag = DisposeBag()
    
    
    // MARK: - Initializer -
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(with district: District) {
        self.textLabel?.text = "District \(district.district)"
    }
}
