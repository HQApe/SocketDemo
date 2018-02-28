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

#import "ViewController.h"
#import "LocalUDPSocketProvider.h"
#import "LocalUDPDataSender.h"
#import "CharsetHelper.h"
#import "UDPUtils.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 初始化socket
    [[LocalUDPSocketProvider sharedInstance] initialLocalUDPSocket];
    
    // 注意：执行延迟的单位是秒哦
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(doSend) userInfo:nil repeats:YES];
    [timer fire];
}

- (void)doSend
{
    NSString *toServer = [NSString stringWithFormat:@"Hi，我是iOS客户端，我的时间戳 %li",[UDPUtils getTimeStampWithMillisecond_l]];
    [[LocalUDPDataSender sharedInstance] send:[CharsetHelper getBytesWithString:toServer]];
}

@end
