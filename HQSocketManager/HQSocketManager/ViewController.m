//
//  ViewController.m
//  HQSocketManager
//
//  Created by zhq-t100 on 17/5/23.
//  Copyright © 2017年 Dinpay. All rights reserved.
//
//$ nc -lk 12345 在终端开端口监听

#import "ViewController.h"
#import "HQSocketManager.h"

@interface ViewController ()<HQSocketManagerDelegate>

@property (strong, nonatomic) UITextField *messageTF;

@property (strong, nonatomic) UITextView *reciveTextContainer;

@property (strong, nonatomic) HQSocketManager *socket;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UITextField *messageTf = [[UITextField alloc] initWithFrame:CGRectMake(20, 100, 200, 30)];
    messageTf.layer.borderColor = [UIColor lightGrayColor].CGColor;
    messageTf.layer.borderWidth = 1.0;
    messageTf.layer.cornerRadius = 5;
    messageTf.layer.masksToBounds = YES;
    [self.view addSubview:messageTf];
    self.messageTF = messageTf;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(20, 160, 60, 30);
    [button setTitleColor:[UIColor purpleColor] forState:UIControlStateNormal];
    [button setTitle:@"发送" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(send:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:button];
    
    UIButton *clear = [UIButton buttonWithType:UIButtonTypeCustom];
    clear.frame = CGRectMake(120, 160, 60, 30);
    [clear setTitleColor:[UIColor purpleColor] forState:UIControlStateNormal];
    [clear setTitle:@"Clear" forState:UIControlStateNormal];
    [clear addTarget:self action:@selector(clear:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:clear];
    
    
    UITextView *reciveTextContainer = [[UITextView alloc] initWithFrame:CGRectMake(10, 200, 355, 300)];
    reciveTextContainer.editable = NO;
    reciveTextContainer.backgroundColor = [UIColor lightGrayColor];
    reciveTextContainer.textColor = [UIColor cyanColor];
    [self.view addSubview:reciveTextContainer];
    self.reciveTextContainer = reciveTextContainer;
    
    _socket = [HQSocketManager shareManager];
    [_socket addDelegate:self];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self.view endEditing:YES];
}

- (void)send:(UIButton *)button
{
    [[HQSocketManager shareManager] sendMessage:self.messageTF.text timeOut:-1 tag:99];
    
    self.messageTF.text = nil;
}

- (void)clear:(UIButton *)button
{
    [self.reciveTextContainer setText:nil];
}

- (void)hq_socketManager:(HQSocketManager *)manager didReciveMessageDate:(NSData *)messageDate
{
    //转为明文消息
    NSString *secretStr  = [[NSString alloc] initWithData:messageDate encoding:NSUTF8StringEncoding];
    //    //去除'\n'
//    secretStr = [secretStr stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    [self.reciveTextContainer insertText:secretStr];
    
#warning 此处可以先根据与后台的约定来解析一个消息模型，用于接收信息后，做相应的处理。
    
    //验证连接消息
    if ([secretStr isEqualToString:@"connect\n"]){
    //验证消息
    }else if ([secretStr isEqualToString:@"loginSucceed\n"]){
        
        //普通消息类型
    }else if ([secretStr isEqualToString:@""]) {
        
        //系统消息
    }else if ([secretStr isEqualToString:@""]){
        
        //发送普通消息回执
    }else if ([secretStr isEqualToString:@""]){
        
        //发送普通消息失败回执
    }else if ([secretStr isEqualToString:@""]){
        
        // 未知消息类型
    }else{
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
