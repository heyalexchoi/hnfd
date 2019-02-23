//
//  AppDelegate.swift
//  HackerNews
//
//  Created by alexchoi on 4/9/15.
//  Copyright (c) 2015 Alex Choi. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        if let window = window {
            let tabBarController = UITabBarController()
            let storiesNavigationController = UINavigationController(rootViewController: StoriesViewController())
            let searchNavigationController = UINavigationController(rootViewController: SearchViewController())
//            tabBarController.viewControllers = [storiesNavigationController, searchNavigationController]
            tabBarController.viewControllers = [searchNavigationController]

            window.rootViewController = tabBarController
            window.makeKeyAndVisible()
        }
        
        let urlCache = Foundation.URLCache(memoryCapacity: 20 * 1024 * 1024, diskCapacity: 20 * 1024 * 1024, diskPath: nil)        
        URLCache.shared = urlCache
        
        Appearance.setAppearances()
        
        UIApplication.shared.setMinimumBackgroundFetchInterval(3600) // 1 hour must pass before another background fetch will be initiated
        
        return true
    }
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // just prefetch the first 25 top stories
        DataSource.fullySync(storiesType: .Top, limit: 25, offset: 0, timeout: 25)
        .then { () -> (Void) in
            completionHandler(.newData)
        }
        .catch { (error) in
            completionHandler(.failed)
        }
    }
    
    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        Downloader.backgroundManager.backgroundCompletionHandler = completionHandler // wat
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
}
