//
//  ComplaintViewController.m
//  LanTaiOrder
//
//  Created by Ruby on 13-3-3.
//  Copyright (c) 2013年 LanTai. All rights reserved.
//

#import "ComplaintViewController.h"
#import "PayViewController.h"

@interface ComplaintViewController ()

@end

@implementation ComplaintViewController

@synthesize lblCarNum,lblCode,lblName,lblProduct;
@synthesize reasonView,requestView;
@synthesize info,infoBgView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (![self.navigationItem rightBarButtonItem]) {
        [self addRightnaviItemWithImage:@"back"];
    }
    if (info) {
        self.lblCarNum.text = [info objectForKey:@"carNum"];
        self.lblCode.text = [info objectForKey:@"code"];
        self.lblName.text = [info objectForKey:@"name"];
        self.lblProduct.text = [info objectForKey:@"prods"];
    }
    [self.reasonView becomeFirstResponder];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"view_bg"]];
     self.infoBgView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"dot_1_bg"]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)clickSubmit:(id)sender{
    if (self.reasonView.text.length==0 || self.requestView.text.length==0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kTip message:@"请输入投诉理由和要求" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }else{
        STHTTPRequest *r = [STHTTPRequest requestWithURLString:[NSString stringWithFormat:@"%@%@",kHost,kComplaint]];
        [r setPOSTDictionary:[NSDictionary dictionaryWithObjectsAndKeys:self.reasonView.text,@"reason",self.requestView.text,@"request",[DataService sharedService].store_id,@"store_id",[info objectForKey:@"order_id"],@"order_id", nil]];
        [r setPostDataEncoding:NSUTF8StringEncoding];
        NSError *error = nil;
        NSDictionary *result = [[r startSynchronousWithError:&error] objectFromJSONString];
        DLog(@"%@",result);
        if ([[result objectForKey:@"status"] intValue] == 1) {
            if([[info objectForKey:@"from"] intValue]==1){
                [self.navigationController popViewControllerAnimated:YES];
            }else{
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
    }
}

@end
