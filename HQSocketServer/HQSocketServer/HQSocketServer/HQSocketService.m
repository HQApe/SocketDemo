//
//  HQSocketService.m
//  HQSocketServer
//
//  Created by zhq-t100 on 17/5/27.
//  Copyright © 2017年 Dinpay. All rights reserved.
//

#import "HQSocketService.h"
#import "GCDAsyncSocket.h"

@interface HQSocketService ()<GCDAsyncSocketDelegate>
{
    GCDAsyncSocket * _severSocket;
    GCDAsyncSocket *_clientSocket;
}

@property (strong, nonatomic) NSMutableArray *clientSockets;

@end

@implementation HQSocketService

static HQSocketService *_instance = nil;
+ (instancetype)shareManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[HQSocketService alloc] init];
    });
    return _instance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}

- (NSMutableArray *)clientSockets
{
    if (_clientSockets == nil) {
        _clientSockets = [NSMutableArray array];
    }
    return _clientSockets;
}



- (void)startServiceWithPort:(uint16_t)port
{
    _severSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    NSError *error = nil;
    BOOL result = [_severSocket acceptOnPort:port error:&error];
    if (!result) {
        NSLog(@"建立服务端绑定 %d 端口失败 === %@", port, error);
    }else{
        
    }
}

#pragma mark - AsyncSocketDelegate
//有客户端主动连接服务端成功回调
- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket
{
    //sock 服务端的socket
    //newSocket 客户端连接的socket
    NSLog(@"%@----%@",sock, newSocket);
    
    //1.保存连接的客户端socket(否则newSocket释放掉后链接会自动断开)
    [self.clientSockets addObject:newSocket];
    
    //连接成功服务端立即向客户端提供服务
    
    NSString *serviceContent = @"欢迎进入Socket测试系统请输入login登录\n";
    
    [newSocket writeData:[serviceContent dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:100];
    
    //CocoaAsyncSocket建立连接后开始读取数据
    [newSocket readDataWithTimeout:-1 tag:100];
}

//服务端接收到客户端数据的回调
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    
    NSString * content = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSLog(@"服务端接收到了：%@", content);
    
    //1.接受到用户数据
    NSString *str = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    
    NSInteger code = [str integerValue];
    NSString *responseString = nil;
    switch (code) {
        case 1:
            responseString = @"您的账户余额为0，请尽快充值\n";
            break;
        case 2:
            responseString = @"系统忙，请稍后重试\n";
            break;
        case 3:
            responseString = @"系统忙，暂时不能接受投诉建议\n";
            break;
        case 4:
            responseString = @"请上官网查看更多优惠\n";
            break;
        case 0:
            responseString = @"客服忙，谢谢!\n";
            break;
        default:
            break;
    }
    
    if ([str isEqualToString:@"beatID\n"]) { //与客户端协商好的心跳包数据
        responseString = @"beatID\n";
    }else if ([str isEqualToString:@"connect\n"]) {//登录成功认证
        responseString = @"connect\n";
    }else if ([str isEqualToString:@"login\n"]) {//登录成功认证
        
        NSMutableDictionary *reqData = [NSMutableDictionary dictionaryWithDictionary: @{
                                                                                        @"userInfo":@{
                                                                                                @"accountNo":@"001234",
                                                                                                @"userId":@"20170527009322456774",
                                                                                                @"headUrl":@"member/header_12434353545646.png",
                                                                                                @"token":@"DETYEFHFFH120093034343535462",
                                                                                                @"nickname":@"小明",
                                                                                                @"authToken":@"002",
                                                                                                @"mobileNo":@"15098098875",
                                                                                                @"verifyCode":@"669874",
                                                                                                @"versionNo":@"1.1.9",
                                                                                                @"systemType":@"iOS",
                                                                                                @"systemVersion":@"10.3.2",
                                                                                                @"clientId":@"343785498549859485408598593485476847684395784574",
                                                                                                @"languageCode":@"009",
                                                                                                @"content":@"几天是个好日子啊！几天是个好日子啊。"
                                                                                                }
                                                                                        
                                                                                        }];
        
        NSError *error = nil;
        NSData *jsonDate = [NSJSONSerialization dataWithJSONObject:reqData options:NSJSONWritingPrettyPrinted error:&error];
        if (error) {
            return;
        }
        responseString = [[NSString alloc] initWithData:jsonDate encoding:NSUTF8StringEncoding];
    }
    //处理请求 返回数据
    [sock writeData:[responseString dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
    //CocoaAsyncSocket每次读取完成后必须调用一次监听数据方法
    [sock readDataWithTimeout:-1 tag:0];
}

//服务端发送数据成功
- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    NSLog(@"服务器发送数据成功");
    
    [sock readDataWithTimeout:-1 tag:100];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    NSLog(@"===========失去连接=========");
}

@end
