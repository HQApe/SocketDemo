//
//  HQSocketManager.m
//  HQSocketManager
//
//  Created by zhq-t100 on 17/5/23.
//  Copyright © 2017年 Dinpay. All rights reserved.
//

#import "HQSocketManager.h"
#import "GCDAsyncSocket.h"

#define TCP_beatBody  @"beatID\n"    //心跳标识
#define TCP_AutoConnectCount  5    //自动重连次数，5次重连后默认没有网络就断开了
#define TCP_BeatDuration  5        //心跳频率
#define TCP_MaxBeatMissCount   5   //最大心跳丢失数

//自动重连次数
NSInteger autoConnectCount = TCP_AutoConnectCount;

@interface HQSocketManager ()<GCDAsyncSocketDelegate>

//连接对象
@property (strong , nonatomic) GCDAsyncSocket *connectSocket;
//代理集合
@property (strong, nonatomic) NSMutableSet *delegates;
//心跳定时器
@property (nonatomic, strong) dispatch_source_t beatTimer;
//发送心跳次数
@property (nonatomic, assign) NSInteger senBeatCount;

@property (nonatomic, copy) NSString *host;

@property (nonatomic, assign) uint16_t port;

@property (strong, nonatomic) NSMutableData *reciveData;

@property (copy, nonatomic) ConnectionCompletion connectionCompletion;

@end


@implementation HQSocketManager

static HQSocketManager *_instance = nil;
+ (instancetype)shareManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[HQSocketManager alloc] init];
    });
    return _instance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
        [_instance initializeConnection];
    });
    
    return _instance;
}

- (NSMutableSet *)delegates
{
    if (!_delegates) {
        _delegates = [[NSMutableSet alloc] init];
    }
    return _delegates;
}

- (NSMutableData *)reciveData
{
    if (!_reciveData) {
        _reciveData = [NSMutableData data];
    }
    return _reciveData;
}


