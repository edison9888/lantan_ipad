//
//  LoginViewController.m
//  LanTaiOrder
//
//  Created by Ruby on 13-1-23.
//  Copyright (c) 2013年 LanTai. All rights reserved.
//

#import "LoginViewController.h"
#import "AppDelegate.h"
#import "InitViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

@synthesize txtName,txtPwd,loginView;
@synthesize btn_ip;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)setIp {
    [DataService sharedService].kDomain = nil;
    [DataService sharedService].kHost = nil;
    [DataService sharedService].str_ip = nil;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"IP"];
    [defaults synchronize];
    
    [DataService sharedService].user_id = nil;
    [DataService sharedService].reserve_list = nil;
    [DataService sharedService].reserve_count = nil;
    [DataService sharedService].store_id = nil;
    [DataService sharedService].car_num = nil;
    NSUserDefaults *defaultss = [NSUserDefaults standardUserDefaults];
    [defaultss removeObjectForKey:@"userId"];
    [defaultss removeObjectForKey:@"storeId"];
    [defaultss synchronize];
    
    InitViewController *initView = [[InitViewController alloc]initWithNibName:@"InitViewController" bundle:nil];
    [self presentViewController:initView animated:YES completion:nil];

}
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
- (void)viewDidLoad
{
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"login_bg.jpg"]];
    self.loginView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"login"]];
    self.navigationController.navigationBar.hidden = YES;
    [super viewDidLoad];
    CGRect frame = self.txtName.frame;
    frame.size.height = 45;
    self.txtName.frame = frame;
    frame = txtPwd.frame;
    frame.size.height = 45;
    txtPwd.frame = frame;
    //监听键盘
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name: UIKeyboardWillHideNotification object:nil];
    
   
    self.btn_ip = [[UIButton alloc]initWithFrame:CGRectMake(495, 0, 40, 42)];
    [self.btn_ip setImage:[UIImage imageNamed:@"ip"] forState:UIControlStateNormal];
    [self.btn_ip addTarget:self action:@selector(setIp) forControlEvents:UIControlEventTouchUpInside];
    [self.loginView addSubview:self.btn_ip];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)closeAlert:(NSTimer*)timer {
    [(AHAlertView*) timer.userInfo  dismissWithStyle:AHAlertViewDismissalStyleZoomDown];
}
- (BOOL)checkForm{
    NSString *passport = [[NSString alloc] initWithString: self.txtName.text];
    NSString *password = [[NSString alloc] initWithString: self.txtPwd.text];
    NSString *msgStr = @"";
    if (passport.length == 0){
        msgStr = @"请输入用户名";
    }else if (password.length == 0){
        msgStr = @"请输入密码";
    }
    
    if (msgStr.length > 0){
        [AHAlertView applyCustomAlertAppearance];
        AHAlertView *alertt = [[AHAlertView alloc] initWithTitle:kTip message:msgStr];
//        __block AHAlertView *alert = alertt;
//        [alertt setCancelButtonTitle:@"确定" block:^{
//            alert.dismissalStyle = AHAlertViewDismissalStyleTumble;
//            alert = nil;
//        }];
        [alertt show];
        [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(closeAlert:) userInfo:alertt repeats:NO];
        return FALSE;
    }
    return TRUE;
}
-(void)login {
    STHTTPRequest *request = [STHTTPRequest requestWithURLString:[NSString stringWithFormat:@"%@%@",[DataService sharedService].kHost,kLogin]];
    [request setPOSTDictionary:[NSMutableDictionary dictionaryWithObjectsAndKeys:self.txtName.text,@"user_name",self.txtPwd.text,@"user_password", nil]];
    [request setPostDataEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    NSString *result = [request startSynchronousWithError:&error];
    NSDictionary *jsonData = [result objectFromJSONString];
    DLog(@"%@",jsonData);
    NSString *text = [jsonData objectForKey:@"info"];
    if (jsonData != nil) {
        if (text.length == 0) {
            NSDictionary *staff = [jsonData objectForKey:@"staff"];
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:[NSString stringWithFormat:@"%@",[staff objectForKey:@"id"]] forKey:@"userId"];
            [defaults setObject:[NSString stringWithFormat:@"%@",[staff objectForKey:@"store_id"]] forKey:@"storeId"];
            [defaults synchronize];
            
            [DataService sharedService].user_id = [NSString stringWithFormat:@"%@",[staff objectForKey:@"id"]];
            [DataService sharedService].store_id = [NSString stringWithFormat:@"%@",[staff objectForKey:@"store_id"]];
            [(AppDelegate *)[UIApplication sharedApplication].delegate showRootView];
            
        }else{
            [AHAlertView applyCustomAlertAppearance];
            AHAlertView *alertt = [[AHAlertView alloc] initWithTitle:kTip message:text];
            __block AHAlertView *alert = alertt;
            [alertt setCancelButtonTitle:@"确定" block:^{
                alert.dismissalStyle = AHAlertViewDismissalStyleTumble;
                alert = nil;
            }];
            [alertt show];
        }
    }else {
        [AHAlertView applyCustomAlertAppearance];
        AHAlertView *alertt = [[AHAlertView alloc] initWithTitle:kTip message:@"出错了"];
        __block AHAlertView *alert = alertt;
        [alertt setCancelButtonTitle:@"确定" block:^{
            alert.dismissalStyle = AHAlertViewDismissalStyleTumble;
            alert = nil;
        }];
        [alertt show];
        
    }
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}
- (IBAction)clickLogin:(id)sender{
    
    [self.txtName resignFirstResponder];
    [self.txtPwd resignFirstResponder];
    if ([self checkForm]) {
        if ([[Utils isExistenceNetwork] isEqualToString:@"NotReachable"]) {
            [AHAlertView applyCustomAlertAppearance];
            AHAlertView *alertt = [[AHAlertView alloc] initWithTitle:kTip message:kNoReachable];
            __block AHAlertView *alert = alertt;
            [alertt setCancelButtonTitle:@"确定" block:^{
                alert.dismissalStyle = AHAlertViewDismissalStyleTumble;
                alert = nil;
            }];
            [alertt show];
        }else{
            MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
            hud.dimBackground = NO;
            [hud showWhileExecuting:@selector(login) onTarget:self withObject:nil animated:YES];
            hud.labelText = @"正在努力加载...";
            [self.view addSubview:hud];
        }
    }
}

- (void)keyBoardWillShow:(id)sender{
    [UIView beginAnimations:nil context:nil];
    CGRect frame = self.loginView.frame;
    if (frame.origin.y==100) {
        frame.origin.y = -30;
    }
    self.loginView.frame = frame;
    [UIView commitAnimations];
}

- (void)keyBoardWillHide:(id)sender{
    [UIView beginAnimations:nil context:nil];
    CGRect frame = self.loginView.frame;
    if (frame.origin.y==-30) {
        frame.origin.y = 100;
    }
    self.loginView.frame = frame;
    [UIView commitAnimations];
}

@end
