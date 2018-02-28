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

#import "LocalUDPSocketProvider.h"
#import "GCDAsyncUdpSocket.h"
#import "ConfigEntity.h"
#import "CompletionDefine.h"


#pragma mark - 私有API

@interface LocalUDPSocketProvider ()

@property (nonatomic, retain) GCDAsyncUdpSocket *localUDPSocket;
@property (nonatomic, copy) ConnectionCompletion connectionCompletionOnce_;

@end


#pragma mark - 本类的代码实现

@implementation LocalUDPSocketProvider

// 本类的单例对象
static LocalUDPSocketProvider *instance = nil;

//@synthesize localUDPSocket;

+ (LocalUDPSocketProvider *)sharedInstance
{
    if (instance == nil)
        instance = [[super allocWithZone:NULL] init];
    return instance;
}

- (GCDAsyncUdpSocket *)initialLocalUDPSocket
{
    NSLog(@"【IMCORE】new GCDAsyncUdpSocket中...");
    
    // ** Setup our socket.
    // The socket will invoke our delegate methods using the usual delegate paradigm.
    // However, it will invoke the delegate methods on a specified GCD delegate dispatch queue.
    //
    // Now we can configure the delegate dispatch queues however we want.
    // We could simply use the main dispatch queue, so the delegate methods are invoked on the main thread.
    // Or we could use a dedicated dispatch queue, which could be helpful if we were doing a lot of processing.
    //
    // The best approach for your application will depend upon convenience, requirements and performance.
    //
    // For this simple example, we're just going to use the main thread.
    self.localUDPSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    // ** START udp socket
    // 本地绑定端口合法性检查
    int port = [ConfigEntity getLocalUdpSendAndListeningPort];
    if (port < 0 || port > 65535)
        port = 0;
    NSError *error = nil;
    // 绑定到指定端口（以便收发数据）
    if (![self.localUDPSocket bindToPort:port error:&error])
    {
        NSLog(@"【IMCORE】localUDPSocket创建时出错，原因是 bindToPort: %@", error);
        return nil;
    }
    // 开启收数据处理
    if (![self.localUDPSocket beginReceiving:&error])
    {
        NSLog(@"【IMCORE】localUDPSocket创建时出错，原因是 beginReceiving: %@", error);
        return nil;
    }
    
    NSLog(@"【IMCORE】localUDPSocket创建已成功完成.");
    
    return self.localUDPSocket;
}

- (BOOL)tryConnectToHost:(NSError **)errPtr withSocket:(GCDAsyncUdpSocket *)skt completion:(ConnectionCompletion)finish
{
    if([ConfigEntity getServerIp] == nil)
    {
        NSLog(@"【IMCORE】tryConnectToHost到目标主机%@:%d没有成功，ConfigEntity.server_ip==null!", [ConfigEntity getServerIp], [ConfigEntity getServerPort]);
        return NO;
    }
    
    NSError *connectError = nil;
    // 设置连接结果回调
    if(finish != nil)
       [self setConnectionCompletionOnce_:finish];
    // 开始连接
    [skt connectToHost:[ConfigEntity getServerIp] onPort:[ConfigEntity getServerPort] error:&connectError];
    if(connectError != nil)
    {
        NSLog(@"【IMCORE】localUDPSocket尝试发出连接到目标主机%@:%d的动作时出错了：%@.(此前isConnected?%d)", [ConfigEntity getServerIp], [ConfigEntity getServerPort], connectError, [skt isConnected]);
        return NO;
    }
    else
    {
        NSLog(@"【IMCORE】localUDPSocket尝试发出连接到目标主机%@:%d的动作成功了.(此前isConnected?%d)", [ConfigEntity getServerIp], [ConfigEntity getServerPort], [skt isConnected]);
        return YES;
    }
}

- (BOOL) isLocalUDPSocketReady
{
    return self.localUDPSocket != nil && ![self.localUDPSocket isClosed];
}

- (GCDAsyncUdpSocket *) getLocalUDPSocket
{
    return self.localUDPSocket;
}

- (void) setConnectionObserver:(ConnectionCompletion)connObserver
{
    self.connectionCompletionOnce_ = connObserver;
}


#pragma mark - GCDAsyncUdpSocketDelegate代码实现

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag
{
    NSLog(@"【UDP_SOCKET】tag为%li的NSData已成功发出.", tag);
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error
{
    NSLog(@"【UDP_SOCKET】tag为%li的NSData没有发送成功，原因是%@", tag, error);
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data
      fromAddress:(NSData *)address
withFilterContext:(id)filterContext
{
    NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (msg)
    {
        NSLog(@"【UDP_SOCKET】【NOTE】>>>>>> 收到服务端的消息： %@", msg);
    }
    else
    {
        NSString *host = nil;
        uint16_t port = 0;
        [GCDAsyncUdpSocket getHost:&host port:&port fromAddress:address];
        NSLog(@"【UDP_SOCKET】RECV: Unknown message from: %@:%hu", host, port);
    }
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didConnectToAddress:(NSData *)address
{
    NSLog(@"【UDP_SOCKET】成收到的了UDP的connect反馈, isCOnnected?%d", [sock isConnected]);
    // 连接结果回调
    if(self.connectionCompletionOnce_ != nil)
        self.connectionCompletionOnce_(YES);
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotConnect:(NSError *)error
{
    NSLog(@"【UDP_SOCKET】成收到的了UDP的connect反馈，但连接没有成功, isCOnnected?%d", [sock isConnected]);
    // 连接结果回调
    if(self.connectionCompletionOnce_ != nil)
        self.connectionCompletionOnce_(NO);
}

@end
