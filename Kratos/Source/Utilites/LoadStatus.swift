//
//  LoadingState.swift
//  Kratos
//
//  Created by Dylan Straughan on 5/7/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import Foundation

enum LoadStatus {
    case none
    case empty
    case actionableEmpty(prompt: String, action: () -> Void)
    case loading
    case error(error: KratosError)
}

func == (lhs: LoadStatus, rhs: LoadStatus) -> Bool {
    switch (lhs, rhs) {
    case (.loading, .loading), (.none, .none), (.empty, .empty), (.error(_), .error(_)), (.actionableEmpty(_, _), .actionableEmpty(_, _)):
        return true
    default:
        return false
    }
}

func != (lhs: LoadStatus, rhs: LoadStatus) -> Bool {
    switch (lhs, rhs) {
    case (.loading, .loading), (.none, .none), (.empty, .empty), (.error(_), .error(_)), (.actionableEmpty(_, _), .actionableEmpty(_, _)):
        return false
    default:
        return true
    }
}
