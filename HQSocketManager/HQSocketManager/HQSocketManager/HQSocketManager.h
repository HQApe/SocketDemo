//
//  HQSocketManager.h
//  HQSocketManager
//
//  Created by zhq-t100 on 17/5/23.
//  Copyright © 2017年 Dinpay. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, SocketConnectStatus) {
    SocketConnectStatusUnConnected       = 0<<0,//未连接状态
    SocketConnectStatusConnected         = 1<<0,//连接状态
    SocketConnectStatusDisconnectByUser  = 2<<0,//主动断开连接
    SocketConnectStatusUnknow            = 3<<0 //未知
};

@class HQSocketManager;

@protocol HQSocketManagerDelegate <NSObject>

@optional
- (void)hq_socketManager:(HQSocketManager *)manager didReciveMessageDate:(NSData *)messageDate;

@end


@interface HQSocketManager : NSObject

//socket连接状态
@property (nonatomic, assign) SocketConnectStatus connectStatus;

/** 长连接单例 */
+ (instancetype)shareManager;

/** 添加代理 */
- (void)addDelegate:(id<HQSocketManagerDelegate>)delegate;

/** 移除代理 */
- (void)removeDelegate:(id<HQSocketManagerDelegate>)delegate;

/** 发送心跳包 */
- (void)sendBeat;

/** 连接服务器端口 */
- (void)connectServerHost:(NSString *)host port:(uint16_t)port;

/** 主动断开连接 */
- (void)executeDisconnectServer;

/** 发送消息 */
- (void)sendMessage:(NSString *)message timeOut:(NSUInteger)timeOut tag:(long)tag;


@end
