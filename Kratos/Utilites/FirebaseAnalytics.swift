//
//  FirebaseAnalyicAction.swift
//  Kratos
//
//  Created by Dylan Straughan on 1/19/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import UIKit
import Firebase

struct FirebaseAnalytics {
    
    enum ModelType: String {
        case person
        case tally
        case bill
        case userVote
    }
    
    enum ExpandableViewType: String{
        case RepListView
        case CommitteeView
        case ActionsView
    }
    
    enum MenuBarButton: String {
        case AccountDetail
        case UserVote
        case Info
    }
    
    enum BaseAnalyticType: String {
        case registerTapped
        case submitTapped
        case login
        case tap
        case swipe
        case pan
        case navigatedToNewViewController
        case expandedView
        case mainViewRepresentativeSelection
        case selectedRepresentative
        case contactedRepresentative
        case userVoteViewed
        case pushMenuBar
        case popMenuBar
        case pressedMenuBarButton
        case editedAccountDetails
        case selectedUserVote
        case loggedOut
    }
    
    enum FlowAnalytic {
        case registerTapped
        case submitTapped
        case login
        case tap(view: UIView, viewController: UIViewController?)
        case swipe(view: UIView, viewController: UIViewController?)
        case pan(view: UIView, viewController: UIViewController?)
        case navigate(to: UIViewController, with: ModelType?, id: Int?)
        case expanded(viewType: ExpandableViewType, id: Int?)
        case mainViewRepresentativeSelection(representativeID: Int)
        case selectedRepresentative(representativeID: Int)
        case contact(representativeID: Int, contactType: KratosAnalytics.ContactAnalyticType)
        case userVoted(voteValue: VoteValue)
        case pushMenuBar
        case popMenuBar
        case pressedMenuBar(button: MenuBarButton)
        case editedAccountDetails
        case selectedUserVote(userVoteId: Int)
        case loggedOut
        
        func fireEvent() {
            switch self {
            case .registerTapped:
                FIRAnalytics.logEvent(withName: BaseAnalyticType.registerTapped.rawValue, parameters: nil)
            case .submitTapped:
                FIRAnalytics.logEvent(withName: BaseAnalyticType.submitTapped.rawValue, parameters: nil)
            case .login:
                FIRAnalytics.logEvent(withName: BaseAnalyticType.login.rawValue, parameters: nil)
            case .tap(let view, let viewController):
                FIRAnalytics.logEvent(withName: BaseAnalyticType.tap.rawValue, parameters: ["view": String(describing: type(of: view)) as NSObject,
                                                                                            "viewController" : String(describing: type(of: viewController)) as NSObject])
            case .swipe(let view, let viewController):
                FIRAnalytics.logEvent(withName: BaseAnalyticType.swipe.rawValue, parameters: ["view": String(describing: type(of: view)) as NSObject,
                                                                                              "viewController" : String(describing: type(of: viewController)) as NSObject])
            case .pan(let view, let viewController):
                FIRAnalytics.logEvent(withName: BaseAnalyticType.pan.rawValue, parameters: ["view": String(describing: type(of: view)) as NSObject,
                                                                                            "viewController" : String(describing: type(of: viewController)) as NSObject])
            case .navigate(let viewController, let modelType, let id):
                var parameters = ["viewController": String(describing: type(of: viewController)) as NSObject]
                if let modelType = modelType {
                    parameters["modelType"] = modelType.rawValue as NSObject
                }
                if let id = id {
                    parameters["id"] = id as NSObject
                }
                FIRAnalytics.logEvent(withName: BaseAnalyticType.navigatedToNewViewController.rawValue, parameters: parameters)
                
            case .expanded(let expandableView, let id):
                var parameters = ["expandableView": String(describing: type(of: expandableView)) as NSObject]
                if let id = id {
                    parameters["id"] = id as NSObject
                }
                FIRAnalytics.logEvent(withName: BaseAnalyticType.expandedView.rawValue, parameters: parameters)
            case .mainViewRepresentativeSelection(let personID):
                FIRAnalytics.logEvent(withName: BaseAnalyticType.mainViewRepresentativeSelection.rawValue, parameters: ["id": String(describing: type(of: personID)) as NSObject])
            case .selectedRepresentative(let personID):
                FIRAnalytics.logEvent(withName: BaseAnalyticType.selectedRepresentative.rawValue, parameters: ["id": String(describing: type(of: personID)) as NSObject])
            case .contact(let personID, let contactType):
                FIRAnalytics.logEvent(withName: BaseAnalyticType.contactedRepresentative.rawValue, parameters: ["id": personID as NSObject,
                                                                                                                "contactType" : contactType.rawValue as NSObject])
            case .userVoted(let voteValue):
                FIRAnalytics.logEvent(withName: BaseAnalyticType.userVoteViewed.rawValue, parameters: ["voteValue": voteValue.rawValue as NSObject])
            case .pushMenuBar:
                FIRAnalytics.logEvent(withName: BaseAnalyticType.pushMenuBar.rawValue, parameters: nil)
            case .popMenuBar:
                FIRAnalytics.logEvent(withName: BaseAnalyticType.popMenuBar.rawValue, parameters: nil)
            case .pressedMenuBar(let menuButton):
                FIRAnalytics.logEvent(withName: BaseAnalyticType.pressedMenuBarButton.rawValue, parameters: ["button": menuButton.rawValue as NSObject])
            case .editedAccountDetails:
                FIRAnalytics.logEvent(withName: BaseAnalyticType.editedAccountDetails.rawValue, parameters: nil)
            case .selectedUserVote(let tally):
                FIRAnalytics.logEvent(withName: BaseAnalyticType.userVoteViewed.rawValue, parameters: ["tally": tally as NSObject])
            case .loggedOut:
                FIRAnalytics.logEvent(withName: BaseAnalyticType.loggedOut.rawValue, parameters: nil)
            }
        }
    }
}
