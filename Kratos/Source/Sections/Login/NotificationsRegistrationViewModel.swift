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
    
    let title = Variable<String>("Notifications")
    let confirmationButtonTitle = Variable<String>("Register for Notifications")
    let skipButtonTitle = Variable<String>("Skip")
    let text = Variable<String>("We use notifications to inform you when you are being represented by your congress-people. We do not spam you with news about every breath they take, we focus on the important stuff.")

    init(client: Client) {
        self.client = client
    }
}
