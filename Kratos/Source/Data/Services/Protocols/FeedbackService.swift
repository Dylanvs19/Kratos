//
//  FeedbackService.swift
//  Kratos
//
//  Created by Dylan Straughan on 5/6/17.
//  Copyright © 2017 Kratos, Inc. All rights reserved.
//

import Foundation
import RxSwift

protocol FeedbackService: Provider  {
    func fetchFeedback() -> Observable<[String]>
    func postFeedback(questions: [String: String]) -> Observable<Void>
}
