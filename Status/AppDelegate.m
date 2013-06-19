//
//  AppDelegate.m
//  Status
//
//  Created by Paul Denya on 1/24/13.
//  Copyright (c) 2013 NEXTMARVEL. All rights reserved.
//

#import "AppDelegate.h"

#import "ViewController.h"
#import <FacebookSDK/FacebookSDK.h>


@implementation AppDelegate

- (void)dealloc
{
	[_window release];
	[_viewController release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
	self.viewController = [[[ViewController alloc] initWithNibName:@"ViewController" bundle:nil] autorelease];
	self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application	 {
	// We need to properly handle activation of the application with regards to Facebook Login
	// (e.g., returning from iOS 6.0 Login Dialog or from fast app switching).
	[FBSession.activeSession handleDidBecomeActive];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
	if ([url.scheme isEqualToString:@"nmstatus"]) {
		return YES;
	}
	
    return [FBSession.activeSession handleOpenURL:url];
}

@end
