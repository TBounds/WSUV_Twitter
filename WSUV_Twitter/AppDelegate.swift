//
//  AppDelegate.swift
//  WSUV_Twitter
//
//  Created by Tyler James Bounds on 3/21/17.
//  Copyright © 2017 Tyler James Bounds. All rights reserved.
//

import UIKit

struct Tweet : Hashable {
    var tweet_id : Int
    var username : String
    var isdeleted : Bool
    var tweet : NSString
    var date : NSDate
    
    var hashValue: Int {
        return self.tweet_id
    }
    
    init(_ tweet_id: Int, _ username : String, _ isdeleted : Bool, _ tweet : NSString, _ date : NSDate){
        self.tweet_id = tweet_id
        self.username = username
        self.isdeleted = isdeleted
        self.tweet = tweet
        self.date = date
    }

}

// http://samuelmullen.com/2014/10/implementing_swifts_hashable_protocol/
func == (lhs: Tweet, rhs: Tweet) -> Bool {
    return lhs.tweet_id == rhs.tweet_id
}

let kAddTweetNotification = Notification.Name("AddTweetNotification")

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var tweets : [Tweet] = []
    
    func lastTweetDate() -> Date {
        // http://www.globalnerdy.com/2016/08/18/how-to-work-with-dates-and-times-in-swift-3-part-1-dates-calendars-and-datecomponents/
        let lastYear = Date(timeIntervalSinceNow: -1 * 60 * 60 * 364 * 24)
        return lastYear
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // tweets.append(Tweet(1, "Tommy Boi", false, "This is just a test. Do not be alarmed.", Date() as NSDate))
        // tweets.append(Tweet(2, "Pamala Handerson", false, "Someone love me...pls.", Date() as NSDate))
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

