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

#import <Foundation/Foundation.h>
#import "GCDAsyncUdpSocket.h"

/*!
 * 一个本地UDP消息发送工具类。
 */
@interface UDPUtils : NSObject

/*!
 * 发送一条UDP消息。
 *
 * @param skt GCDAsyncUdpSocket对象引用
 * @param d 要发送的比特数组
 * @return true表示成功发出，否则表示发送失败
 * @see #send(DatagramSocket, DatagramPacket)
 */
+ (BOOL) sendImpl:(GCDAsyncUdpSocket *) skt withData:(NSData *)d;

/*!
 *  返回系统时间戳（单位：毫秒），浮点表示。
 *
 *  @return 形如：1414074342829.249023
 */
+ (NSTimeInterval) getTimeStampWithMillisecond;

/*!
 *  返回系统时间戳（单位：毫秒），long表示。
 *
 *  @return 形如：1414074342829
 */
+ (long) getTimeStampWithMillisecond_l;

@end
