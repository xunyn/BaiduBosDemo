//
//  DeviceUtil.h
//  BaiduBosDemo
//
//  Created by xunyanan on 2/6/16.
//  Copyright © 2016 xunyanan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DeviceUtil : NSObject

+ (BOOL) isBelowTargetOSVersion:(NSInteger)targetBigVersionNum targetSmallVersionNum:(NSInteger)targetSmallVersionNum;


@end
