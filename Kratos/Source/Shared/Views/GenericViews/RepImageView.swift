//
//  RepImageView.swift
//  Kratos
//
//  Created by Dylan Straughan on 1/13/17.
//  Copyright © 2017 Kratos, Inc. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class RepImageView: UIImageView {
    
    var loadStatus = Variable<LoadStatus>(.none)
    var disposeBag = DisposeBag()
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.clipsToBounds = true
        self.contentMode = .scaleAspectFill
        self.addRepImageViewBorder()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addRepImageViewBorder() {
        layer.borderColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.2).cgColor
        layer.borderWidth = 2.0
        layer.cornerRadius = 2.0
    }
}


