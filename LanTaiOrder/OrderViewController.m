//
//  OrderViewController.m
//  LanTaiOrder
//
//  Created by Ruby on 13-3-1.
//  Copyright (c) 2013年 LanTai. All rights reserved.
//

#import "OrderViewController.h"
#import "AddViewController.h"
#import "ProductCell.h"
#import "OldProductCell.h"
#import "ComplaintViewController.h"
#import "PicViewController.h"
#import "UIViewController+MJPopupViewController.h"
#import "PayViewController.h"
#import "TabHeader.h"

@interface OrderViewController ()<PicViewDelegate>{
    PicViewController *picView;
}

@end

@implementation OrderViewController

@synthesize lblBrand,lblCarNum,lblPhone,lblProduct,lblTime,lblUserName;
@synthesize btnCheckIn,btnDone,btnOldRecord,btnOrderRecord,btnCancel,btnPay;
@synthesize orderView,carInfoBgView,noInfoView,carInfoView,orderTable,workingTable;
@synthesize orderList,orderItems;
@synthesize lblOrderNum,lblReceiver,lblStatus,lblWorkingCar,lblWorkingName,lblTotal;
@synthesize car_num,customer,workingOrder;
@synthesize addOrderView;
@synthesize timeLabel,productLabel;
@synthesize car_id;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

