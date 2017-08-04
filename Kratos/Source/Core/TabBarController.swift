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
        case congress
        case main
        case user
        
        static let allValues: [Tab] = [.congress, .main, .user]
        
        var image: UIImage {
            switch self {
            case .congress:
                return #imageLiteral(resourceName: "congressTabIcon").withRenderingMode(.alwaysOriginal)
            case .main:
                return #imageLiteral(resourceName: "kratosIcon").withRenderingMode(.alwaysOriginal)
            case .user:
                return #imageLiteral(resourceName: "userTabIcon").withRenderingMode(.alwaysOriginal)
            }
        }
        
        var selectedImage: UIImage {
            switch self {
            case .congress:
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
            case .congress:
                let vc = ExploreController(client: client)
                vc.tabBarItem = tabBarItem
                return vc
            case .main:
                let vc = UserRepsViewController(client: client)
                vc.tabBarItem = tabBarItem
                return vc
            case .user:
                let vc = TrackController(client: client)
                vc.tabBarItem = tabBarItem
                return vc
            }
        }
    }
    
    
    let scrollDelegate = ScrollingTabBarControllerDelegate()
    var firstItemImageView: UIImageView?
    var secondItemImageView: UIImageView?
    var thirdItemImageView: UIImageView?
    
    init(client: Client) {
        super.init(nibName: nil, bundle: nil)
        configure(with: client)
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
            tabImageView.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
        },
                       completion: nil)
        
        UIView.animate(withDuration: 0.5,
                       delay: 0.05, 
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 0,
                       options: .curveEaseOut,
                       animations: { () -> Void in
            tabImageView.transform = CGAffineTransform(rotationAngle: CGFloat.pi * 2)
        },
                       completion: nil)
    }
}
