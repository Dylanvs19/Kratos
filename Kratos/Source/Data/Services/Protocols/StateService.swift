//
//  StateService.swift
//  Kratos
//
//  Created by Dylan Straughan on 5/6/17.
//  Copyright © 2017 Kratos, Inc. All rights reserved.
//

import Foundation
import RxSwift

protocol StateService {
    func fetchStateImage(state: State) -> Observable<String>
    func fetchDistricts(from query: String) -> Observable<[District]>
}
