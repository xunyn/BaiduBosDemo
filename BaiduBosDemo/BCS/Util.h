//
//  Util.h
//  DogDogHome
//
//  Created by xun yanan on 14-4-22.
//  Copyright (c) 2014年 xun yanan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Util : NSObject

+ (NSString *)md5:(NSString *)str;
+ (NSString*)md5WithData:(NSData *)data;

+ (NSString *)normalizePropertyAndValue:(id)obj skipKeys:(NSArray *)skipArr;

+ (NSString *)sha1Base64:(NSString *)key content:(NSString *)content;

+ (NSString *)urlEncode:(NSString *)str;
+ (NSString *)urlEncodeExceptSlash:(NSString *)str;
+ (NSString *)sha256Base64:(NSString *)key content:(NSString *)content;
+ (NSString *)sha256:(NSString *)key content:(NSString *)content;
+ (NSString *)preettyTime:(long long)ts;

+ (CGSize)targetImageSize:(NSInteger)width height:(NSInteger)height;
+ (NSData *)compressImage:(UIImage *)image;
@end
