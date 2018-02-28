//
//  AppDelegate.m
//  HQSocketManager
//
//  Created by zhq-t100 on 17/5/23.
//  Copyright © 2017年 Dinpay. All rights reserved.
//

#import "AppDelegate.h"
#import "HQSocketManager.h"

@interface AppDelegate ()<HQSocketManagerDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [[HQSocketManager shareManager] connectServerHost:@"192.168.21.201" port:9999];
    [[HQSocketManager shareManager] addDelegate:self];
    return YES;
}

- (void)hq_socketManager:(HQSocketManager *)manager didReciveMessageDate:(NSData *)messageDate
{
    //转为明文消息
    NSString *secretStr  = [[NSString alloc] initWithData:messageDate encoding:NSUTF8StringEncoding];
    //    //去除'\n'
    //    secretStr = [secretStr stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    NSLog(@"%@", secretStr);
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
