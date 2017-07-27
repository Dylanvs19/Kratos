//
//  FirebaseAnalyicAction.swift
//  Kratos
//
//  Created by Dylan Straughan on 1/19/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import UIKit
import Firebase

enum FirebaseAnalytics {
    
    case registerTapped
    case submitTapped
    case login
    case expanded(viewType: ExpandableViewType, id: Int?)
    case mainViewRepresentativeSelection(representativeID: Int?)
    case selectedRepresentative(representativeID: Int?)
    case contact(representativeID: Int?, contactType: KratosAnalytics.ContactAnalyticType)
    case userVoted(voteValue: VoteValue)
    case pushMenuBar
    case popMenuBar
    case pressedMenuBar(button: MenuBarButton)
    case editedAccountDetails
    case selectedUserVote(userVoteId: Int?)
    case loggedOut
    
    func fireEvent() {
        
        func appendData(to dict: [String: NSObject]? = nil) -> [String: NSObject] {
            var returnDict = dict ?? [String: NSObject]()
            returnDict["date"] = DateFormatter.utc.string(from: Date()) as NSObject
//            if let id = Datastore.shared.user?.id {
//                returnDict["userId"] = id as NSObject
//            }
            return returnDict
        }
        
        switch self {
        case .registerTapped:
            FIRAnalytics.logEvent(withName: BaseAnalyticType.registerTapped.rawValue, parameters: appendData())
            
        case .submitTapped:
            FIRAnalytics.logEvent(withName: BaseAnalyticType.submitTapped.rawValue, parameters: appendData())
            
        case .login:
            FIRAnalytics.logEvent(withName: BaseAnalyticType.login.rawValue, parameters: appendData())
            
        case .expanded(let expandableView, let id):
            var dict: [String: NSObject] = ["expandableView": String(describing: type(of: expandableView)) as NSObject]
            if let id = id {
                dict["id"] = id as NSObject
            }
            FIRAnalytics.logEvent(withName: BaseAnalyticType.expandedView.rawValue, parameters: appendData(to: dict))
        case .mainViewRepresentativeSelection(let personID):
            let dict: [String: NSObject] = ["id": String(describing: type(of: personID)) as NSObject]
            FIRAnalytics.logEvent(withName: BaseAnalyticType.mainViewRepresentativeSelection.rawValue, parameters: appendData(to: dict))
        case .selectedRepresentative(let personID):
            let dict: [String: NSObject] = ["id": String(describing: type(of: personID)) as NSObject]
            FIRAnalytics.logEvent(withName: BaseAnalyticType.selectedRepresentative.rawValue, parameters: appendData(to: dict))
        case .contact(let personID, let contactType):
            var dict = ["contactType" : contactType.rawValue as NSObject]
            if let id = personID {
                dict["id"] = id as NSObject
            }
            FIRAnalytics.logEvent(withName: BaseAnalyticType.contactedRepresentative.rawValue, parameters: appendData(to: dict))
        case .userVoted(let voteValue):
            let dict: [String: NSObject] = ["voteValue": voteValue.rawValue as NSObject]
            FIRAnalytics.logEvent(withName: BaseAnalyticType.userVoteViewed.rawValue, parameters: appendData(to: dict))
        case .pushMenuBar:
            FIRAnalytics.logEvent(withName: BaseAnalyticType.pushMenuBar.rawValue, parameters: appendData())
        case .popMenuBar:
            FIRAnalytics.logEvent(withName: BaseAnalyticType.popMenuBar.rawValue, parameters: appendData())
        case .pressedMenuBar(let menuButton):
            let dict: [String: NSObject] = ["button": menuButton.rawValue as NSObject]
            FIRAnalytics.logEvent(withName: BaseAnalyticType.pressedMenuBarButton.rawValue, parameters: appendData(to: dict))
        case .editedAccountDetails:
            FIRAnalytics.logEvent(withName: BaseAnalyticType.editedAccountDetails.rawValue, parameters: appendData())
        case .selectedUserVote(let tallyID):
            var dict = [String: NSObject]()
            if let id = tallyID {
                dict["tally"] = id as NSObject
            }
            FIRAnalytics.logEvent(withName: BaseAnalyticType.userVoteViewed.rawValue, parameters: appendData(to: dict))
        case .loggedOut:
            FIRAnalytics.logEvent(withName: BaseAnalyticType.loggedOut.rawValue, parameters: appendData())
        }
    }
    
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
}
