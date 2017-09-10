//
//  TrackButton.swift
//  Kratos
//
//  Created by Dylan Straughan on 4/18/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class TrackButton: UIButton {  //CurtainPresenter {
    // MARK: - Enum -
    enum State {
        case tracked
        case untracked
        
        var backgroundColor: Color {
            switch self {
            case .tracked:
                return Color.gray
            case .untracked:
                return Color.kratosGreen
            }
        }
        
        var title: String {
            switch self {
            case .tracked:
                return "Untrack"
            case .untracked:
                return "Track"
            }
        }
    }
    
    // MARK: - Variables -
    var disposeBag = DisposeBag()
    var viewModel: TrackButtonViewModel?
    
    // MARK: - Initializer -
    convenience init(with client: Client, billId: Int) {
        self.init(frame: .zero)
        self.viewModel = TrackButtonViewModel(with: client, billId: billId)
        customization()
        bind()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    // MARK: - Configuration -
    fileprivate func update(with state: State) {
        UIView.animate(withDuration: 0.5) { 
            self.style(with: [.backgroundColor(state.backgroundColor),
                         .titleColor(.white),
                         .font(.cellTitle),
                         .cornerRadius(5)])
            self.setTitle(state.title, for: .normal)
            self.superview?.layoutIfNeeded()
        }
    }
    
    // MARK: - Customization -
    private func customization() {
        contentEdgeInsets = UIEdgeInsetsMake(5, 10, 5, 10)
        setTitle("L", for: .highlighted)
    }
}

// MARK: - Binds -
extension TrackButton: RxBinder {
    func bind() {
        guard let viewModel = viewModel else { return }
        viewModel.state.asObservable()
            .subscribe(onNext: { [weak self] state in
                self?.update(with: state)
            })
            .disposed(by: disposeBag)
        
        rx.controlEvent(.touchUpInside)
            .asObservable()
            .bind(to: viewModel.buttonPressed)
            .disposed(by: disposeBag)
    }
}


