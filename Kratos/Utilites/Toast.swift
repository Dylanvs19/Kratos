//
//  Toast.swift
//  Kratos
//
//  Created by Dylan Straughan on 3/30/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import Foundation
import UIKit

protocol Toaster {
    func present(error: NetworkError)
    func present(definition: Definition)
    func expand()
    func didSelect()
    func dismiss()
}

extension Toaster where Self: UIViewController {
    func present(error: NetworkError) {
        guard error.type == .surfaceable else { return }
    }
}

class Toast: UIView {
    
    enum ToastType {
        case error
        case definition
    }
    var type: ToastType = .error
    
}
