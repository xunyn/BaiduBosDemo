//
//  BcsSignatureManager.m
//  JianBao
//
//  Created by xunyanan on 1/18/16.
//  Copyright © 2016 xunyanan. All rights reserved.
//

#import "BcsSignatureManager.h"
#import "BCS.h"
#import "Util.h"

static NSString *bucket = BOS_BUCKET;
static BcsSignatureManager *defaultBcsSignatureManager;
@implementation BcsSignatureManager

+ (BcsSignatureManager *)defaultBcsSignatureManager{
    if (defaultBcsSignatureManager) {
        return defaultBcsSignatureManager;
    }
    defaultBcsSignatureManager = [[BcsSignatureManager alloc] init];
    return defaultBcsSignatureManager;
}
- (id)init{
    self = [super init];
    if (self) {

    }
    return self;
}

+ (NSString *)signaturedURL:(NSString *)method object:(NSString *)object{
    
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    NSString *dateString = [dateFormatter stringFromDate:date];
    
    NSString *authStr = [NSString stringWithFormat:@"bce-auth-%@/%@/%@/%@",BOS_VERSION,BOS_AK,dateString,@"1800"];
    
    NSString *signingKey =[Util sha256:BOS_SK content:authStr];
    
    NSString *canonicalURIStr = [NSString stringWithFormat:@"/%@/%@%@",BOS_VERSION, bucket,object];
    canonicalURIStr = [Util urlEncodeExceptSlash:canonicalURIStr];
    
    NSString *canonicalQueryString = [NSString stringWithFormat:@"responseContentDisposition=%@",@"attachment"];
    
    NSString *canonicalHeadersStr = [NSString stringWithFormat:@"host:%@",BOS_HOST];
    
    NSString *canonicalRequestStr = [NSString stringWithFormat:@"%@\n%@\n%@\n%@",method,canonicalURIStr,canonicalQueryString,canonicalHeadersStr];
    NSString *signature = [Util sha256:signingKey content:canonicalRequestStr];
    
    NSString *authorizationStr = [NSString stringWithFormat:@"%@/%@/%@",authStr,@"host",signature];
    //NSString *authorizationStr = [NSString stringWithFormat:@"%@/%@/%@",authStr,@"",signature];
    authorizationStr = [Util urlEncode:authorizationStr];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@%@/%@%@?%@&authorization=%@",BOS_SERVER,BOS_VERSION, bucket,object,canonicalQueryString,authorizationStr];
    NSLog(@"%@",urlStr);
    return urlStr;
}

+ (NSString *)bcsURLWithObject:(NSString *)object{
    NSString *str = [NSString stringWithFormat:@"%@%@/%@%@",BOS_SERVER,BOS_VERSION, bucket,object];
    return str;
}

+ (NSString *)bcsImagteURLWithObject:(NSString *)object{
    NSString *str = [NSString stringWithFormat:@"%@%@",BOS_IMAGE_SERVER,object];
    return str;
}


+ (NSMutableURLRequest *)signaturedHeader:(NSMutableURLRequest *)request object:(NSString *)object queryString:(NSString *)queryString{
    NSString *method = [request HTTPMethod];
    NSString *canonicalHeadersStr = [NSString stringWithFormat:@"host:%@",BOS_HOST];
    
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    NSString *dateString = [dateFormatter stringFromDate:date];
    
    NSString *authStr = [NSString stringWithFormat:@"bce-auth-%@/%@/%@/%@",BOS_VERSION,BOS_AK,dateString,@"1800"];
    
    
    NSString *signingKey =[Util sha256:BOS_SK content:authStr];
    
    NSString *canonicalURIStr = [NSString stringWithFormat:@"/%@/%@%@",BOS_VERSION, bucket,object];
    
     canonicalURIStr = [Util urlEncodeExceptSlash:canonicalURIStr];
    
    //need  handle query string
    
    NSString *canonicalRequestStr = [NSString stringWithFormat:@"%@\n%@\n%@\n%@",method,canonicalURIStr,queryString,canonicalHeadersStr];
    NSString *signature = [Util sha256:signingKey content:canonicalRequestStr];
    NSString *authorizationStr = [NSString stringWithFormat:@"%@/%@/%@",authStr,@"host",signature];
    
    [request setValue:authorizationStr forHTTPHeaderField:@"Authorization"];
    [request setValue:BOS_HOST forHTTPHeaderField:@"Host"];
    [request setValue:dateString forHTTPHeaderField:@"x-bce-date"];
    //[request setValue:dateString forHTTPHeaderField:@"Date"];
    
    return request;
}

+ (NSMutableURLRequest *)signaturedImageHeader:(NSMutableURLRequest *)request object:(NSString *)object queryString:(NSString *)queryString{
    NSString *method = [request HTTPMethod];
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    NSString *dateString = [dateFormatter stringFromDate:date];

    NSString *canonicalHeadersStr = [NSString stringWithFormat:@"host:%@",BOS_IMAGE_HOST];
    
    NSString *authStr = [NSString stringWithFormat:@"bce-auth-%@/%@/%@/%@",BOS_VERSION,BOS_AK,dateString,@"3600"];
    
    NSString *signingKey =[Util sha256:BOS_SK content:authStr];
    
    NSString *canonicalURIStr = [NSString stringWithFormat:@"/%@/%@%@",BOS_VERSION, bucket,object];
    
    canonicalURIStr = [NSString stringWithFormat:@"%@",object];
    canonicalURIStr = [Util urlEncodeExceptSlash:canonicalURIStr];
    
    //need  handle query string
    
    NSString *canonicalRequestStr = [NSString stringWithFormat:@"%@\n%@\n%@\n%@",method,canonicalURIStr,queryString,canonicalHeadersStr];
    NSString *signature = [Util sha256:signingKey content:canonicalRequestStr];
    NSString *authorizationStr = [NSString stringWithFormat:@"%@/%@/%@",authStr,@"host",signature];
    
    [request setValue:authorizationStr forHTTPHeaderField:@"Authorization"];
    [request setValue:BOS_IMAGE_HOST forHTTPHeaderField:@"Host"];
    [request setValue:dateString forHTTPHeaderField:@"x-bce-date"];

    
    return request;
}


+ (NSString *)signaturedHeaderStr:(NSString *)method object:(NSString *)object queryString:(NSString *)queryString{
    
    NSString *canonicalHeadersStr = [NSString stringWithFormat:@"host:%@",BOS_HOST];
    
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    NSString *dateString = [dateFormatter stringFromDate:date];
    
    NSString *authStr = [NSString stringWithFormat:@"bce-auth-%@/%@/%@/%@",BOS_VERSION,BOS_AK,dateString,@"1800"];
    
    
    NSString *signingKey =[Util sha256:BOS_SK content:authStr];
    
    NSString *canonicalURIStr = [NSString stringWithFormat:@"/%@/%@%@",BOS_VERSION, bucket,object];
    canonicalURIStr = [Util urlEncodeExceptSlash:canonicalURIStr];

    //need  handle query string

    NSString *canonicalRequestStr = [NSString stringWithFormat:@"%@\n%@\n%@\n%@",method,canonicalURIStr,queryString,canonicalHeadersStr];
    NSString *signature = [Util sha256:signingKey content:canonicalRequestStr];
    
    NSString *authorizationStr = [NSString stringWithFormat:@"%@/%@/%@",authStr,@"host",signature];

    return authorizationStr;
}


@end
