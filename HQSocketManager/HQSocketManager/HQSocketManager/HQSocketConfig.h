//
//  HQSocketConfig.h
//  HQSocketManager
//
//  Created by zhq-t100 on 2018/3/1.
//  Copyright © 2018年 Dinpay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HQSocketConfig : NSObject

@property (copy, nonatomic) NSString *host;
@property (assign, nonatomic) uint16_t port;
@property (assign, nonatomic) NSUInteger reconnectCount;
@property (assign, nonatomic) NSTimeInterval beatDuration;
@property (assign, nonatomic) NSUInteger beatMissCount;

@end
