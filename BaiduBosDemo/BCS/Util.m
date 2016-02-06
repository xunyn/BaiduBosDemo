//
//  Util.m
//  DogDogHome
//
//  Created by xun yanan on 14-4-22.
//  Copyright (c) 2014年 xun yanan. All rights reserved.
//

#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>
#import <objc/runtime.h>
#import "Util.h"
#import "DeviceUtil.h"

#define IMAGE_WIDTH 1280
#define IMAGE_HEIGHT 1440
#define IMAGE_QUALITY 0.6
#define IMAGE_FILE_SZIE 512*1024

@implementation Util

+ (NSString *)md5:(NSString *)str
{
    if (str == nil) {
        return @"";
    }
    const char *cStr = [str UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result); // This is the md5 call
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ]; 
}

+ (NSString*)md5WithData:(NSData *)data
{
    unsigned char result[16];
    CC_MD5( data.bytes, (CC_LONG)data.length, result ); // This is the md5 call
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];  
}



+ (NSString *)normalizePropertyAndValue:(id) obj skipKeys:(NSArray *)skipArr{
    Class class = [obj class];
    NSMutableArray *propertyNames = [[NSMutableArray alloc] init];
    NSMutableString *str= [[NSMutableString alloc] init];
    unsigned int propertyCount = 0;
    objc_property_t *properties = class_copyPropertyList(class, &propertyCount);
    
    for (unsigned int i = 0; i < propertyCount; i++) {
        objc_property_t property = properties[i];
        const char * name = property_getName(property);
        NSString *nameStr = [NSString stringWithCString:name encoding:NSASCIIStringEncoding];
        BOOL isSkiped = NO;
        for (NSString *key in skipArr) {
            if ([nameStr isEqualToString:key]) {
                isSkiped = YES;
                break;
            }
        }
        if (isSkiped) {
            isSkiped = NO;
            continue;
        }else{
        id value = [obj valueForKey:nameStr];
        if (value) {
            NSString *valueStr;
            if ([value isKindOfClass:[NSString class]]) {
                valueStr = (NSString *)value;
            }else if([value isKindOfClass:[NSUUID class]]){
                valueStr = [value UUIDString];
            }
            if (i == 0) {
                [str appendString:[NSString stringWithFormat:@"%@=%@",nameStr,valueStr]];
            }else{
                [str appendString:[NSString stringWithFormat:@"&%@=%@",nameStr,valueStr]];
            }
            [propertyNames addObject:[NSString stringWithUTF8String:name]];
            }
        }
  
    }
    free(properties);
    return str;
}

+ (NSString *)sha1Base64:(NSString *)key content:(NSString *)content{
    const char *cKey = [key cStringUsingEncoding:NSUTF8StringEncoding];
    const char *cData = [content cStringUsingEncoding:NSUTF8StringEncoding];
    unsigned char cHMAC[CC_SHA1_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA1, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    NSData *HMAC = [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];
    NSString *signature = nil;
    if([DeviceUtil isBelowTargetOSVersion:7 targetSmallVersionNum:0]){
        signature = [HMAC base64Encoding];
    }else{
        signature = [HMAC base64EncodedStringWithOptions:0];
    }
    
    NSLog(@"HMAC %@", [HMAC description]);
    NSLog(@"Signature %@", signature);
    return signature;
}
+ (NSString *)sha256:(NSString *)key content:(NSString *)data{
    const char *cKey = [key cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cData = [data cStringUsingEncoding:NSASCIIStringEncoding];
    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    NSData *hash = [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];

    NSString *hashedtmp1 = [[hash description] stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *hashedtmp2 = [hashedtmp1 stringByReplacingOccurrencesOfString:@"<" withString:@""];
    NSString *hashedStr = [hashedtmp2 stringByReplacingOccurrencesOfString:@">" withString:@""];
    
    //493281a58df53a6c8c7982ded9aa4f19715d5fa888be646290753ef7348ddbf0
    //d9f35aaba8a5f3efa654851917114b6f22cd831116fd7d8431e08af22dcff24c
    return hashedStr;
}
+ (NSString *)sha256Base64:(NSString *)key content:(NSString *)content{
    const char *cKey = [key cStringUsingEncoding:NSUTF8StringEncoding];
    const char *cData = [content cStringUsingEncoding:NSUTF8StringEncoding];
    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    NSData *hash = [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];
    NSString *signature = nil;
    if([DeviceUtil isBelowTargetOSVersion:7 targetSmallVersionNum:0]){
        signature = [hash base64Encoding];
    }else{
        signature = [hash base64EncodedStringWithOptions:0];
    }
    
    NSLog(@"HMAC %@", [hash description]);
    NSLog(@"Signature %@", signature);
    return signature;
}

+ (NSString*)base64forData:(NSData*)theData {
    const uint8_t* input = (const uint8_t*)[theData bytes];
    NSInteger length = [theData length];
    
    static char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
    
    NSMutableData* data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    uint8_t* output = (uint8_t*)data.mutableBytes;
    
    NSInteger i;
    for (i=0; i < length; i += 3) {
        NSInteger value = 0;
        NSInteger j;
        for (j = i; j < (i + 3); j++) {
            value <<= 8;
            
            if (j < length) {  value |= (0xFF & input[j]);  }  }  NSInteger theIndex = (i / 3) * 4;  output[theIndex + 0] = table[(value >> 18) & 0x3F];
        output[theIndex + 1] = table[(value >> 12) & 0x3F];
        output[theIndex + 2] = (i + 1) < length ? table[(value >> 6) & 0x3F] : '=';
        output[theIndex + 3] = (i + 2) < length ? table[(value >> 0) & 0x3F] : '=';
    }
    
    return [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];

}

+ (NSString *)urlEncode:(NSString *)str{
    NSString *encodedString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,(CFStringRef)str,NULL,(CFStringRef)@"!*'();:@&=+$,/?%#[]",kCFStringEncodingUTF8 ));
    NSLog(@"%@",encodedString);
    return encodedString;
}


+ (NSString *)urlEncodeExceptSlash:(NSString *)str{
    NSString *encodedString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,(CFStringRef)str,NULL,(CFStringRef)@"!*'();:@&=+$,?%#[]",kCFStringEncodingUTF8 ));
    NSLog(@"%@",encodedString);
    return encodedString;
}


