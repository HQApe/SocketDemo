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

#import "UDPUtils.h"
#import "GCDAsyncUdpSocket.h"

@implementation UDPUtils

+ (BOOL) sendImpl:(GCDAsyncUdpSocket *) skt withData:(NSData *)d
{
    BOOL sendSucess = YES;
    if(skt != nil && d != nil)
    {
        if([skt isConnected])
            [skt sendData:d withTimeout:-1 tag:0];
    }
    else
        NSLog(@"【IMCORE】在sendImpl()UDP数据报时没有成功执行，原因是：skt==null || d == null!");
    
    return sendSucess;
}


+ (NSTimeInterval) getTimeStampWithMillisecond
{
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval a = [dat timeIntervalSince1970] * 1000;
    return a;
}

+ (long) getTimeStampWithMillisecond_l
{
    return [[NSNumber numberWithDouble:[UDPUtils getTimeStampWithMillisecond]] longValue];
}

@end
