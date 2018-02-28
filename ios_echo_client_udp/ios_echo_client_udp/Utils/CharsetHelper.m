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

#import "CharsetHelper.h"

@implementation CharsetHelper

+ (NSString *) getString:(NSData *)data
{
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

+ (NSData *) getBytesWithString:(NSString *)str
{
    return [str dataUsingEncoding:NSUTF8StringEncoding];
}

@end
