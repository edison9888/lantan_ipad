//
//  InitViewController.m
//  LanTaiOrder
//
//  Created by comdosoft on 13-3-29.
//  Copyright (c) 2013年 LanTai. All rights reserved.
//

#import "InitViewController.h"
#import "AppDelegate.h"

@interface InitViewController ()

@end

@implementation InitViewController
@synthesize activityView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.activityView startAnimating];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.activityView stopAnimating];
    
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self performSelector:@selector(showMainView) withObject:nil afterDelay:1];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)showMainView {
    [[AppDelegate shareInstance] showRootView];
}
@end