+(NSString *)preettyTime:(long long)ts
{
    //原有时间
    NSString *firstDateStr=[Util FormatTime:@"yyyy-MM-dd" timeInterval:ts];
    NSArray *firstDateStrArr=[firstDateStr componentsSeparatedByString:@"-"];
    
    //现在时间
    NSDate *now = [NSDate date];
    NSDateComponents *componentsNow = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:now];
    NSString *nowDateStr = [NSString stringWithFormat:@"%ld-%ld-%ld", (long)[componentsNow year], (long)[componentsNow month], (long)[componentsNow day]];
    NSArray *nowDateStrArr = [nowDateStr componentsSeparatedByString:@"-"];
    
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:ts/1000];
    NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
    
    //同年
    if ([firstDateStrArr[0] intValue] == [nowDateStrArr[0] intValue]){
        
        //当天
        if( [firstDateStrArr[1] intValue] == [nowDateStrArr[1] intValue] && [nowDateStrArr[2] intValue]== [firstDateStrArr[2] intValue]){
            [dateformatter setDateFormat:@"HH:mm"];
            return [NSString stringWithFormat:@"%@", [dateformatter stringFromDate:date]];
        }
        
        //昨天
        if( [firstDateStrArr[1] intValue]==[nowDateStrArr[1] intValue] && ([nowDateStrArr[2] intValue]-[firstDateStrArr[2] intValue]==1)){
            [dateformatter setDateFormat:@"HH:mm"];
            return [NSString stringWithFormat:@"昨天 %@", [dateformatter stringFromDate:date]];
            
        }else{//昨天之前
            [dateformatter setDateFormat:@"MM-dd HH:mm"];
            return  [dateformatter stringFromDate:date];
        }
        
    }else{
        [dateformatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        return [dateformatter stringFromDate:date];
    }
    
}

+ (NSString *)FormatTime:(NSString *)format timeInterval:(double)value;
{
    NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:value / 1000];
    [dateformatter setDateFormat:format];
    return [dateformatter stringFromDate:date];
}

+ (CGSize)targetImageSize:(NSInteger)width height:(NSInteger)height{
    NSInteger actualWidth;
    NSInteger actualHeight;
    CGFloat ratio = (CGFloat)width/height;
    if (width> IMAGE_WIDTH && height > IMAGE_HEIGHT) {
        actualWidth = width;
        actualHeight = height;
        for (;actualWidth >= IMAGE_WIDTH*2 &&actualHeight >= IMAGE_HEIGHT*2;) {
            actualHeight = height/2;
            actualWidth = width/2;
        }
        if (actualWidth >= IMAGE_WIDTH &&actualWidth >= IMAGE_HEIGHT) {
            actualWidth = IMAGE_WIDTH;
            actualHeight = actualWidth/ratio;
        }else if(actualWidth > IMAGE_WIDTH && actualWidth <= IMAGE_HEIGHT){
            actualWidth = IMAGE_WIDTH;
            actualHeight = actualWidth/ratio;
            
        }else if(actualWidth <= IMAGE_WIDTH && actualWidth >IMAGE_HEIGHT){
            actualHeight = IMAGE_HEIGHT;
            actualWidth = actualHeight*ratio;
            
        }if(actualWidth < IMAGE_HEIGHT && actualWidth < IMAGE_HEIGHT){
            actualWidth = width;
            actualHeight = height;
        }

    }else if(width > IMAGE_WIDTH && height <= IMAGE_HEIGHT){
        actualWidth = IMAGE_WIDTH;
        actualHeight = actualWidth/ratio;
        
    }else if(width <= IMAGE_WIDTH && height >IMAGE_HEIGHT){
        actualHeight = IMAGE_HEIGHT;
        actualWidth = actualHeight*ratio;
    
    }else if(width < IMAGE_HEIGHT && height < IMAGE_HEIGHT){
        actualWidth = width;
        actualHeight = height;
    }else{
        actualWidth = width;
        actualHeight = height;
    }

    return CGSizeMake(actualWidth, actualHeight);
}

+ (NSData *)compressImage:(UIImage *)image{
    
    NSData *imageData = UIImageJPEGRepresentation(image, IMAGE_QUALITY);
    
    for (; [imageData length] >= IMAGE_FILE_SZIE; ) {
        UIImage *compressedImage = [UIImage imageWithData:imageData];
        imageData = UIImageJPEGRepresentation(compressedImage, IMAGE_QUALITY);
    }
    return imageData;
}

@end
