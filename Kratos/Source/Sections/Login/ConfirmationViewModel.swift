//
//  ConfirmationViewModel.swift
//  Kratos
//
//  Created by Dylan Straughan on 5/24/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import Foundation
import RxSwift

class ConfirmationViewModel {
    
    let client: Client
    let disposeBag = DisposeBag()
    
    let title = Variable<String>("Confirmation")
    let buttonTitle = Variable<String>("Link Pressed")
    let text = Variable<String>("We have just sent an email to your email address you provided to us with a magic link. Once you have activated the link you will be signed in. If you are not automatically signed in after activating the link in the email, press the button below.")
    
    init(client: Client) {
        self.client = client
    }
}
