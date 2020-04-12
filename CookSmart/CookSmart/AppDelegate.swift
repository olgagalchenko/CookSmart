//
//  AppDelegate.swift
//  test
//
//  Created by Alex King on 4/11/20.
//  Copyright © 2020 Alex King. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // Override point for customization after application launch.
    logAppLifecycleEvent("launch", nil)
    return true
  }

  // MARK: UISceneSession Lifecycle

  func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
  }

  func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
  }

  // MARK: Legacy Lifecycle

  func applicationWillResignActive(_ application: UIApplication) {
    logAppLifecycleEvent("resign_active", nil)
  }

  func applicationDidEnterBackground(_ application: UIApplication) {
    logAppLifecycleEvent("enter_background", nil)
  }

  func applicationWillEnterForeground(_ application: UIApplication) {
    logAppLifecycleEvent("enter_foreground", nil)
  }

  func applicationDidBecomeActive(_ application: UIApplication) {
    logAppLifecycleEvent("become_active", nil)
  }

  func applicationWillTerminate(_ application: UIApplication) {
    logAppLifecycleEvent("terminate", nil)
  }
}
