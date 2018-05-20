//
//  Client+FeedbackService.swift
//  Kratos
//
//  Created by Dylan Straughan on 5/7/17.
//  Copyright © 2017 Kratos, Inc. All rights reserved.
//

import Foundation
import RxSwift

extension Client: FeedbackService {
    
    func fetchFeedback() -> Observable<[String]> {
        return request(.fetchFeedback)
            .toJson()
            .map {
                guard let json = $0 as? JSONObject,
                    let questions = json["questions"] as? [String] else { throw MappingError.unexpectedValue }
                return questions
            }
    }
    
    func postFeedback(questions: [String : String]) -> Observable<Void> {
        guard let id = _user.value?.id else { return Observable.error(AuthenticationError.notLoggedIn) }
        return request(.postFeedback(userID: id, questions: questions))
            .map { _ in return () }
    }
}
