//
//  AnalyticsService.swift
//  Kratos
//
//  Created by Dylan Straughan on 5/6/17.
//  Copyright © 2017 Kratos, Inc. All rights reserved.
//

import Foundation
import RxSwift

protocol AnalyticsService: Provider  {
    func logContact(contact: RepContactView.Contact, personId: Int)
    func logView(type: KratosAnalytics)
}
