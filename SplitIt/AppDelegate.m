//
//  AppDelegate.m
//  SplitIt
//
//  Created by ERIC ELMOZNINO on 2015-07-08.
//  Copyright (c) 2015 Eric Elmoznino. All rights reserved.
//

#import "AppDelegate.h"
#import "EEGroupsViewController.h"
#import "EEGroupStore.h"
#import "EEPeopleViewController.h"
#import "EEPurchasesViewController.h"
#import "EESplitItViewController.h"
#import "EEMoreViewController.h"
#import "iRate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    EEGroupsViewController *gvc = [[EEGroupsViewController alloc] init];
    
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:gvc];
    nc.navigationBar.translucent = NO;
    
    nc.restorationIdentifier = NSStringFromClass([nc class]);
    
    self.window.rootViewController = nc;
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    return YES;
}

+ (void)initialize
{
    //Configure iRate
    [iRate sharedInstance].applicationName = @"SplitIT";
    [iRate sharedInstance].messageTitle = @"Enjoying SplitIT?";
    [iRate sharedInstance].message = @"Take a few seconds to rate us!";
    [iRate sharedInstance].cancelButtonLabel = @"No Thanks";
    [iRate sharedInstance].rateButtonLabel = @"Rate It Now";
    [iRate sharedInstance].remindButtonLabel = @"Remind Me Later";
    [iRate sharedInstance].useUIAlertControllerIfAvailable = YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    BOOL success = [[EEGroupStore sharedStore] saveChanges];
    if (success) {
        NSLog(@"Saved all groups successfully");
    }
    else {
        NSLog(@"Could not save any groups");
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
