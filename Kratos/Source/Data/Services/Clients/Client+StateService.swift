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
    func fetchStatesAndDistricts() -> Observable<[StateDistrictModel]> {
        return request(.fetchStatesAndDistricts)
            .toJson()
            .map {
                guard let dict = $0 as? [String: [Int]] else { throw MappingError.unexpectedValue }
                var models = [StateDistrictModel]()
                for (key, value) in dict {
                    if let state = State(rawValue: key) {
                        models.append(StateDistrictModel(state: state, districts: value))
                    }
                }
                return models
            }
    }
    func fetchStateImage(state: State) -> Observable<String> {
      return request(.getStateImage(state: state.rawValue.lowercased()))
        .toJson()
        .map {
            guard let dict = $0 as? [String: String],
                  let url = dict["url"] else { throw MappingError.unexpectedValue }
            return url
        }
    }
}
