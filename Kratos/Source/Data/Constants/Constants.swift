//
// Contstants.swift
// Kratos
//
// Created by Dylan Straughan on 8/9/16.
// Copyright © 2017 Kratos, Inc. All rights reserved.
//

import Foundation

enum Constant: String {
    // generic
    case kratos = "K R A T O S"
    case monospaceVotes = "VOTES"
    case monospaceDetails = "DETAILS"
    case login = "L O G I N"
    case birthdate = "B I R T H D A T E"
    case party = "P A R T Y"
    case register = "R E G I S T E R"
    case submit = "S U B M I T"
    case ok = "OK"
    
    case welcomeCreateButtonTitle = "Create Account"
    
    //LoginVC
    case loginContinueButtonTitle = "C R E A T E"
    case loginSendButtonTitle = "S E N D"
    case loginSignUpButtonTitle = "S I G N U P"
    case loginSignInButtonTitle = "S I G N I N"
    case loginForgotPasswordButtonTitle = "Forgot Password"
    case loginForgotPasswordAlertTitle = "Email Sent!"
    case loginForgotPasswordAlertText = "An email with instructions for resetting your password has been sent."
    
    //AccountDetailsVC
    case accountDetailsSaveButtonTitle = "S A V E"
    case accountDetailsEditButtonTitle = "E D I T"
    case accountDetailsCancelButtonTitle = "C A N C E L"
    case accountDetailsDoneButtonTitle = "D O N E"
    case accountDetailsPartyActionSheetDescription = "Choose your party affiliation"
    case accountDetailsDemocratButtonTitle = "D E M O C R A T"
    case accountDetailsDemocratText = "Democrat"
    case accountDetailsRepublicanButtonTitle = "R E P U B L I C A N"
    case accountDetailsRepublicanText = "Republican"
    case accountDetailsIndependentButtonTitle = "I N D E P E N D E N T"
    case accountDetailsIndependentText = "Independent"
    case accountDetailsAddressExplanationText = "Your address is used to locate your congressional district."
    
    //KratosTextFields
    case textFieldEmailTitle = "E M A I L"
    case textFieldEmailTitleInvalid = "Please enter a valid email address."
    case textFieldPasswordTitle = "P A S S W O R D"
    case textFieldPasswordTitleInvalid = "Your password must be longer than 6 characters."
    case textFieldFirstTitle = "F I R S T"
    case textFieldFirstTitleInvalid = "Your first name must be longer than 3 characters."
    case textFieldLastTitle = "L A S T"
    case textFieldLastTitleInvalid = "Your last name must be longer than 3 characters."
    case textFieldAddressTitle = "A D D R E S S"
    case textFieldAddressTitleInvalid = "Please enter a valid street address."
    case textFieldCityTitle = "C I T Y"
    case textFieldCityTitleInvalid = "Please enter a valid city name."
    case textFieldStateTitle = "S T A T E"
    case textFieldStateTitleInvalid = "Please enter a valid state."
    case textFieldZipcodeTitle = "Z I P C O D E"
    case textFieldZipcodeTitleInvalid = "Please enter a valid zip code"
    case textFieldConfirmationTitle = "C O N F I R M A T I O N"
    case textFieldConfirmationTitleInvalid = "Please enter a valid confirmation number."
    case textFieldSearchTitle = "S E A R C H"
    
    //ConfirmationVC
    case confirmationTitle = "Confirmation"
    case confirmationResendConfirmationButtonTitle = "RESEND CONFIRMATION"
    case confirmationExplainationText = "A confirmation code has just been sent to your email address. Enter it here:"
    
    // NotificationVC
    case notificationTitle = "Notifications"
    case notificationSkipButtonTitle = "S K I P"
    case notificationExplanationText = "We use notifications to inform you when your representatives are voting on things that you care about. We do not spam you with news about every breath they take, we focus on the important stuff."
    
    //ExploreVC
    case exploreTitle = "On The Floor"
    case exploreSenateButtonTitle = "SENATE"
    case exploreHouseButtonTitle = "HOUSE"
    case exploreTrendingButtonTitle = "TRENDING"
    case exploreRecessLabelTitle = "Congress is currently in recess. Check out your representatives' websites for events."
    case exploreSenateEmptyLabel = "The Senate currently has no bills to consider in the upcoming days."
    case exploreHouseEmptyLabel = "The House currently has no bills to consider in the upcoming days."
    case exploreTrendingEmptyLabel = "There are no bills trending in Congress."
    
    //UserVC
    case userTitle = "My Bills"
    case userBillsSubjectEmptyStateMessage = "There are no bills whose top term is this subject."
    case userBillsNoSubjectSelectedEmptyStateMessage = "Select a subject."
    case userBillsNoTrackedSubjectsOrBillsEmptyStateMessage = "You have no tracked bills or tracked subjects."
    
    // User Rep VC
    case districtSelectionReturnHomeButtonTitle = "Return Home"
    case districtSelectionSearchInfoLabel = "Enter an address and sumbit to see another congressional district."
    case districtSelectionTitle = "District Selection"
    
    //BillVC
    case billTrackButtonTrackedTitle = "TRACKING"
    case billTrackButtonUntrackedTitle = "TRACK"

    //SubjectSelectionVC
    case subjectSelectionTitle = "Select Subjects"
    
    // RepInfoView
    case repInfoViewBioTitle = "BIOGRAPHY"
    case repInfoViewBillsTitle = "SPONSOR"
    case repInfoViewTermsSectionTitle = "Terms"
    
    // BillInfoView
    case billInfoViewSummaryTitle = "SUMMARY"
    case billInfoViewSponsorsTitle = "SPONSORS"
    case billInfoViewVotesEmptyTitle = "There have been no votes for this bill."
    case billInfoViewEmptyVotes = "There have been no votes on this bill."
    
    // MenuVC
    case menuAccountDetailsButtonTitle = "Account Details"
    case menuFeedbackButtonTitle = "Feedback"
    case menuLogoutButtonTitle = "Logout"
    case menuCloseButtonTitle = "Close"
    
    //Error
    case errorTitle = "Error"
    case errorMessage = "Something went wrong on our end. Check back soon."
}

func localize(_ constant: Constant) -> String {
  return constant.rawValue
}
