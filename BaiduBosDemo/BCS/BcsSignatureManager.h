//
//  BcsSignatureManager.h
//  JianBao
//
//  Created by xunyanan on 1/18/16.
//  Copyright © 2016 xunyanan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BCS.h"


@interface BcsSignatureManager : NSObject

+ (NSString *)signaturedURL:(NSString *)method object:(NSString *)object;

+ (NSMutableURLRequest *)signaturedHeader:(NSMutableURLRequest *)request object:(NSString *)object queryString:(NSString *)queryString;

+ (NSMutableURLRequest *)signaturedImageHeader:(NSMutableURLRequest *)request object:(NSString *)object queryString:(NSString *)queryString;

+ (NSString *)bcsURLWithObject:(NSString *)object;
+ (NSString *)bcsImagteURLWithObject:(NSString *)object;
@end
