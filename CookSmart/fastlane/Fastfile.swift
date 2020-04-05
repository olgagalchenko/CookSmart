// This file contains the fastlane.tools configuration
// You can find the documentation at https://docs.fastlane.tools
//
// For a list of all available actions, check out
//
//     https://docs.fastlane.tools/actions
//

import Foundation

class Fastfile: LaneFile {
	func buildLane() {
    desc("Builds cake")
		// add actions here: https://docs.fastlane.tools/actions

//    createKeychain(name: <#T##String?#>,
//                   path: <#T##String?#>,
//                   password: <#T##String#>,
//                   defaultKeychain: <#T##Bool#>,
//                   unlock: <#T##Bool#>,
//                   timeout: <#T##Int#>,
//                   lockWhenSleeps: <#T##Bool#>,
//                   lockAfterTimeout: <#T##Bool#>,
//                   addToSearchList: <#T##Bool#>,
//                   requireCreate: <#T##Bool#>)
//
//    cert(username: "alexking124@gmail.com",
//         teamId: <#T##String?#>,
//         teamName: <#T##String?#>,
//         filename: <#T##String?#>,
//         outputPath: <#T##String#>,
//         keychainPath: <#T##String#>,
//         keychainPassword: <#T##String?#>,
//         platform: "ios")
//
//    sigh(adhoc: <#T##Bool#>,
//         developerId: <#T##Bool#>,
//         development: <#T##Bool#>,
//         skipInstall: <#T##Bool#>,
//         force: <#T##Bool#>,
//         appIdentifier: <#T##String#>,
//         username: <#T##String#>,
//         teamId: <#T##String?#>,
//         teamName: <#T##String?#>,
//         provisioningName: <#T##String?#>,
//         ignoreProfilesWithDifferentName: <#T##Bool#>,
//         outputPath: <#T##String#>,
//         certId: <#T##String?#>,
//         certOwnerName: <#T##String?#>,
//         filename: <#T##String?#>,
//         skipFetchProfiles: <#T##Bool#>,
//         skipCertificateVerification: <#T##Bool#>,
//         platform: <#T##Any#>,
//         readonly: <#T##Bool#>,
//         templateName: <#T##String?#>)

    buildIosApp(skipCodesigning: true)
  }
}
