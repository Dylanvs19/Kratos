//
//  Client.swift
//  Kratos
//
//  Created by Dylan Straughan on 5/3/17.
//  Copyright © 2017 Kratos, Inc. All rights reserved.
//

import Foundation
import Alamofire

enum KratosTarget: Target {
    //Login
    case register(user: User, fcmToken: String?)
    case confirmation(pin: String)
    case login(email: String, password: String)
    case forgotPassword(email: String)
    case resendConfirmation(email: String)
    //User
    //Metadata
    case fetchUser
    case update(user: User, fcmToken: String?)
    
    //BillTracking
    case fetchTrackedBills(pageNumber: Int)
    case fetchTrackedBillIds
    case trackBill(billID: Int)
    case viewTrackedBill(billID: Int)
    case untrackBill(billID: Int)
    
    //SubjectTracking
    case fetchTrackedSubjects
    case followSubject(subjectID: Int)
    case unfollowSubject(subjectID: Int)
    
    //UserVotes
    case fetchUserVotingRecord
    case createUserVote(voteValue: VoteValue, tallyID: Int)
    case fetchUserVote(tallyID: Int)
    case updateUserVote(voteValue: VoteValue, tallyID: Int)
    case deleteUserVote(tallyID: Int)
    
    //Congress
    //Metadata
    case determineRecess
    
    // Representatives
    case fetchRepresentatives(state: String, district: Int)
    case fetchPerson(personID: Int)
    case fetchTallies(personID: Int, pageNumber: Int)
    case fetchSponsoredBills(personID: Int, pageNumber: Int)

    //Vote
    case fetchTally(lightTallyID: Int)

    //Bill
    case fetchAllBills(pageNumber: Int)
    case fetchBill(billID: Int)
    case fetchBills(subjects: [Subject], tracked: Bool, pageNumber: Int)
    
    //Bills on the floor
    case fetchOnFloor(chamber: Chamber)
    case fetchTrendingBills
    
    //Subjects
    case fetchAllSubjects(onlyActive: Bool)
    
    //State
    case fetchDistricts(query: String)
    case fetchStatesAndDistricts
    case getStateImage(state: String)

    //Feedback
    case fetchFeedback
    case postFeedback(userID: Int, questions: [String: String])
    
    //Analytics
    case logContact(type: RepContactView.Contact, personId: Int)
    case logView(type: KratosAnalytics)
    
    //Image 
    case url(url: String)
    
    var parameters: [String: Any]? {
        switch self {
        case .register(let user, let token):
            var userDict = user.toJson()
            if let token = token,
               let user = userDict["user"] as? [String: Any] {
                var cpy = user
                cpy["push_token"] = token
                userDict["user"] = cpy
            }
            return userDict
        case .confirmation(let pin):
            return ["pin": pin]
        case .resendConfirmation(let email):
            return ["email": email]
        case .login(let email, let password):
            return ["session" :[
                                "email": email.lowercased(),
                                "password": password
                                ]
                    ]
        case .forgotPassword(let email):
            return ["email": email.lowercased()]
        case .update(let user, let token):
            var userDict = user.toJson()
            if let token = token,
                let user = userDict["user"] as? [String: Any] {
                var cpy = user
                cpy["push_token"] = token
                userDict["user"] = cpy
            }
            return userDict
        case .trackBill(let billID):
            return ["track": ["bill_id": billID ] ]
        case .followSubject(let subjectID):
            return ["follow": ["subject_id": subjectID ] ]
        case .createUserVote(let voteValue, let tallyID):
            return ["vote": ["tally_id": tallyID,
                             "value": voteValue.rawValue
                            ]
                   ]
        case .updateUserVote(let voteValue, let tallyID):
            return ["vote": [
                            "tally_id": tallyID,
                            "value": voteValue.rawValue
                            ]
                   ]
        case .postFeedback(let id, let questions):
            return ["user-id" : id,
                    "answers" : questions]
        case .logContact(let type, let personId):
            return ["user_action": ["action" : type.method.title,
                                    "person_id" : personId]]
        case .fetchDistricts(let query):
            return ["query": query]
        default:
            return nil
        }
    }
    
