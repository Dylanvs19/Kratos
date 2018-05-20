//
//  FeedbackViewModel.swift
//  Kratos
//
//  Created by Dylan Straughan on 10/13/17.
//  Copyright © 2017 Kratos, Inc. All rights reserved.
//

import Foundation
import RxSwift

class FeedbackViewModel {
    // MARK: - Variables -
    let client: FeedbackService
    let disposeBag = DisposeBag()
    let fetchLoadStatus = BehaviorSubject<LoadStatus>(value: .none)
    let postLoadStatus = BehaviorSubject<LoadStatus>(value: .none)
    
    let questions = Variable<[String]>([])
    let answers = ReplaySubject<[String: String]>.create(bufferSize: 1)
    
    // MARK: - Initializer -
    init(client: FeedbackService) {
        self.client = client
        bind()
    }
    
    // MARK: - Client Requests -
    func fetchFeedback() {
        fetchLoadStatus.onNext(.loading)
        client.fetchFeedback()
            .subscribe(
                onNext: { [unowned self] questions in
                    self.fetchLoadStatus.onNext(.none)
                    self.questions.value = questions
                }, onError: { [unowned self] error in
                    self.fetchLoadStatus.onNext(.error(KratosError.cast(from: error)))
                }
            )
            .disposed(by: disposeBag)
    }
    
    func postFeedBack(for answers: [String: String]) {
        postLoadStatus.onNext(.loading)
        client.postFeedback(questions: answers)
            .subscribe(
                onNext: { [unowned self] questions in
                    self.postLoadStatus.onNext(.none)
                }, onError: { [unowned self] error in
                    self.postLoadStatus.onNext(.error(KratosError.cast(from: error)))
                }
            )
            .disposed(by: disposeBag)
    }
}

// MARK: - Binds -
extension FeedbackViewModel {
    func bind() {
        answers
            .subscribe(onNext: { [unowned self] in  self.postFeedBack(for: $0)})
            .disposed(by: disposeBag)
    }
}
