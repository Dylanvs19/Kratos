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
    func fetchFeedback() -> Observable<[String]>
    func postFeedback(questions: [String: String]) -> Observable<Void>
}
