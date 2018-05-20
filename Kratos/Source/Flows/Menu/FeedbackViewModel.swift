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
    let fetchLoadStatus = Variable<LoadStatus>(.none)
    let postLoadStatus = Variable<LoadStatus>(.none)
    
    let questions = Variable<[String]>([])
    let answers = ReplaySubject<[String: String]>.create(bufferSize: 1)
    
    // MARK: - Initializer -
    init(client: FeedbackService) {
        self.client = client
        bind()
    }
    
    // MARK: - Client Requests -
    func fetchFeedback() {
        fetchLoadStatus.value = .loading
        client.fetchFeedback()
            .subscribe(
                onNext: { [weak self] questions in
                    self?.fetchLoadStatus.value = .none
                    self?.questions.value = questions
                }, onError: { [weak self] error in
                    self?.fetchLoadStatus.value = .error(KratosError.cast(from: error))
                }
            )
            .disposed(by: disposeBag)
    }
    
    func postFeedBack(for answers: [String: String]) {
        postLoadStatus.value = .loading
        client.postFeedback(questions: answers)
            .subscribe(
                onNext: { [weak self] questions in
                    self?.postLoadStatus.value = .none
                }, onError: { [weak self] error in
                    self?.postLoadStatus.value = .error(KratosError.cast(from: error))
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
