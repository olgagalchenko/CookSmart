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
    buildIosApp(project: "CookSmart.xcodeproj",
                scheme: "cake")

  }
}
