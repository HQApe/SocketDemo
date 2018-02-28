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
 * 数据交互的编解码实现类。
 */
@interface CharsetHelper : NSObject

/*!
 * 将byte数组按UTF-8编码组织成字符串并返回.
 *
 * @param data
 * @return 成功解码完成则返回字符串，否则返回nil
 */
+ (NSString *) getString:(NSData *)data;

/*!
 *  将字符串按UTF-8编码成byte数组。
 *
 *  @param str 字符串
 *
 *  @return 编码后的byte数组结果
 */
+ (NSData *) getBytesWithString:(NSString *)str;

@end
