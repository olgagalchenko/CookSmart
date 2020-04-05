// This file contains the fastlane.tools configuration
// You can find the documentation at https://docs.fastlane.tools
//
// For a list of all available actions, check out
//
//     https://docs.fastlane.tools/actions
//

import Foundation

class Fastfile: LaneFile {
	func addToTestflightLane() {
		desc("Description of what the lane does")
		// add actions here: https://docs.fastlane.tools/actions
    buildIosApp(scheme: <#T##String?#>,
                clean: <#T##Bool#>,
                outputDirectory: <#T##String#>,
                outputName: <#T##String?#>,
                configuration: <#T##String?#>,
                silent: <#T##Bool#>,
                codesigningIdentity: <#T##String?#>,
                skipPackageIpa: <#T##Bool#>,
                includeSymbols: <#T##Bool?#>,
                includeBitcode: <#T##Bool?#>,
                exportMethod: <#T##String?#>,
                exportOptions: <#T##[String : Any]?#>,
                exportXcargs: <#T##String?#>,
                skipBuildArchive: <#T##Bool?#>,
                skipArchive: <#T##Bool?#>,
                skipCodesigning: <#T##Bool?#>,
                buildPath: <#T##String?#>,
                archivePath: <#T##String?#>,
                derivedDataPath: <#T##String?#>,
                resultBundle: <#T##Bool#>,
                resultBundlePath: <#T##String?#>,
                buildlogPath: <#T##String#>,
                sdk: <#T##String?#>,
                toolchain: <#T##String?#>,
                destination: <#T##String?#>,
                exportTeamId: <#T##String?#>,
                xcargs: <#T##String?#>,
                xcconfig: <#T##String?#>,
                suppressXcodeOutput: <#T##Bool?#>,
                disableXcpretty: <#T##Bool?#>,
                xcprettyTestFormat: <#T##Bool?#>,
                xcprettyFormatter: <#T##String?#>,
                xcprettyReportJunit: <#T##String?#>,
                xcprettyReportHtml: <#T##String?#>,
                xcprettyReportJson: <#T##String?#>,
                analyzeBuildTime: <#T##Bool?#>,
                xcprettyUtf: <#T##Bool?#>,
                skipProfileDetection: <#T##Bool#>,
                clonedSourcePackagesPath: <#T##String?#>)
	}
}
