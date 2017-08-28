//
//  TabBarController.swift
//  Kratos
//
//  Created by Dylan Straughan on 3/19/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class TabBarController: UITabBarController {
    
    enum Tab {
        case explore
        case main
        case user
        
        static let allValues: [Tab] = [.explore, .main, .user]
        
        var image: UIImage {
            switch self {
            case .explore:
                return #imageLiteral(resourceName: "congressTabIcon").withRenderingMode(.alwaysOriginal)
            case .main:
                return #imageLiteral(resourceName: "kratosDeselectedIcon").withRenderingMode(.alwaysOriginal)
            case .user:
                return #imageLiteral(resourceName: "userTabIcon").withRenderingMode(.alwaysOriginal)
            }
        }
        
        var selectedImage: UIImage {
            switch self {
            case .explore:
                return #imageLiteral(resourceName: "congressSelectedTabIcon").withRenderingMode(.alwaysOriginal)
            case .main:
                return #imageLiteral(resourceName: "kratosSelectedIcon").withRenderingMode(.alwaysOriginal)
            case .user:
                return #imageLiteral(resourceName: "userSelectedTabIcon").withRenderingMode(.alwaysOriginal)
            }
        }
        
        var tabBarItem: UITabBarItem {
            return UITabBarItem(title: "", image: image, selectedImage: selectedImage)
        }
        
        func viewController(with client: Client) -> UIViewController {
            switch self {
            case .explore:
                let vc = ExploreController(client: client)
                vc.title = localize(.exploreTitle)
                vc.tabBarItem = tabBarItem
                vc.tabBarItem.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0)
                return vc
            case .main:
                let vc = UserRepsViewController(client: client)
                vc.tabBarItem = tabBarItem
                vc.tabBarItem.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0)
                return vc
            case .user:
                let vc = UserController(client: client)
                vc.title = localize(.userTitle)
                vc.tabBarItem = tabBarItem
                vc.tabBarItem.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0)
                return vc
            }
        }
    }
    
    let client: Client
    let disposeBag = DisposeBag()
    let scrollDelegate = ScrollingTabBarControllerDelegate()
    
    init(with client: Client) {
        self.client = client
        super.init(nibName: nil, bundle: nil)
        configure(with: client)
        bind()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = scrollDelegate
        
    }
    
    func configure(with client: Client) {
        let vcArray = Tab.allValues.map { $0.viewController(with: client).embedInNavVC() }
        setViewControllers(vcArray, animated: true)
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        guard let items = tabBar.items else { return }
        var imageView: UIImageView?
        for (i, tabItem) in items.enumerated() where item == tabItem {
            imageView = tabBar.subviews[i + 1].subviews.first as? UIImageView
        }

        guard let tabImageView = imageView else { return }
        tabImageView.transform = CGAffineTransform.identity
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 0,
                       options: .curveEaseIn,
                       animations: { () -> Void in
            tabImageView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        },
                       completion: nil)
        
        UIView.animate(withDuration: 0.5,
                       delay: 0.05, 
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 0,
                       options: .curveEaseOut,
                       animations: { () -> Void in
            tabImageView.transform = CGAffineTransform.identity
        },
                       completion: nil)
    }
}

extension TabBarController: RxBinder {
    func bind() {
        client.isLoggedIn.asObservable()
            .filter { $0 == false }
            .subscribe(onNext: { next in
                let navVC = UINavigationController(rootViewController: LoginController(client: Client.default))
                ApplicationLauncher.rootTransition(to: navVC)
            })
            .disposed(by: disposeBag)
    }
}
