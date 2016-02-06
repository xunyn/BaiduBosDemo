//
//  DeviceUtil.m
//  BaiduBosDemo
//
//  Created by xunyanan on 2/6/16.
//  Copyright © 2016 xunyanan. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "DeviceUtil.h"


@implementation DeviceUtil


+ (BOOL) isBelowTargetOSVersion:(NSInteger)targetBigVersionNum targetSmallVersionNum:(NSInteger)targetSmallVersionNum
{
    NSString *systemVersion = [[UIDevice currentDevice] systemVersion];
    
    NSArray *systemVersionArray = [systemVersion componentsSeparatedByString:@"."];
    
    NSInteger systemBigVersion = [[systemVersionArray objectAtIndex:0]integerValue];
    
    if (systemBigVersion < targetBigVersionNum)
    {
        return YES;
    }
    
    NSInteger systemSmallVersion = [[systemVersionArray objectAtIndex:1]integerValue];
    
    if (systemSmallVersion < targetSmallVersionNum)
    {
        return YES;
    }
    
    return NO;
}
@end
