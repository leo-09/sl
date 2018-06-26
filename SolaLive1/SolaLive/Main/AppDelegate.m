//
//  AppDelegate.m
//  PhoneLive
//
//  Created by liyy on 2018/2/1.
//  Copyright © 2018年 easydarwin. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // 默认分辨率
    NSString *res = [[NSUserDefaults standardUserDefaults] objectForKey:resolition];
    if (!res) {
        [[NSUserDefaults standardUserDefaults] setObject:@"288*352" forKey:resolition];
    }
    
    // 默认码率
    NSString *rate = [[NSUserDefaults standardUserDefaults] objectForKey:Rate];
    if (!rate) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d", 800 * 1000] forKey:Rate];
    }
    
    // 默认后摄像头
    NSString *camera = [[NSUserDefaults standardUserDefaults] objectForKey:FBCamera];
    if (!camera) {
        [[NSUserDefaults standardUserDefaults] setObject:@"后摄像头" forKey:FBCamera];
    }
    
    // 默认横屏
    NSString *orientation = [[NSUserDefaults standardUserDefaults] objectForKey:Orientation];
    if (!orientation) {
        [[NSUserDefaults standardUserDefaults] setObject:@"横屏" forKey:Orientation];
    }
    
    // 仅推送音频(默认是否)
    NSString *audio = [[NSUserDefaults standardUserDefaults] objectForKey:OnlyAudio];
    if (!audio) {
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:OnlyAudio];
    }
    
    // 本地存储
    NSString *save = [[NSUserDefaults standardUserDefaults] objectForKey:SaveVideo];
    if (!save) {
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:SaveVideo];
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