- (dispatch_source_t)beatTimer
{
    if (!_beatTimer) {
        _beatTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
        dispatch_source_set_timer(_beatTimer, DISPATCH_TIME_NOW, TCP_BeatDuration * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
        dispatch_source_set_event_handler(_beatTimer, ^{
            _senBeatCount ++ ;
            //超过最大心跳丢失数, 置为未连接状态
            if (_senBeatCount>TCP_MaxBeatMissCount) {
                _connectStatus = SocketConnectStatusUnConnected;
            }else{
                [_connectSocket writeData:[TCP_beatBody dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:9999];
                NSLog(@"【INFO】Socket TCP发送了心跳 》》 IP: %@ 端口：%d", self.host, self.port);
            }
        });
    }
    return _beatTimer;
}

#pragma mark - initialize
- (void)initializeConnection
{
    //将handler设置成接收TCP信息的代理
    _connectSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    //设置默认关闭读取
    [_connectSocket setAutoDisconnectOnClosedReadStream:NO];
    //默认状态未连接
    _connectStatus = SocketConnectStatusUnknow;
}


#pragma mark - 连接服务器端口
/** 连接服务器端口 */
- (void)connectServerHost:(NSString *)host port:(uint16_t)port connctionCompletion:(ConnectionCompletion)complition
{
    _host = host;
    _port = port;
    NSError *error = nil;
    if (complition) {
        [self setConnectionCompletion:complition];
    }
    
    [_connectSocket connectToHost:host onPort:port error:&error];
    if (error.localizedDescription) {
        NSLog(@"【INFO】Socket TCP连接服务器失败 \n失败原因：%@ \n\n 》》》》 IP: %@ 端口：%d", error, host, port);
    }
}

/** 添加代理 */
- (void)addDelegate:(id<HQSocketManagerDelegate>)delegate
{
    [self.delegates addObject:delegate];
}

/** 移除代理 */
- (void)removeDelegate:(id<HQSocketManagerDelegate>)delegate
{
    [self.delegates removeObject:delegate];
}

/** 主动断开连接 */
- (void)executeDisconnectServer
{
    //更新sokect连接状态
    _connectStatus = SocketConnectStatusDisconnectByUser;
    [self disconnect];
}

/** 发送消息 */
- (void)sendMessage:(NSString *)message timeOut:(NSUInteger)timeOut tag:(long)tag
{
    //将模型转换为json字符串
    NSString *messageJson = message;
    //以"\n"分割此条消息 , 支持的分割方式有很多种例如\r\n、\r、\n、空字符串,不支持自定义分隔符,具体的需要和服务器协商分包方式 , 这里以\n分包
    /*
     如不进行分包,那么服务器如果在短时间里收到多条消息 , 那么就会出现粘包的现象 , 无法识别哪些数据为单独的一条消息 .
     对于普通文本消息来讲 , 这里的处理已经基本上足够 . 但是如果是图片进行了分割发送,就会形成多个包 , 那么这里的做法就显得并不健全,严谨来讲,应该设置包头,把该条消息的外信息放置于包头中,例如图片信息,该包长度等,服务器收到后,进行相应的分包,拼接处理.
     */
    messageJson           = [messageJson stringByAppendingString:@"\n"];
    NSData  *messageData  = [messageJson dataUsingEncoding:NSUTF8StringEncoding];
    
    if (!_connectSocket.isConnected) {
        [self reconnectServerCompletion:^(BOOL connectRsult) {
            if (connectRsult) {
                //写入数据
                [_connectSocket writeData:messageData withTimeout:timeOut tag:tag];
            }
        }];
    }
    //写入数据
    [_connectSocket writeData:messageData withTimeout:timeOut tag:tag];
}



#pragma mark - Private
- (void)beginReadDataTimeOut:(long)timeOut tag:(long)tag
{
    /** [GCDAsyncSocket LFData] 分包读取协议
     可以是："\x0D"、"\x0A"、"\x0D\x0A"、"" 、自定义
     */
    [_connectSocket readDataToData:[GCDAsyncSocket LFData] withTimeout:timeOut maxLength:0 tag:tag];
}

- (void)reconnectServerCompletion:(ConnectionCompletion)complition
{
    [self connectServerHost:_host port:_port connctionCompletion:complition];
}

- (void)sendBeat
{
    //已经连接
    _connectStatus = SocketConnectStatusConnected;
    //定时发送心跳开启
    dispatch_resume(self.beatTimer);//再次发送心跳包的时候会奔溃，暂未找到原因
}

- (void)serverInterruption
{
    //更新soceket连接状态
    _connectStatus = SocketConnectStatusUnConnected;
    [self disconnect];
}

- (void)disconnect
{
    //断开连接
    [_connectSocket disconnect];
    //关闭心跳定时器
    dispatch_source_cancel(self.beatTimer);
    //置为初始化
    _senBeatCount = 0;
}


#pragma mark - GCDAsyncSocketDelegate

 /*
 #pragma mark - TCP连接成功建立 ,配置SSL 相当于https 保证安全性 , 这里是单向验证服务器地址 , 仅仅需要验证服务器的IP即可
 - (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
 {
 // 配置 SSL/TLS 设置信息
 NSMutableDictionary *settings = [NSMutableDictionary dictionaryWithCapacity:3];
 //允许自签名证书手动验证
 [settings setObject:@YES forKey:GCDAsyncSocketManuallyEvaluateTrust];
 //GCDAsyncSocketSSLPeerName
 [settings setObject:@"此处填服务器IP地址" forKey:GCDAsyncSocketSSLPeerName];
 [_chatSocket startTLS:settings];
 }

 #pragma mark - TCP成功获取安全验证
 - (void)socketDidSecure:(GCDAsyncSocket *)sock
 {
 //登录服务器
 ChatModel *loginModel  = [[ChatModel alloc]init];
 //此版本号需和后台协商 , 便于后台进行版本控制
 loginModel.versionCode = TCP_VersionCode;
 //当前用户ID
 loginModel.fromUserID  = [Account shareInstance].myUserID;
 //设备类型
 loginModel.deviceType  = DeviceType;
 //发送登录验证
 [self sendMessage:loginModel timeOut:-1 tag:0];
 //开启读入流
 [self beginReadDataTimeOut:-1 tag:0];
 }
 */

#pragma mark - TCP已经断开连接、失败
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    NSLog(@"【INFO】Socket TCP连接服务器失败 \n失败原因：%@ \n\n 》》》》IP：%@ 端口：%d",err, self.host, self.port);
    //如果是主动断开连接
    if (_connectStatus == SocketConnectStatusDisconnectByUser) return;
    //置为未连接状态
    _connectStatus  = SocketConnectStatusUnConnected;
    //自动重连
    if (autoConnectCount) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self reconnectServerCompletion:nil];
            NSLog(@"【INFO】Socket TCP第%ld次重连 》》IP：%@ 端口：%d",(long)autoConnectCount, self.host, self.port);
            autoConnectCount -- ;
        });
        
    }else{
        if (self.connectionCompletion) {
            self.connectionCompletion(NO);
            _connectionCompletion = nil;
        }
        [self disconnect];
        NSLog(@"【INFO】Socket TCP重连次数已用完 》》IP：%@ 端口：%d", self.host, self.port);//再继续重连
    }
}

