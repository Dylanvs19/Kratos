//
//  TabBarController.swift
//  Kratos
//
//  Created by Dylan Straughan on 3/19/17.
//  Copyright © 2017 Kratos, Inc. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class TabBarController: UITabBarController {
    
    enum Tab: Int {
        case explore = 0
        case main = 1
        case user = 2
        
        static let allValues: [Tab] = [.explore, .main, .user]
        
        var image: UIImage {
            switch self {
            case .explore:
                return #imageLiteral(resourceName: "congressTabIcon").withRenderingMode(.alwaysOriginal)
            case .main:
                return #imageLiteral(resourceName: "kratosDeselectedIcon").withRenderingMode(.alwaysOriginal)
            case .user:
                return #imageLiteral(resourceName: "scrollIcon").withRenderingMode(.alwaysOriginal)
            }
        }
        
        var selectedImage: UIImage {
            switch self {
            case .explore:
                return #imageLiteral(resourceName: "congressSelectedTabIcon").withRenderingMode(.alwaysOriginal)
            case .main:
                return #imageLiteral(resourceName: "kratosSelectedIcon").withRenderingMode(.alwaysOriginal)
            case .user:
                return #imageLiteral(resourceName: "scrollSelectedIcon").withRenderingMode(.alwaysOriginal)
            }
        }
        
        var tabBarItem: UITabBarItem {
            let item = UITabBarItem(title: "", image: image, selectedImage: selectedImage)
            item.tag = self.rawValue
            return item
        }
        
        var viewController: UIViewController {
            switch self {
            case .explore:
                let vc = ExploreController(client: Client.provider())
                vc.title = localize(.exploreTitle)
                vc.tabBarItem = tabBarItem
                vc.tabBarItem.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0)
                return vc
            case .main:
                let vc = UserRepsViewController(client: Client.provider())
                vc.tabBarItem = tabBarItem
                vc.tabBarItem.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0)
                return vc
            case .user:
                let vc = UserController(client: Client.provider())
                vc.title = localize(.userTitle)
                vc.tabBarItem = tabBarItem
                vc.tabBarItem.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0)
                return vc
            }
        }
    }
    
    let client: AuthService
    let disposeBag = DisposeBag()
    let scrollDelegate = ScrollingTabBarControllerDelegate()
    
    init(with client: AuthService) {
        self.client = client
        super.init(nibName: nil, bundle: nil)
        configureTabs()
        bind()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = scrollDelegate
        styleViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.selectedIndex = 1
    }
    
    func configureTabs() {
        let vcArray = Tab.allValues.map { $0.viewController.embedInNavVC() }
        setViewControllers(vcArray, animated: true)
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        guard let imageView = tabBar.subviews[item.tag + 1].subviews.first as? UIImageView else { return }
        

        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 0,
                       options: .curveEaseIn,
                       animations: { () -> Void in
                        imageView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
                        imageView.layoutIfNeeded()
                        self.tabBar.layoutIfNeeded()
        },
                       completion: nil)
        
        UIView.animate(withDuration: 0.5,
                       delay: 0.05, 
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 0,
                       options: .curveEaseOut,
                       animations: { () -> Void in
                        imageView.transform = CGAffineTransform.identity
                        imageView.layoutIfNeeded()
                        self.tabBar.layoutIfNeeded()
        },
                       completion: nil)
    }
}

extension TabBarController: ViewBuilder {
    func styleViews() {
        UITabBar.appearance().shadowImage = UIImage()
        UITabBar.appearance().backgroundImage = UIImage.from(color: .white)
    }
    
    func addSubviews() {}
}

extension TabBarController: RxBinder {
    func bind() {
        client.isLoggedIn
            .filter { $0 == false }
            .subscribe(onNext: { _ in
                let navVC = UINavigationController(rootViewController: WelcomeController())
                ApplicationLauncher.rootTransition(to: navVC)
            })
            .disposed(by: disposeBag)
    }
}
