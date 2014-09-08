//
//  ContantsObjC.m
//  NUS SOC Print
//
//  Created by Yeo Kheng Meng on 8/9/14.
//  Copyright (c) 2014 Yeo Kheng Meng. All rights reserved.
//


#import "ConstantsObjC.h"

@implementation ConstantsObjC

+(NSString *) getBuildDate {
    NSString * date = [NSString stringWithUTF8String:__DATE__];
    return date;
}

@end