//
//  HQSocketService.h
//  HQSocketServer
//
//  Created by zhq-t100 on 17/5/27.
//  Copyright © 2017年 Dinpay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HQSocketService : NSObject

+ (instancetype)shareManager;

- (void)startServiceWithPort:(uint16_t)port;

@end
