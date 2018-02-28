//  ----------------------------------------------------------------------
//  Copyright (C) 2016 即时通讯网（52im.net）- 即时通讯开发者社区.
//  All rights reserved.
//  Site URL:  http://www.52im.net
//
//  52im.net PROPRIETARY/CONFIDENTIAL. Use is subject to license terms.
//
//  You can contact author with jack.jiang@52im.net or jb2011@163.com.
//  ----------------------------------------------------------------------
//
//
//  Created by JackJiang on 16/06/22.
//  Copyright (c) 2016年 52im.net. All rights reserved.
//

#import "LocalUDPDataSender.h"
#import "CharsetHelper.h"
#import "GCDAsyncUdpSocket.h"
#import "LocalUDPSocketProvider.h"
#import "ConfigEntity.h"
#import "UDPUtils.h"
#import "CompletionDefine.h"

@implementation LocalUDPDataSender

// 本类的单例对象
static LocalUDPDataSender *instance = nil;

- (BOOL) send:(NSData *)dataWithBytes
{
    // 获得UDPSocket实例
    GCDAsyncUdpSocket *ds = [[LocalUDPSocketProvider sharedInstance] getLocalUDPSocket];
    // 确保发送数据开始前，已经进行connect的操作：如果Socket没有“连接”上服务端，尝试“连接”一次
    if(ds != nil && ![ds isConnected])
    {
        // 此次数据只在“连接”成功后发出，“连接”成功则会调用此回调block代码
        ConnectionCompletion observerBlock = ^(BOOL connectResult) {
            // 成功建立了UDP连接后就把包发出去
            if(connectResult)
                [UDPUtils sendImpl:ds withData:dataWithBytes];
            else
            {
            }
        };
        // 调置连接回调
        [[LocalUDPSocketProvider sharedInstance] setConnectionObserver:observerBlock];
        
        NSError *connectError = nil;
        BOOL connectResult = [[LocalUDPSocketProvider sharedInstance] tryConnectToHost:&connectError withSocket:ds completion:observerBlock];
        // 如果连接意图没有成功发出则返回错误码
        return connectResult;
    }
    else
    {
        return [UDPUtils sendImpl:ds withData:dataWithBytes];
    }
}

// 获取本类的单例。使用单例访问本类的所有资源是唯一的合法途径。
+ (LocalUDPDataSender *)sharedInstance
{
    if (instance == nil)
    {
        instance = [[super allocWithZone:NULL] init];
    }
    return instance;
}


@end
