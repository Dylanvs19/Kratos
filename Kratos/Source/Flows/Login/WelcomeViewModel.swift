//
//  WelcomeViewModel.swift
//  Kratos
//
//  Created by Dylan Straughan on 4/17/18.
//  Copyright © 2018 Dylan Straughan. All rights reserved.
//

import Foundation
import RxSwift

struct WelcomeViewModel {
    // MARK: - `properties` -
    let client: Client
    
    // MARK: - `initialization` -
    init(with client: Client) {
        self.client = client
    }
}

// MARK: - `RxBinder` -
extension WelcomeViewModel: RxBinder {
    func bind() {
        
    }
}
