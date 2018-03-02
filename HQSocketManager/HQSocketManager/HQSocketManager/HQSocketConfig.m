//
//  HQSocketConfig.m
//  HQSocketManager
//
//  Created by zhq-t100 on 2018/3/1.
//  Copyright © 2018年 Dinpay. All rights reserved.
//

#import "HQSocketConfig.h"

@implementation HQSocketConfig


static HQSocketConfig *_instance = nil;
+ (instancetype)defualtConfig
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[HQSocketConfig alloc] init];
    });
    return _instance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
        [_instance initializeConfig];
    });
    
    return _instance;
}

- (void)initializeConfig
{
    _host = @"192.168.1.1";
    _port = 8080;
    _reconnectCount = 10;
    _beatDuration = 5;
    _beatMissCount = 12;
}

@end
