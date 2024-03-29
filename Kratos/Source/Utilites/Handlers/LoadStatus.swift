//
//  LoadingState.swift
//  Kratos
//
//  Created by Dylan Straughan on 5/7/17.
//  Copyright © 2017 Kratos, Inc. All rights reserved.
//

import Foundation

enum LoadStatus {
    case loading
    case error(Error)
    case none
}

func == (lhs: LoadStatus, rhs: LoadStatus) -> Bool {
    switch (lhs, rhs) {
    case (.loading, .loading), (.none, .none), (.error(_), .error(_)):
        return true
    default:
        return false
    }
}

func != (lhs: LoadStatus, rhs: LoadStatus) -> Bool {
    return !(lhs == rhs)
}
