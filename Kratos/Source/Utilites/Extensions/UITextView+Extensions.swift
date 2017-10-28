//
//  UITextView+Extensions.swift
//  Kratos
//
//  Created by Dylan Straughan on 8/5/17.
//  Copyright © 2017 Kratos, Inc. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

extension Reactive where Base: UITextView {
    var totalSize: Observable<CGSize> {
        return didChange
            .map {
            return self.base.sizeThatFits(CGSize(width: self.base.frame.size.width, height: .greatestFiniteMagnitude))
        }
    }
}
