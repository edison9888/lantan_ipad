//
//  Utils.h
//  LanTaiOrder
//
//  Created by Ruby on 13-1-23.
//  Copyright (c) 2013年 LanTai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Utils : NSObject

+ (NSString *)isExistenceNetwork;

+ (NSMutableArray *)fetchWorkingList;

+ (NSString *)orderStatus:(int)status;

@end
