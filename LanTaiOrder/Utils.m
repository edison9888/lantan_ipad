//
//  Utils.m
//  LanTaiOrder
//
//  Created by Ruby on 13-1-23.
//  Copyright (c) 2013年 LanTai. All rights reserved.
//

#import "Utils.h"
#import "pinyin.h"

@implementation Utils

//判断网络类型
+ (NSString *)isExistenceNetwork {
    NSString *str = nil;
	Reachability *r = [Reachability reachabilityWithHostName:@"www.apple.com"];
    switch ([r currentReachabilityStatus]) {
        case NotReachable:
			str = @"NotReachable";
            break;
        case ReachableViaWWAN:
			str = @"ReachableViaWWAN";
            break;
        case ReachableViaWiFi:
			str = @"ReachableViaWiFi";
            break;
    }
    return str;
}
+(NSMutableArray *)matchArray {
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 0; i < 27; i++) [array addObject:[NSMutableArray array]];
    NSString *nameSection = nil;
    for (int m=0; m<[[DataService sharedService].matchArray count]; m++) {
        
        nameSection = [[NSString stringWithFormat:@"%c",pinyinFirstLetter([[[DataService sharedService].matchArray objectAtIndex:m] characterAtIndex:0])] uppercaseString];
        NSUInteger firstLetterLoc = [ALPHA rangeOfString:[nameSection substringToIndex:1]].location;
        if (firstLetterLoc != NSNotFound)
            [[array objectAtIndex:firstLetterLoc] addObject:[[DataService sharedService].matchArray objectAtIndex:m]];
    }
    return array;
}

+ (NSString *)orderStatus:(int)status{
    if (status==0) {
        return @"未施工";
    }else if(status==1){
        return @"施工中";
    }else if(status==2){
        return @"等待付款";
    }else if(status==3){
        return @"已付款";
    }else if(status==4){
        return @"已结束";
    }
    return @"";
}

+ (NSString *)formateDate:(NSString *)date{
    NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
    [inputFormatter setLocale:[[NSLocale alloc] init]];
    [inputFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssz"];
    NSDate* startDate = [inputFormatter dateFromString:date];
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setLocale:[NSLocale currentLocale]];
    [outputFormatter setDateFormat:@"yyyy.MM.dd HH:mm"];
    NSString *str = [outputFormatter stringFromDate:startDate];
    return str;
}

+ (NSString *)MD5:(NSString *)str{
    const char *cStr = [str UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, strlen(cStr), result); // This is the md5 call
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

+(NSString *)createPostURL:(NSMutableDictionary *)params
{
    NSString *postString=@"";
    for(NSString *key in [params allKeys])
    {
        NSString *value=[params objectForKey:key];
        postString=[postString stringByAppendingFormat:@"%@=%@&",key,value];
    }
    if([postString length]>1)
    {
        postString=[postString substringToIndex:[postString length]-1];
    }
    return postString;
}

+(NSMutableURLRequest *)getRequest:(NSMutableDictionary *)params string:(NSString *)theStr{
    NSString *postURL=[Utils createPostURL:params];
    NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:theStr]];
    [theRequest setHTTPMethod:@"POST"];
    [theRequest setHTTPBody:[postURL dataUsingEncoding:NSUTF8StringEncoding]];
    [theRequest addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    return theRequest;
}

@end
