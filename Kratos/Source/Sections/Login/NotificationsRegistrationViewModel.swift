//
//  NotificationsRegistrationViewModel.swift
//  Kratos
//
//  Created by Dylan Straughan on 5/24/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import Foundation
import RxSwift

class NotificationsRegistrationViewModel {

    let client: Client
    
    init(client: Client) {
        self.client = client
        self.bind()
        
    }
    
    func bind() {
        
    }
}