//发送查询请求
- (void)searchOrderByCarNumWithCar_id:(NSString *)carid{
    if (car_num) {
        NSDictionary *result = nil;
        if (self.car_id) {
            STHTTPRequest *r = [STHTTPRequest requestWithURLString:[NSString stringWithFormat:@"%@%@",[DataService sharedService].kHost,kShowCar]];
            [r setPOSTDictionary:[NSDictionary dictionaryWithObjectsAndKeys:[DataService sharedService].store_id,@"store_id",car_num,@"car_num",car_id,@"car_id", nil]];
            [r setPostDataEncoding:NSUTF8StringEncoding];
            NSError *error = nil;
            NSString *str = [r startSynchronousWithError:&error];
            result = [str objectFromJSONString];
        }else {
            STHTTPRequest *r = [STHTTPRequest requestWithURLString:[NSString stringWithFormat:@"%@%@",[DataService sharedService].kHost,kSearchCar]];
            [r setPOSTDictionary:[NSDictionary dictionaryWithObjectsAndKeys:[DataService sharedService].store_id,@"store_id",car_num,@"car_num", nil]];
            [r setPostDataEncoding:NSUTF8StringEncoding];
            NSError *error = nil;
            NSString *str = [r startSynchronousWithError:&error];
            result = [str objectFromJSONString];
        }
        
        
        DLog(@"%@",result);
        if ([[result objectForKey:@"status"] intValue]==1) {
            if ([[result objectForKey:@"customer"] count]==0) {
                self.carInfoView.hidden = YES;
                self.noInfoView.hidden = NO;
            }else{
                self.carInfoView.hidden = NO;
                self.noInfoView.hidden = YES;
                self.lblCarNum.text = [[result objectForKey:@"customer"] objectForKey:@"num"];
                NSString *brand = [NSString stringWithFormat:@"%@-%@",[[result objectForKey:@"customer"] objectForKey:@"brand_name"],[[result objectForKey:@"customer"] objectForKey:@"model_name"]];
                self.lblBrand.text = brand;
                self.lblUserName.text = [[result objectForKey:@"customer"] objectForKey:@"name"];
                self.lblPhone.text = [[result objectForKey:@"customer"] objectForKey:@"mobilephone"];
                //客户信息
                [self.customer setObject:[[result objectForKey:@"customer"] objectForKey:@"num"] forKey:@"carNum"];
                [self.customer setObject:[[result objectForKey:@"customer"] objectForKey:@"name"] forKey:@"name"];
                [self.customer setObject:[[result objectForKey:@"customer"] objectForKey:@"mobilephone"] forKey:@"phone"];
                [self.customer setObject:[[result objectForKey:@"customer"] objectForKey:@"car_num_id"] forKey:@"car_num_id"];
                [self.customer setObject:[[result objectForKey:@"customer"] objectForKey:@"customer_id"] forKey:@"customer_id"];
                [self.customer setObject:[[result objectForKey:@"customer"] objectForKey:@"email"] forKey:@"email"];
                [self.customer setObject:[[result objectForKey:@"customer"] objectForKey:@"birth"] forKey:@"birth"];
                [self.customer setObject:[[result objectForKey:@"customer"] objectForKey:@"year"] forKey:@"year"];
                [self.customer setObject:[[result objectForKey:@"customer"] objectForKey:@"model_name"] forKey:@"model_name"];
                [self.customer setObject:[[result objectForKey:@"customer"] objectForKey:@"brand_name"] forKey:@"brand_name"];
                [self.customer setObject:[[result objectForKey:@"customer"] objectForKey:@"sex"] forKey:@"sex"];
                
                //正在进行中的订单
                self.workingOrder = [result objectForKey:@"working"];
                
                if ([[result objectForKey:@"working"] count]==0) {
                    //没有正在进行中的订单
                    self.lblProduct.text = @"";
                    self.lblTime.text = @"";
                    self.workingView.hidden = YES;
                    self.noWorkingView.hidden = NO;
                    self.orderTable.hidden = YES;
                    self.timeLabel.hidden = YES;//没有时间  隐藏label
                    self.productLabel.hidden = YES;//服务lab
                }else{
                    if (![[[result objectForKey:@"working"] objectForKey:@"started_at"] isEqual:[NSNull null]]) {
                        NSString *str = [Utils formateDate:[[result objectForKey:@"working"] objectForKey:@"started_at"]];
                        NSString *time = [NSString stringWithFormat:@"%@--%@",str,[Utils formateDate:[[result objectForKey:@"working"] objectForKey:@"ended_at"]]];
                        self.lblTime.text = time;
                        self.timeLabel.hidden = NO;//有时间  不隐藏label
                    }else {
                        self.timeLabel.hidden = YES;//没有时间  隐藏label
                    }
                    
                    NSMutableString *prod = [NSMutableString string];
                    NSArray *products = [[result objectForKey:@"working"] objectForKey:@"products"];
                    for (int x=0; x<products.count; x++) {
                        if (x==products.count-1) {
                          [prod appendFormat:@"%@",[[products objectAtIndex:x] objectForKey:@"name"]];  
                        }else{
                        [prod appendFormat:@"%@,",[[products objectAtIndex:x] objectForKey:@"name"]];
                        }
                    }
                    self.lblProduct.text = prod;
                    self.workingView.hidden = NO;
                    self.noWorkingView.hidden = YES;
                    self.orderTable.hidden = YES;
                    self.lblReceiver.text = [[result objectForKey:@"working"] objectForKey:@"staff"];
                    self.lblOrderNum.text = [[result objectForKey:@"working"] objectForKey:@"code"];
                    self.lblStatus.text = [Utils orderStatus:[[[result objectForKey:@"working"] objectForKey:@"status"] intValue]];
                    self.lblWorkingName.text = [[result objectForKey:@"customer"] objectForKey:@"name"];
                    self.lblWorkingCar.text = [[result objectForKey:@"customer"] objectForKey:@"num"];
                    self.lblTotal.text = [NSString stringWithFormat:@"%@(元)",[[result objectForKey:@"working"] objectForKey:@"price"]];
                    self.orderItems = [[result objectForKey:@"working"] objectForKey:@"products"];
                    if (self.orderItems.count == 0) {
                        self.productLabel.hidden = YES;//服务lab
                    }else {
                        self.productLabel.hidden = NO;//服务lab
                    }
                    if ([[workingOrder objectForKey:@"status"] intValue]==0) {
                        self.btnCancel.hidden = NO;
                    }else{
                        self.btnCancel.hidden = YES;
                    }
                    if ([[workingOrder objectForKey:@"status"] intValue]==1 || [[workingOrder objectForKey:@"status"] intValue]==2) {
                        self.btnPay.hidden = NO;
                    }else{
                        self.btnPay.hidden = YES;
                    }
                }
                //过往订单
                if ([[result objectForKey:@"old"] count]>0) {
                    self.orderList = [result objectForKey:@"old"];
                }
            }
        }
    }
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.orderTable reloadData];
}
- (void)viewDidLoad
{
    self.orderList = [NSMutableArray array];
    self.orderItems = [NSMutableArray array];
    self.customer = [NSMutableDictionary dictionary];
    self.workingOrder = [NSMutableDictionary dictionary];
    self.addOrderView = [[AddViewController alloc] initWithNibName:@"AddViewController" bundle:nil];
    
    [self searchOrderByCarNumWithCar_id:self.car_id];
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"order_bg"]];
    self.carInfoView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"dot_bg"]];
    self.noInfoView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"dot_bg"]];
    if (![self.navigationItem rightBarButtonItem]) {
        [self addRightnaviItemWithImage:@"back"];
    }
    
    //加摄像头
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 37, 37)];
    UIImage *image = [UIImage imageNamed:@""];
    imageView.image = image;
    [self.btnCheckIn addSubview:imageView];
    
    
    self.orderView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"order"]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if ([tableView isEqual:orderTable]) {
        return orderList.count;
    }else if([tableView isEqual:workingTable]){
        return orderItems.count;
    }
    return 0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if ([tableView isEqual:workingTable]) {
        return 0;
    }else {
        return 44;
    }
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"";
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *sectionTitle = [self tableView:tableView titleForHeaderInSection:section];
    if (sectionTitle == nil) {
        return nil;
    }
   
    CGRect frame = CGRectMake(0, 0, 844, 43);
    TabHeader *tabHeader = [[TabHeader alloc] initWithFrame:frame];
    return tabHeader;

}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([tableView isEqual:workingTable]) {
        static NSString *CellIdentifier = @"ProductCell";
        NSDictionary *product = [orderItems objectAtIndex:indexPath.row];
        ProductCell *cell = (ProductCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[ProductCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        cell.lblName.text = [product objectForKey:@"name"];
        cell.lblPrice.text = [NSString stringWithFormat:@"%@",[product objectForKey:@"price"]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }else{
        NSString *CellIdentifier = [NSString stringWithFormat:@"OldProductCell%d", [indexPath row]];
        OldProductCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        NSDictionary *order = [orderList objectAtIndex:indexPath.row];
        if (cell == nil) {
            cell = [[OldProductCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier items:[order objectForKey:@"products"]];
        }
        cell.lblCode.text = [order objectForKey:@"code"];
        //时间格式化
        NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
        [inputFormatter setLocale:[[NSLocale alloc] init]];
        [inputFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssz"];
        NSDate* createdDate = [inputFormatter dateFromString:[order objectForKey:@"created_at"]];
        NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
        [outputFormatter setLocale:[NSLocale currentLocale]];
        [outputFormatter setDateFormat:@"yyyy.MM.dd"];
        NSString *str = [outputFormatter stringFromDate:createdDate];
        cell.lblDate.text = str;
        cell.lblTotal.text = [NSString stringWithFormat:@"%.2f",[[order objectForKey:@"price"] floatValue]];
        cell.lblPay.text = [order objectForKey:@"pay_type"];
        [cell.btnComplaint addTarget:self action:@selector(clickComplaint:) forControlEvents:UIControlEventTouchUpInside];
        cell.btnComplaint.tag = 200 + indexPath.row;
        
        NSString *btnTag = [NSString stringWithFormat:@"%d",cell.btnComplaint.tag];
        NSMutableArray *array = [DataService sharedService].doneArray;
        if ([array containsObject:btnTag]) {
            if ([DataService sharedService].payNumber == 1) {
                [cell.btnComplaint setBackgroundImage:[UIImage imageNamed:@"btn_cancel.jpg"] forState:UIControlStateNormal];
                [cell.btnComplaint setBackgroundImage:[UIImage imageNamed:@"btn_cancel_active"] forState:UIControlStateHighlighted];
            }
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([tableView isEqual:workingTable]) {
        return 44;
    }else{
        NSDictionary *order = [orderList objectAtIndex:indexPath.row];
        int count = [[order objectForKey:@"products"] count];
        if (count == 0) {
            return 44+20;
        }
        return count * 44 +20;
        }
}

//点击投诉按钮
- (void)clickComplaint:(id)sender{
    UIButton *btn = (UIButton *)sender;
    ////////////////////////////////////////////
    NSString *btnTag = [NSString stringWithFormat:@"%d",btn.tag];
    DLog(@"%@",btnTag);
    NSMutableArray *array = [DataService sharedService].doneArray;
    NSMutableArray *tempArray = [[NSMutableArray alloc]init];//临时数组
    if (array.count > 0) {
        int i = 0;
        BOOL exit = NO;
        while (i<array.count) {
            NSString *str = [array objectAtIndex:i];
            if ([str isEqualToString:btnTag]) {
                exit = YES;
                break;
            }
            i++;
        }
        if (exit == NO) {
            [tempArray addObject:btnTag];
        }
    }else {
        [tempArray addObject:btnTag];
    }
    
    [[DataService sharedService].doneArray addObjectsFromArray:tempArray];
    
    NSDictionary *order = [orderList objectAtIndex:btn.tag - 200];
    ComplaintViewController *complaintView = [[ComplaintViewController alloc] initWithNibName:@"ComplaintViewController" bundle:nil];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:self.lblUserName.text forKey:@"name"];
    [dic setObject:self.lblCarNum.text forKey:@"carNum"];
    [dic setObject:[order objectForKey:@"code"] forKey:@"code"];//订单号
    [dic setObject:[order objectForKey:@"id"] forKey:@"order_id"];
    [dic setObject:@"1" forKey:@"from"]; // 进入投诉页面的来源
    NSMutableString *prods = [NSMutableString string];
    for (NSDictionary *prod in [order objectForKey:@"products"]) {
        [prods appendFormat:@"%@,",[prod objectForKey:@"name"]];
    }
    if (prods.length != 0) {
        [dic setObject:[prods substringToIndex:prods.length - 1] forKey:@"prods"];
    }
    
    complaintView.info = [NSMutableDictionary dictionaryWithDictionary:dic];
    [self.navigationController pushViewController:complaintView animated:YES];
}

//取消订单（未施工）
-(void)cancleOrder {
    
    STHTTPRequest *r = [STHTTPRequest requestWithURLString:[NSString stringWithFormat:@"%@%@",[DataService sharedService].kHost,kPayOrder]];
    [r setPOSTDictionary:[NSDictionary dictionaryWithObjectsAndKeys:[workingOrder objectForKey:@"id"],@"order_id",@"1",@"opt_type", nil]];
    [r setPostDataEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    NSDictionary *result = [[r startSynchronousWithError:&error] objectFromJSONString];
    if ([[result objectForKey:@"status"] intValue]==1) {
        [AHAlertView applyCustomAlertAppearance];
        AHAlertView *alertt = [[AHAlertView alloc] initWithTitle:kTip message:@"订单已取消"];
        __block AHAlertView *alert = alertt;
        [alertt setCancelButtonTitle:@"确定" block:^{
            alert.dismissalStyle = AHAlertViewDismissalStyleTumble;
            alert = nil;
            [self.navigationController popToRootViewControllerAnimated:YES];
        }];
        [alertt show];
        
    }else{
        [AHAlertView applyCustomAlertAppearance];
        AHAlertView *alertt = [[AHAlertView alloc] initWithTitle:kTip message:@"订单已取消失败"];
        __block AHAlertView *alert = alertt;
        [alertt setCancelButtonTitle:@"确定" block:^{
            alert.dismissalStyle = AHAlertViewDismissalStyleTumble;
            alert = nil;
        }];
        [alertt show];
    }
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}
- (IBAction)clickCancel:(id)sender{
    if ([workingOrder objectForKey:@"id"] != NULL) {
        if ([[Utils isExistenceNetwork] isEqualToString:@"NotReachable"]) {
            [AHAlertView applyCustomAlertAppearance];
            AHAlertView *alertt = [[AHAlertView alloc] initWithTitle:kTip message:kNoReachable];
            __block AHAlertView *alert = alertt;
            [alertt setCancelButtonTitle:@"确定" block:^{
                alert.dismissalStyle = AHAlertViewDismissalStyleTumble;
                alert = nil;
            }];
            [alertt show];
        }else {
            MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
            hud.dimBackground = NO;
            [hud showWhileExecuting:@selector(cancleOrder) onTarget:self withObject:nil animated:YES];
            hud.labelText = @"正在努力加载...";
            [self.view addSubview:hud];
        }
    }
}

//点击下单按钮
-(void)showAddView {
    self.addOrderView.customer = [NSMutableDictionary dictionaryWithDictionary:self.customer];
    [DataService sharedService].car_num = self.lblCarNum.text;
    [DataService sharedService].number = 0;
    self.addOrderView.step = @"3";
    //下单获取数据
    STHTTPRequest *r = [STHTTPRequest requestWithURLString:[NSString stringWithFormat:@"%@%@",[DataService sharedService].kHost,kBrandProduct]];
    [r setPOSTDictionary:[NSDictionary dictionaryWithObjectsAndKeys:[DataService sharedService].store_id,@"store_id", nil]];
    [r setPostDataEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    NSString *str = [r startSynchronousWithError:&error];
    NSDictionary *result = [str objectFromJSONString];
    self.addOrderView.brandResult = [NSMutableDictionary dictionaryWithDictionary:result];
    if ([[result objectForKey:@"status"] intValue]==1) {
        self.addOrderView.brandList = [NSMutableArray arrayWithArray:[result objectForKey:@"brands"]];
        self.addOrderView.productList = [NSMutableArray arrayWithArray:[result objectForKey:@"products"]];
    }
    
    [self.navigationController pushViewController:self.addOrderView animated:YES];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}
-(void)addView {
    self.addOrderView.step = @"0";
    self.addOrderView.car_num = self.car_num;//车牌号
    [DataService sharedService].number = 0;
    //下单获取数据
    STHTTPRequest *r = [STHTTPRequest requestWithURLString:[NSString stringWithFormat:@"%@%@",[DataService sharedService].kHost,kBrandProduct]];
    [r setPOSTDictionary:[NSDictionary dictionaryWithObjectsAndKeys:[DataService sharedService].store_id,@"store_id", nil]];
    [r setPostDataEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    NSString *str = [r startSynchronousWithError:&error];
    NSDictionary *result = [str objectFromJSONString];
    self.addOrderView.brandResult = [NSMutableDictionary dictionaryWithDictionary:result];
    if ([[result objectForKey:@"status"] intValue]==1) {
        self.addOrderView.brandList = [NSMutableArray arrayWithArray:[result objectForKey:@"brands"]];
        self.addOrderView.productList = [NSMutableArray arrayWithArray:[result objectForKey:@"products"]];
    }
    [self.navigationController pushViewController:self.addOrderView animated:YES];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}
- (IBAction)clickDone:(id)sender{
    UIButton *btn = (UIButton *)sender;
    
    if (btn.tag==101) {
        if ([[Utils isExistenceNetwork] isEqualToString:@"NotReachable"]) {
            [AHAlertView applyCustomAlertAppearance];
            AHAlertView *alertt = [[AHAlertView alloc] initWithTitle:kTip message:kNoReachable];
            __block AHAlertView *alert = alertt;
            [alertt setCancelButtonTitle:@"确定" block:^{
                alert.dismissalStyle = AHAlertViewDismissalStyleTumble;
                alert = nil;
            }];
            [alertt show];
        }else {
            MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
            hud.dimBackground = NO;
            [hud showWhileExecuting:@selector(addView) onTarget:self withObject:nil animated:YES];
            hud.labelText = @"正在努力加载...";
            [self.view addSubview:hud];
        }
    }else if (btn.tag==100){
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
            [hud showWhileExecuting:@selector(showAddView) onTarget:self withObject:nil animated:YES];
            hud.labelText = @"正在努力加载...";
            [self.view addSubview:hud];
        }
    }
}

- (IBAction)clickOld:(id)sender{
    self.orderTable.hidden = NO;
    self.workingView.hidden = YES;
    self.noWorkingView.hidden = YES;
    UIColor *c = [UIColor colorWithRed:147.0/255.0 green:2.0/255.0 blue:5.0/255.0 alpha:1.0];
    [btnOldRecord setTitleColor:c forState:UIControlStateNormal];
    [btnOldRecord setTitleColor:c forState:UIControlStateHighlighted];
    [btnOrderRecord setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [btnOrderRecord setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
}

//付款
-(void)pay {
    STHTTPRequest *r = [STHTTPRequest requestWithURLString:[NSString stringWithFormat:@"%@%@",[DataService sharedService].kHost,kPayOrder]];
    [r setPOSTDictionary:[NSDictionary dictionaryWithObjectsAndKeys:[workingOrder objectForKey:@"id"],@"order_id",@"0",@"opt_type", nil]];
    [r setPostDataEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    NSDictionary *result = [[r startSynchronousWithError:&error] objectFromJSONString];
    if ([[result objectForKey:@"status"] intValue]==1) {
        PayViewController *payView  = [[PayViewController alloc] initWithNibName:@"PayViewController" bundle:nil];
        payView.orderInfo = [result objectForKey:@"order"];
        [self.navigationController pushViewController:payView animated:YES];
    }else {
        [AHAlertView applyCustomAlertAppearance];
        AHAlertView *alertt = [[AHAlertView alloc] initWithTitle:kTip message:@"加载失败"];
        __block AHAlertView *alert = alertt;
        [alertt setCancelButtonTitle:@"确定" block:^{
            alert.dismissalStyle = AHAlertViewDismissalStyleTumble;
            alert = nil;
        }];
        [alertt show];
    }
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}
- (IBAction)clickPay:(id)sender{
    if ([workingOrder objectForKey:@"id"] != NULL) {
        if ([[Utils isExistenceNetwork] isEqualToString:@"NotReachable"]) {
            [AHAlertView applyCustomAlertAppearance];
            AHAlertView *alertt = [[AHAlertView alloc] initWithTitle:kTip message:kNoReachable];
            __block AHAlertView *alert = alertt;
            [alertt setCancelButtonTitle:@"确定" block:^{
                alert.dismissalStyle = AHAlertViewDismissalStyleTumble;
                alert = nil;
            }];
            [alertt show];
        }else {
            MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
            hud.dimBackground = NO;
            [hud showWhileExecuting:@selector(pay) onTarget:self withObject:nil animated:YES];
            hud.labelText = @"正在努力加载...";
            [self.view addSubview:hud];
        }
    }
}


- (IBAction)clickPic:(id)sender{
    picView = [[PicViewController alloc] initWithNibName:@"PicViewController" bundle:nil];
    picView.parentController = self;
    picView.delegate = self;
    [self presentPopupViewController:picView animationType:MJPopupViewAnimationSlideBottomBottom];
}

//或登记信息
-(void)reg {
    self.addOrderView.step = @"0";
    self.addOrderView.car_num = self.car_num;//车牌号
    [DataService sharedService].number = 1;
    //下单获取数据
    STHTTPRequest *r = [STHTTPRequest requestWithURLString:[NSString stringWithFormat:@"%@%@",[DataService sharedService].kHost,kBrandProduct]];
    [r setPOSTDictionary:[NSDictionary dictionaryWithObjectsAndKeys:[DataService sharedService].store_id,@"store_id", nil]];
    [r setPostDataEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    NSDictionary *result = [[r startSynchronousWithError:&error] objectFromJSONString];
    self.addOrderView.brandResult = [NSMutableDictionary dictionaryWithDictionary:result];
    if ([[result objectForKey:@"status"] intValue]==1) {
        self.addOrderView.brandList = [NSMutableArray arrayWithArray:[result objectForKey:@"brands"]];
        self.addOrderView.productList = [NSMutableArray arrayWithArray:[result objectForKey:@"products"]];
    }
    
    [self.navigationController pushViewController:self.addOrderView animated:YES];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}
- (IBAction)clickReg:(id)sender{
    if ([[Utils isExistenceNetwork] isEqualToString:@"NotReachable"]) {
        [AHAlertView applyCustomAlertAppearance];
        AHAlertView *alertt = [[AHAlertView alloc] initWithTitle:kTip message:kNoReachable];
        __block AHAlertView *alert = alertt;
        [alertt setCancelButtonTitle:@"确定" block:^{
            alert.dismissalStyle = AHAlertViewDismissalStyleTumble;
            alert = nil;
        }];
        [alertt show];
        
    }else {
        MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
        hud.dimBackground = NO;
        [hud showWhileExecuting:@selector(reg) onTarget:self withObject:nil animated:YES];
        hud.labelText = @"正在努力加载...";
        [self.view addSubview:hud];
    }
}

- (IBAction)clickWorking:(id)sender{
    UIColor *c = [UIColor colorWithRed:147.0/255.0 green:2.0/255.0 blue:5.0/255.0 alpha:1.0];
    [btnOrderRecord setTitleColor:c forState:UIControlStateNormal];
    [btnOrderRecord setTitleColor:c forState:UIControlStateHighlighted];
    [btnOldRecord setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [btnOldRecord setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    if(self.workingOrder.count != 0){
        self.workingView.hidden = NO;
        self.noWorkingView.hidden = YES;
    }else{
        self.workingView.hidden = YES;
        self.noWorkingView.hidden = NO;
    }
    self.orderTable.hidden = YES;
}

//关闭弹出框
- (void)closePopView:(PicViewController *)picViewController{
    [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
    picView = nil;
}

@end
