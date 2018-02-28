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

/*!
 * 数据发送处理实用类。
 */
@interface LocalUDPDataSender : NSObject


/// 获取本类的单例。使用单例访问本类的所有资源是唯一的合法途径。
+ (LocalUDPDataSender *)sharedInstance;

/*
 * 发送数据到服务端.
 * <p>
 * 本方法封装了一些异常处理等代码，数据发送最终实现代码是用 UDPUtils 的 sendImpl: 方法去实施的。
 *
 * @param dataWithBytes byte数组
 * @return 数据是否成功发出，YES表示成功，否则表示失败
 */
- (BOOL) send:(NSData *)dataWithBytes;


@end
