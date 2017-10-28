//
//  Client+AnalyticsService.swift
//  Kratos
//
//  Created by Dylan Straughan on 5/7/17.
//  Copyright © 2017 Kratos, Inc. All rights reserved.
//

import Foundation
import RxSwift

extension Client: AnalyticsService {
    func logContact(contact: RepContactView.Contact, personId: Int) {
        request(.logContact(type: contact, personId: personId))
            .subscribe(
                onNext: { _ in
                    //print("contact event success")
                }
            )
            .disposed(by: disposeBag)
    }
    
    func logView(type: KratosAnalytics) {
        request(.logView(type: type))
            .subscribe(
                onNext: { _ in
                    //print("contact event success")
                }
            )
            .disposed(by: disposeBag)
    }
}
