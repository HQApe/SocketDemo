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
#import "CompletionDefine.h"

/*!
 * 本地 UDP Socket 实例封装实用类。
 * <p>
 * 本类提供存取本地UDP Socket通信对象引用的方便方法，封装了
 * Socket有效性判断以及异常处理等，以便确保调用者通过方法 {@link #getLocalUDPSocket()}
 * 拿到的Socket对象是健康有效的。
 * <p>
 * 依据作者对MobileIMSDK API的设计理念，本类将以单例的形式提供给调用者使用。
 */
@interface LocalUDPSocketProvider : NSObject <GCDAsyncUdpSocketDelegate>

/// 获取本类的单例。使用单例访问本类的所有资源是唯一的合法途径。
+ (LocalUDPSocketProvider *)sharedInstance;

/*!
 * 重置并新建一个全新的Socket对象。
 *
 * @return 新建的全新Socket对象引用
 */
- (GCDAsyncUdpSocket *)initialLocalUDPSocket;

/*!
 * 获得本地UDPSocket的实例引用.
 * <p>
 * 本方法内封装了Socket有效性判断以及异常处理等，以便确保调用者通过本方法
 * 拿到的Socket对象是健康有效的。
 *
 * @return 如果该实例正常则返回它的引用，否则返回null
 */
- (GCDAsyncUdpSocket *) getLocalUDPSocket;

/*!
 * 设置UDP Socket连接结果事件观察者.
 * 注意：此回调一旦设置后只会被调用一次，即无论是被"- (void)udpSocket:didConnectToAddress:"还是“- (void)udpSocket:didNotConnect:”调用，都将在调用完成后被置nil.
 *
 * @param networkConnectionLostObserver
 */
- (void) setConnectionObserver:(ConnectionCompletion)connObserver;

/*!
 *  @Author Jack Jiang, 14-10-27 17:10:47
 *
 *  尝试连接指定的socket.
 *  <p>
 *  UDP是无连接的，此处的连接何解？此处的连接仅是逻辑意义上的操作，实施方法实际动作是进行状态设置等
 *  操作，而带来的方便是每次send数据时就无需再指明主机和端口了.
 *  <p>
 *  本框架中，在发送数据前，请首先确保isConnected == YES。
 *  <p>
 *  一个注意点是：此connect实际上是异步的，真正意义上能连接上目标主机需等到真正的IMAP包到来。但此处
 *  无需等到异步返回，只需保证connect从形式上成功即可。
 *
 *  @param errPtr 本参数为Error的地址，本方法执行返回时如有错误产生则不为空，否则为nil
 *  @param finish 连接结果回调
 *
 *  @return
 *  @see GCDAsyncUdpSocket, ConnectionCompletion
 */
- (BOOL)tryConnectToHost:(NSError **)errPtr withSocket:(GCDAsyncUdpSocket *)skt completion:(ConnectionCompletion)finish;

/*!
 * 本类中的Socket对象是否是健康的。
 *
 * @return true表示是健康的，否则不是
 */
- (BOOL) isLocalUDPSocketReady;


@end
