//
//  ContantsObjC.m
//  NUS SOC Print
//
//  Created by Yeo Kheng Meng on 8/9/14.
//  Copyright (c) 2014 Yeo Kheng Meng. All rights reserved.
//


#import "ConstantsObjC.h"
#import "Reachability.h"

#define TAG @"ConstantsObjC"

@implementation ConstantsObjC

+(NSString *) getBuildDate
{
    NSString * date = [NSString stringWithUTF8String:__DATE__];
    return date;
}

+(bool) isOn3G
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
    
    NetworkStatus status = [reachability currentReachabilityStatus];
    
    NSLog(@"%@ %d", TAG, (int) status);
    
    if(status == ReachableViaWWAN){
        return true;
    } else {
        return false;
    }

}

@end