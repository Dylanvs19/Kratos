//
//  Observable+Extensions.swift
//  Kratos
//
//  Created by Dylan Straughan on 5/30/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import Foundation
import RxSwift

protocol OptionalType {
    associatedtype Boxed
    var asOptional: Boxed? { get }
}

extension Optional: OptionalType {
    var asOptional: Wrapped? { return self }
}

extension ObservableType where E: OptionalType {
    
    /// Filters out nil values from an optional Elements Observable Sequence
    /// - Note: from http://stackoverflow.com/a/36788483
    ///
    /// - Returns: returns a safely unwrapped observable sequence with `nil` values ignored
    func filterNil() -> Observable<E.Boxed> {
        return filter { $0.asOptional != nil }
            .map { $0.asOptional! }
    }
}
