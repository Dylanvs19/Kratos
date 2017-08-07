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


extension ObservableType {
    func withPrevious() -> Observable<(E, E)> {
        return Observable.zip(self, self.skip(1))
            .map { ($0.0, $0.1) }
    }
}

protocol Loadable {
    var isLoading: Bool { get }
    var isDone: Bool { get }
    var error: Error? { get }
}

extension LoadStatus: Loadable {
    var isLoading: Bool {
        return self == .loading
    }
    
    var isDone: Bool {
        return self == .none
    }
    
    var error: Error? {
        if case let .error(error) = self {
            return error
        }
        return nil
    }
}

extension ObservableType where E: Loadable {
    
    func onSuccess(execute: @escaping () -> Void) -> Disposable {
        return withPrevious()
            .filter { $0.isLoading && $1.isDone }
            .subscribe(onNext: { (_, _) in execute() })
    }

    func onError(execute: @escaping (Error) -> Void) -> Disposable {
        return self.map { $0.error }
            .filterNil()
            .subscribe(onNext: { execute($0) })
    }
}
