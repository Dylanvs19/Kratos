//
//  StateService.swift
//  Kratos
//
//  Created by Dylan Straughan on 5/6/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import Foundation
import RxSwift

protocol StateService {
    func getStateDistricts(state: String) -> Observable<[Int]>
    func getStateImage(state: String) -> Observable<String>
}
