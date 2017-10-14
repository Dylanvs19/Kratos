//
//  FeedbackViewModel.swift
//  Kratos
//
//  Created by Dylan Straughan on 10/13/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import Foundation
import RxSwift

class FeedbackViewModel {
    // MARK: - Variables -
    let client: Client
    let disposeBag = DisposeBag()
    let loadStatus = Variable<LoadStatus>(.none)
    
    let questions = Variable<[String]>([])
    let answers = Variable<[String: String]>([String:String]())
    
    // MARK: - Initializer -
    init(client: Client) {
        self.client = client
        bind()
    }
    
    // MARK: - Client Requests -
    func fetchFeedback() {
        loadStatus.value = .loading
        client.fetchFeedback()
            .subscribe(
                onNext: { [weak self] questions in
                    self?.loadStatus.value = .none
                    self?.questions.value = questions
                }, onError: { [weak self] error in
                    self?.loadStatus.value = .error(KratosError.cast(from: error))
                }
            )
            .disposed(by: disposeBag)
    }
    
    func postFeedBack() {
        guard !answers.value.isEmpty else { return }
        loadStatus.value = .loading
        client.postFeedback(questions: answers.value)
            .subscribe(
                onNext: { [weak self] questions in
                    self?.loadStatus.value = .none
                }, onError: { [weak self] error in
                    self?.loadStatus.value = .error(KratosError.cast(from: error))
                }
            )
            .disposed(by: disposeBag)
    }
    
    func extract(answers: [String: String]) {
        self.answers.value = answers
    }
}

// MARK: - Binds -
extension FeedbackViewModel {
    func bind() {
        
    }
}
