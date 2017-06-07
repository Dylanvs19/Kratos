//
//  YourRepsViewController.swift
//  Kratos
//
//  Created by Dylan Straughan on 5/31/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa


class UserRepsViewController: UIViewController {
    
    let client: Client
    let viewModel: UserRepsViewModel
    let disposeBag = DisposeBag()
    let loadStatus = Variable<LoadStatus>(.none)
    
    //TopImage
    let kratosImageView = UIImageView(image: #imageLiteral(resourceName: "Kratos"))
    let topImage = UIImageView()
    let shadeView = UIView()
    let stateView = UIImageView()
    let stateLabel = UILabel()
    let districtLabel = UILabel()
    
    //RepViews
    var firstRepView: UserRepView?
    var secondRepView: UserRepView?
    var thirdRepView: UserRepView?
    
    
    init(client: Client) {
        self.client = client
        self.viewModel = UserRepsViewModel(client: client)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buildViews()
        style()
        bind()
    }
    
    //Animation for RepSelected
    //
    
}

extension UserRepsViewController: ViewBuilder {
    func buildViews() {
        
    }
    
    func buildTopView() {
        
    }
    
    func buidRepViews() {
        firstRepView = UserRepView()
        guard let firstRepView = firstRepView else { return }

    }
    
    func style() {
        
    }
}

extension UserRepsViewController: RxBinder {
    func bind() {
        
        //Assumption of having 3 representatives.
        viewModel.representatives.asObservable()
            .asDriver(onErrorJustReturn: [])
            .drive(onNext: { [weak self] (reps) in
                guard let s = self else { fatalError("self deallocated before it was accessed") }
                switch reps.count {
                case 1:
                    s.firstRepView?.configure(with: s.client, representative: reps[0])
                    s.secondRepView = nil
                    s.thirdRepView = nil
                case 2:
                    s.firstRepView?.configure(with: s.client, representative: reps[0])
                    s.secondRepView?.configure(with: s.client, representative: reps[1])
                    s.thirdRepView = nil
                case 3:
                    s.firstRepView?.configure(with: s.client, representative: reps[0])
                    s.secondRepView?.configure(with: s.client, representative: reps[0])
                    s.thirdRepView?.configure(with: s.client, representative: reps[0])
                default:
                    break
                }
            })
            .disposed(by: disposeBag)
        
        
        
        //Bind Representatives to repViews
        //Bind loadStatus to loadStatus
        //Bind repView didSelectRep to selectedRep
    }
}