#pragma mark - TCP连接成功建立 ,配置SSL 相当于https 保证安全性 , 这里是单向验证服务器地址 , 仅仅需要验证服务器的IP即可
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    NSLog(@"【INFO】 Socket TCP连接服务器成功 》》 IP: %@ 端口：%d", host, port);
    if (self.connectionCompletion) {
        self.connectionCompletion(YES);
        _connectionCompletion = nil;
    }
    
    autoConnectCount = 5;
    //开始接受服务器数据
    [self beginReadDataTimeOut:-1 tag:0];
    //开始发送心跳包
    [self sendBeat];
}


#pragma mark - 写入数据成功 , 重新开启允许读取数据
- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    NSLog(@"【INFO】Socket TCP数据发送成功 》》IP：%@ 端口：%d", sock.connectedHost, sock.connectedPort);
    //等待接受服务器数据
    [self beginReadDataTimeOut:-1 tag:0];
}

#pragma mark - 接收到数据
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSLog(@"【INFO】Socket TCP数据接收成功 》》IP：%@ 端口：%d", sock.connectedHost, sock.connectedPort);
    /**
     1.数据粘包处理；
     2.解析协议头；
     3.数据完整性验证；
     4.数据处理
     5.数据解析、分发
     */
    [self.reciveData appendData:data];
    //等待接受服务器数据
    [self beginReadDataTimeOut:-1 tag:0];
    
    //解析消息
    NSString *secretStr  = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if ([secretStr isEqualToString:TCP_beatBody]) {
        //重置心跳包丢失次数为0
        _senBeatCount = 0;
        NSLog(@"INFO】Socket TCP接收到心跳 》》IP：%@ 端口：%d", sock.connectedHost, sock.connectedPort);
        return;
    }
    //消息分发
    for (id delegate in self.delegates) {
        if ([delegate respondsToSelector:@selector(hq_socketManager:didReciveMessageDate:)]) {
            [delegate hq_socketManager:self didReciveMessageDate:data];
        }
    }
    
}

#pragma mark - 发送消息超时
- (NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutWriteWithTag:(long)tag elapsed:(NSTimeInterval)elapsed bytesDone:(NSUInteger)length
{
    //此处进行数据库更新消息处理
    
//    //发送超时消息分发
//    for (id<ChatHandlerDelegate> delegate in self.delegates) {
//        if ([delegate respondsToSelector:@selector(sendMessageTimeOutWithTag:)]) {
//            [delegate sendMessageTimeOutWithTag:tag];
//        }
//    }
    return -1;
}

#pragma mark - 网络监听
//有网络的时候，主动请求连接


@end
