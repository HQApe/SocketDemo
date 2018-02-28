//
//  ViewController.m
//  HQSocketServer
//
//  Created by zhq-t100 on 17/5/27.
//  Copyright © 2017年 Dinpay. All rights reserved.
//

#import "ViewController.h"
#import "HQSocketService.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    
    [self startService];
}

- (void)startService
{
    HQSocketService *socketService = [HQSocketService shareManager];
    
    [socketService startServiceWithPort:2234];
    
    [[NSRunLoop mainRunLoop]run];//目的让服务器不停止
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


@end