    var path: String {
        switch self {
        //Login
        case .register:
            return "/registrations"
        case .confirmation:
            return "/confirmation"
        case .login:
            return "/login"
        case .forgotPassword:
            return "/forgot-password"
        case .resendConfirmation:
            return "/confirmation/request"
            
        //User
        //Metadata
        case .fetchUser,
             .update:
            return "/me"
            
        //BillTracking
        case .fetchTrackedBills(let pageNumber):
            return "/me/bills?page=\(pageNumber)"
        case .fetchTrackedBillIds:
            return "/me/bills?onlyids=true"
        case .trackBill:
            return "/me/bills"
            
        case .viewTrackedBill(let billID),
             .untrackBill(let billID):
            return "/me/bills/\(billID)"
            
        //SubjectTracking
        case .fetchTrackedSubjects,
             .followSubject:
            return "/me/subjects"
        case .unfollowSubject(let subjectID):
            return "/me/subjects/\(subjectID)"
            
        //UserVotes
        case .fetchUserVotingRecord,
             .createUserVote:
            return "/me/votes"
        case .fetchUserVote(let tallyID),
             .deleteUserVote(let tallyID),
             .updateUserVote(_, let tallyID):
            return "/me/votes/\(tallyID)"
            
        //Congress
        //Metadata
        case .determineRecess:
            return "/congress/recess"
            
        // Representatives
        case .fetchRepresentatives(let state, let district):
            return "/districts/\(state)/\(district)"
        case .fetchPerson(let personID):
            return "/people/\(personID)"
        case .fetchTallies(let personID, let pageNumber):
            return "/people/\(personID)/votes?id=\(personID)&page=\(pageNumber)"
        case .fetchSponsoredBills(let personID, let pageNumber):
            return "/people/\(personID)/bills?id=\(personID)&page=\(pageNumber)"
        //Vote
        case .fetchTally(let lightTallyID):
            return "/tallies/\(lightTallyID)"
        //Bill
        case .fetchAllBills(let pageNumber):
            return "/bills?page=\(pageNumber)"
        case .fetchBill(let billID):
            return "/bills/\(billID)"
        case .fetchBills(let subjects, let tracked, let pageNumber):
            if subjects.isEmpty {
                return "/me/bills?page=\(pageNumber)&subjects[]=false&userbills=\(tracked)"
            } else {
                return subjects.reduce("/me/bills?page=\(pageNumber)&userbills=\(tracked)") { $0 + "&subjects[]=\($1.id)"}
            }
        case .fetchOnFloor(let chamber):
            return "/congress/\(chamber.pathValue)/floor"
        case .fetchTrendingBills:
            return "/congress/trending"
        //Subjects
        case .fetchAllSubjects(let onlyActive):
            return "/subjects?active=\(onlyActive)"
        //State
        case .fetchStatesAndDistricts:
            return "/states"
        case .getStateImage(let state):
            return "/states/\(state.lowercased())/image"
        //Feedback
        case .fetchFeedback,
             .postFeedback:
            return "/feedback"
        //Analytics
        case .logContact:
            return "/analytics/track/actions/"
        case .logView(let type):
            switch type {
            case .repViewed(let id):
                return "/analytics/track/person/\(id)/"
            case .tallyViewed(let id):
                return "/analytics/track/tally/\(id)/"
            case .billViewed(let id):
                return "/analytics/track/bill/\(id)/"
            }
        //Image
        case .url(let url):
            return url
        case .fetchDistricts:
            return "/districts"
        }
    }
    
    var method: Alamofire.HTTPMethod {
        switch self {
        case .register,
             .confirmation,
             .resendConfirmation,
             .login,
             .forgotPassword,
             .update,
             .trackBill,
             .followSubject,
             .createUserVote,
             .logContact,
             .logView,
             .postFeedback,
             .fetchDistricts:
            return .post
        case .untrackBill,
             .unfollowSubject,
             .deleteUserVote:
            return .delete
        case .updateUserVote:
            return .put
        default:
            return .get
        }
    }
    
    var parameterEncoding: ParameterEncoding{
        switch self {
        case .register,
             .confirmation,
             .resendConfirmation,
             .login,
             .forgotPassword,
             .update,
             .trackBill,
             .followSubject,
             .createUserVote,
             .updateUserVote,
             .postFeedback,
             .logContact,
             .fetchDistricts:
            return JSONEncoding.default
        default:
            return URLEncoding.default
        }
    }
}

extension KratosTarget: Equatable {
    
    static func ==(lhs: KratosTarget, rhs: KratosTarget) -> Bool {
        switch (lhs, rhs) {
        case (.register, .register),
             (.confirmation, .confirmation),
             (.login, .login),
             (.forgotPassword, .forgotPassword),
             (.resendConfirmation, .resendConfirmation),
             (.fetchUser, .fetchUser),
             (.update, .update),
             (.fetchTrackedBills, .fetchTrackedBills),
             (.fetchTrackedBillIds, .fetchTrackedBillIds),
             (.trackBill, .trackBill),
             (.viewTrackedBill, .viewTrackedBill),
             (.untrackBill, .untrackBill),
             (.fetchTrackedSubjects, .fetchTrackedSubjects),
             (.followSubject, .followSubject),
             (.unfollowSubject, .unfollowSubject),
             (.fetchUserVotingRecord, .fetchUserVotingRecord),
             (.createUserVote, .createUserVote),
             (.fetchUserVote, .fetchUserVote),
             (.updateUserVote, .updateUserVote),
             (.deleteUserVote, .deleteUserVote),
             (.determineRecess, .determineRecess),
             (.fetchRepresentatives, .fetchRepresentatives),
             (.fetchPerson, .fetchPerson),
             (.fetchTallies, .fetchTallies),
             (.fetchSponsoredBills, .fetchSponsoredBills),
             (.fetchTally, .fetchTally),
             (.fetchAllBills, .fetchAllBills),
             (.fetchBill, .fetchBill),
             (.fetchBills, .fetchBills),
             (.fetchAllSubjects, .fetchAllSubjects),
             (.fetchStatesAndDistricts, .fetchStatesAndDistricts),
             (.getStateImage, .getStateImage),
             (.fetchFeedback, .fetchFeedback),
             (.postFeedback, .postFeedback),
             (.logView, .logView),
             (.logContact, .logContact):
            return true
        default:
            return false
        }
    }
    
    static func !=(lhs: KratosTarget, rhs: KratosTarget) -> Bool {
        return !(lhs == rhs)
    }
}
