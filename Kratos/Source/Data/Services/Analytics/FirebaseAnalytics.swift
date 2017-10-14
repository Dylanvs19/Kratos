//
//  FirebaseAnalyicAction.swift
//  Kratos
//
//  Created by Dylan Straughan on 1/19/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import UIKit
import Firebase

protocol AnalyticsEnabled {
    var client: Client { get set }
}

extension AnalyticsEnabled {
    func log(event: FirebaseAnalytics) {
        event.fire()
    }
}

enum KratosAnalytics {
    case repViewed(id: Int)
    case tallyViewed(id: Int)
    case billViewed(id: Int)
}

enum FirebaseAnalytics {
    
    enum LoginAction: String {
        case create
        case forgotPassword
        case login
        
        var event: String {
            switch self {
            case .create: return "login_create"
            case .forgotPassword: return "login_forgot_password"
            case .login: return "login_login"
            }
        }
    }
    
    enum AccountDetailsAction: String {
        case edit
        case register
        
        var event: String {
            switch self {
            case .edit: return "accountDetails_edit"
            case .register: return "accountDetails_register"
            }
        }
    }
    
    enum NotificationOption {
        case register
        case skip
        
        var event: String {
            switch self {
            case .register: return "notifications_register"
            case .skip: return "notifications_skip"
            }
        }
    }
    
    enum MenuAction {
        case accountDetails
        case logout
        case privacyPolicy
        
        var event: String {
            switch self {
            case .accountDetails: return "menu_accountDetails"
            case .privacyPolicy: return "menu_privacyPolicy"
            case .logout: return "menu_logout"
            }
        }
    }
    
    enum ExploreAction {
        case exploreTabSelected(ExploreController.State)
        case billSelected(id: Int)
        
        var event: String {
            switch self {
            case .exploreTabSelected(let tab): return "explore_tabSelected_\(tab.title)"
            case .billSelected(let id): return "explore_billSelected_\(id)"
            }
        }
    }
    
    enum UserAction {
        case subjectSelected(id: Int)
        case subjectDeselected(id: Int)
        case billSelected(id: Int)
        
        var event: String {
            switch self {
            case .subjectSelected(let id): return "userVC_subjectSelected_\(id)"
            case .subjectDeselected(let id): return "userVC_subjectDeselected_\(id)"
            case .billSelected(let id): return "userVC_billSelected_\(id)"
            }
        }
    }
    
    enum RepAction {
        case tabSelected(RepInfoView.State)
        case tallySelected(id: Int)
        case billSelected(id: Int)
        var event: String {
            switch self {
            case .tabSelected(let tab): return "representativeVC_tabSelected_\(tab.title)"
            case .tallySelected(let id): return "representativeVC_tallySelected_\(id)"
            case .billSelected(let id): return "representativeVC_billSelected_\(id)"
            }
        }
    }
    
    enum BillAction {
        case tabSelected(BillInfoView.State)
        case tallySelected(id: Int)
        case repSelected(id: Int)
        case track(id: Int)
        case untrack(id: Int)
        
        var event: String {
            switch self {
            case .tabSelected(let tab): return "billVC_tabSelected_\(tab.title)"
            case .tallySelected(let id): return "billVC_tallySelected_\(id)"
            case .repSelected(let id): return "billVC_repSelected_\(id)"
            case .track(let id): return "billVC_track_\(id)"
            case .untrack(let id): return "billVC_untrack_\(id)"
            }
        }
    }
    
    enum TallyAction {
        case tabSelected(TallyController.State)
        case repSelected(id: Int)
        var event: String {
            switch self {
            case .tabSelected(let tab): return "tallyVC_tabSelected_\(tab.title)"
            case .repSelected(let id): return "tallyVC_repSelected_\(id)"
            }
        }
    }
    
    //TabBarController
    case appTabSelected(TabBarController.Tab)
    
    //Login
    case loginController
    case login(LoginAction)
    
    //AccountDetails
    case accountDetailsController
    case accountDetails(AccountDetailsAction)
    
    //Notifications
    case notificationController
    case notification(NotificationOption)
    
    //Confirmation
    case confirmationController
    case confirmed
    
    //Menu
    case menuController
    case menu(MenuAction)
    
    //MainController
    case mainController
    case repSelected(id: Int)
    
    //ExploreController
    case exploreController
    case explore(ExploreAction)
    
    //UserController
    case userController
    case user(UserAction)
    
    //RepController
    case representativeController
    case representative(RepAction)
    
    case billController
    case bill(BillAction)
    
    case tallyController
    case tally(TallyAction)
    
    case error(KratosError)
    
    func fire() {
        
        func appendData(to dict: [String: NSObject]? = nil) -> [String: NSObject] {
            var returnDict = dict ?? [String: NSObject]()
            returnDict["date"] = DateFormatter.utc.string(from: Date()) as NSObject
            
            return returnDict
        }
        
        switch self {
        // TabBarController
        case .appTabSelected(let tab): FIRAnalytics.logEvent(withName: "tabSelected_\(tab.rawValue)", parameters: nil)
        // Login
        case .loginController: FIRAnalytics.logEvent(withName: "loginVC", parameters: nil)
        case .login(let action): FIRAnalytics.logEvent(withName: action.event, parameters: nil)
        // AccountDetails
        case .accountDetailsController: FIRAnalytics.logEvent(withName: "accountDetailsVC", parameters: nil)
        case .accountDetails(let action): FIRAnalytics.logEvent(withName: action.event, parameters: nil)
        // Notifications
        case .notificationController: FIRAnalytics.logEvent(withName: "notificationVC", parameters: nil)
        case .notification(let action): FIRAnalytics.logEvent(withName: action.event, parameters: nil)
        // Confirmation
        case .confirmationController: FIRAnalytics.logEvent(withName: "confirmationVC", parameters: nil)
        case .confirmed: FIRAnalytics.logEvent(withName: "confirmation_confirmed", parameters: nil)
        // Menu
        case .menuController:
            FIRAnalytics.logEvent(withName: "menuVC", parameters: nil)
        case .menu(let action):
             FIRAnalytics.logEvent(withName: action.event, parameters: nil)
        // MainController
        case .mainController: FIRAnalytics.logEvent(withName: "mainVC", parameters: nil)
        case .repSelected(let id): FIRAnalytics.logEvent(withName: "mainVC_repSelected_\(id)", parameters: nil)
        // ExploreController
        case .exploreController: FIRAnalytics.logEvent(withName: "exploreVC", parameters: nil)
        case .explore(let action): FIRAnalytics.logEvent(withName: action.event, parameters: nil)
        // UserController
        case .userController: FIRAnalytics.logEvent(withName: "userVC", parameters: nil)
        case .user(let action): FIRAnalytics.logEvent(withName: action.event, parameters: nil)
        // RepController
        case .representativeController: FIRAnalytics.logEvent(withName: "repVC", parameters: nil)
        case .representative(let action): FIRAnalytics.logEvent(withName: action.event, parameters: nil)
        // BillController
        case .billController: FIRAnalytics.logEvent(withName: "billVC", parameters: nil)
        case .bill(let action): FIRAnalytics.logEvent(withName: action.event, parameters: nil)
        // TallyController
        case .tallyController: FIRAnalytics.logEvent(withName: "tallyVC", parameters: nil)
        case .tally(let action): FIRAnalytics.logEvent(withName: action.event, parameters: nil)
        // Error
        case .error(let error): FIRAnalytics.logEvent(withName: error.localizedDescription, parameters: nil)
        }
    }
}
