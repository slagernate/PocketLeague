//
//  AppDelegate.swift
//  NCSoccer
//
//  Created by Nathan Slager on 8/29/16.
//  Copyright © 2016 nathanslager. All rights reserved.
//

import UIKit

//let matchFinderVC = MatchFinderViewController()

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

		var window: UIWindow?

/* If you don't know when these are called, set breakpoints and launch/open/close/relaunch the app. Or just read what I noticed when launching/opening/closing/relaunching the app. */
	
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		// Override point for customization after application launch.
		
		/* Nate: Called at application launch only */
		return true
	}

	func applicationWillResignActive(_ application: UIApplication) {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
		
		
		/* Nate: Called immediately after one of these scenarios
			1. Home button pressed
		
		
		*/

	}

	func applicationDidEnterBackground(_ application: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
		
		/* Nate: Called when the home is pressed, but after the applicationWillResignActive func. This is the last func called before control is given away */
	}

	func applicationWillEnterForeground(_ application: UIApplication) {
		// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
		
		/* Nate: Only called when the app is revisted (e.g. not called when app is launched for the first time) */

	}

	func applicationDidBecomeActive(_ application: UIApplication) {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
		
		/* Nate: called either:
			1. after application() (after application launched)
		OR 
			2. after applicationWillEnterForeground (app is revisited) 
		
		--Last function called before application takes over  */
		


	}

	func applicationWillTerminate(_ application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
		/* Nate: */

	}


}

