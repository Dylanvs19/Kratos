//
//  FeedbackService.swift
//  Kratos
//
//  Created by Dylan Straughan on 5/6/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import Foundation
import RxSwift

protocol FeedbackService {
    func fetchFeedback() -> Observable<Bool>
    func postFeedback(userID: Int, questions: [String: String]) -> Observable<Bool>
}
