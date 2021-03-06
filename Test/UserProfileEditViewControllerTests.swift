//
//  UserProfileEditViewControllerTests.swift
//  edX
//
//  Created by Akiva Leffert on 10/30/15.
//  Copyright © 2015 edX. All rights reserved.
//

import Foundation
@testable import edX

class UserProfileEditViewControllerTests : SnapshotTestCase {
    
    var profile : UserProfile {
        return UserProfile(username: "Test Person", bio: "Hello I am a lorem ipsum dolor sit amet", parentalConsent: false, countryCode: "de", accountPrivacy: .Public)
    }
    
    func testSnapshotPublic() {
        let env = UserProfileEditViewController.Environment(networkManager: MockNetworkManager(), userProfileManager:MockUserProfileManager())
        let controller = UserProfileEditViewController(profile: profile, environment: env)
        inScreenNavigationContext(controller, action: { () -> () in
            assertSnapshotValidWithContent(controller.navigationController!)
        })
    }

}