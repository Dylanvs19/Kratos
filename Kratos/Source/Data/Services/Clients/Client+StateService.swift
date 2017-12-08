//
//  Client+StateService.swift
//  Kratos
//
//  Created by Dylan Straughan on 5/7/17.
//  Copyright © 2017 Kratos, Inc. All rights reserved.
//

import Foundation
import RxSwift

extension Client: StateService {
    func fetchStateImage(state: State) -> Observable<String> {
      return request(.getStateImage(state: state.rawValue.lowercased()))
        .toJson()
        .map {
            guard let dict = $0 as? [String: String],
                  let url = dict["url"] else { throw MappingError.unexpectedValue }
            return url
        }
    }
    func fetchDistricts(from query: String) -> Observable<[District]> {
        return request(.fetchDistricts(query: query))
            .toJson()
            .mapArray()
    }
}
