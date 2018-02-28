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
 * 本接口中定义了一些用于回调的block类型。
 */
@interface CompletionDefine : NSObject

/*!
 *  @Author Jack Jiang, 14-10-29 19:10:41
 *
 *  UDP Socket连接结果回调。
 *
 *  @param connectRsult YES表示连接成功，NO否则表示连接失败
 */
typedef void (^ConnectionCompletion)(BOOL connectRsult);

@end
