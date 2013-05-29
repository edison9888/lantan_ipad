//
//  BaseViewController.h
//  LanTaiOrder
//
//  Created by Ruby on 13-3-17.
//  Copyright (c) 2013年 LanTai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseViewController : UIViewController

- (void)addLeftnaviItemWithImage:(NSString *)imageName;
- (void)addRightnaviItemWithImage:(NSString *)imageName;
- (void)addRightnaviItemsWithImage:(NSString *)imageName andImage:(NSString *)image;

@property (strong, nonatomic) UIButton *btn_ip;
@end
