 //
//  AddViewController.m
//  LanTaiOrder
//
//  Created by Ruby on 13-3-3.
//  Copyright (c) 2013年 LanTai. All rights reserved.
//

#import "AddViewController.h"

@interface AddViewController ()

@end

#define PICTURE @"pic"
#define kPickerAnimationDuration 0.40
#define TagOff 100
#define TagOn 1000

@implementation AddViewController
@synthesize stepView_0,stepView_1,stepView_2,stepView_3,stepView_4,step,btnDone,btnNext,btnPre;
@synthesize picView_0,picView_1,picView_2,picView_3,stepImg;
@synthesize brandView,modelView,productsView;
@synthesize txtBirth,txtCarNum,txtCarYear,txtEmail,txtName,txtPhone;
@synthesize getPic,brandList,brandResult,productList,selectedIndexs,customer;
@synthesize picArray,dataArray,car_num;
@synthesize pickerView,pickView,dateFormatter;
@synthesize pickerBtn,refreshBtn;
@synthesize label,product_ids;
@synthesize manBtn,womanBtn;


static bool refresh = NO;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)fileURL
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:[fileURL path]]) {
        return NO;
    }
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    if ([currSysVer isEqualToString:@"5.0.1"]) {
        const char* filePath = [[fileURL path] fileSystemRepresentation];
        const char* attrName = "com.apple.MobileBackup";
        u_int8_t attrValue = 1;
        int result = setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
        return result == 0;
    }
    else if (&NSURLIsExcludedFromBackupKey) {
        NSError *error = nil;
        BOOL result = [fileURL setResourceValue:[NSNumber numberWithBool:YES] forKey:NSURLIsExcludedFromBackupKey error:&error];
        if (result == NO) {
            return NO;
        }
        else {
            return YES;
        }
    } else {
        return YES;
    }
}


- (void)initView{
    self.btnNext.hidden = NO;
    self.btnDone.hidden = YES;
    self.btnPre.hidden = NO;
    self.refreshBtn.hidden = YES;
    if ([step intValue]==0) {
        self.btnPre.hidden = YES;
        stepView_0.hidden = NO;
        stepView_1.hidden = YES;
        stepView_2.hidden = YES;
        stepView_3.hidden = YES;
        stepView_4.hidden = YES;
    }else if ([step intValue]==1) {
        stepView_0.hidden = YES;
        stepView_1.hidden = NO;
        stepView_2.hidden = YES;
        stepView_3.hidden = YES;
        stepView_4.hidden = YES;
    }else if ([step intValue]==2) {
        if ([DataService sharedService].number == 1) {
            stepView_0.hidden = YES;
            stepView_1.hidden = YES;
            stepView_2.hidden = NO;
            stepView_3.hidden = YES;
            stepView_4.hidden = YES;
            self.btnNext.hidden = YES;
            self.btnDone.hidden = NO;
        }else {
            stepView_0.hidden = YES;
            stepView_1.hidden = YES;
            stepView_2.hidden = NO;
            stepView_3.hidden = YES;
            stepView_4.hidden = YES;
        }
    }else if ([step intValue]==3) {
        stepView_0.hidden = YES;
        stepView_1.hidden = YES;
        stepView_2.hidden = YES;
        stepView_3.hidden = NO;
        stepView_4.hidden = YES;
    }else if ([step intValue]==4) {
        self.refreshBtn.hidden = NO;
        self.btnNext.hidden = YES;
        self.btnDone.hidden = NO;
        stepView_0.hidden = YES;
        stepView_1.hidden = YES;
        stepView_2.hidden = YES;
        stepView_3.hidden = YES;
        stepView_4.hidden = NO;
    }
}

- (void)initPicView{
    picView_0 = [[PictureCell alloc] initWithFrame:CGRectMake(250, 50, 172, 192) title:@"车前" delegate:self img:@"front"];
    picView_1 = [[PictureCell alloc] initWithFrame:CGRectMake(520, 50, 172, 192) title:@"车后" delegate:self img:@"behind"];
    picView_2 = [[PictureCell alloc] initWithFrame:CGRectMake(250, 260, 172, 192) title:@"车左" delegate:self img:@"left"];
    picView_3 = [[PictureCell alloc] initWithFrame:CGRectMake(520, 260, 172, 192) title:@"车右" delegate:self img:@"right"];
    [stepView_3 addSubview:picView_0];
    [stepView_3 addSubview:picView_1];
    [stepView_3 addSubview:picView_2];
    [stepView_3 addSubview:picView_3];
}

- (void)initBrandView{
    CGRect frame = self.brandView.frame;
    frame.size.height = 162.0;
    self.brandView.frame = frame;
    frame = self.modelView.frame;
    frame.size.height = 162.0;
    self.modelView.frame = frame;
    
    if ((brandList.count>0) && (![[customer objectForKey:@"brand_name"] isKindOfClass:[NSNull class]])) {
        for (int i = 0; i<brandList.count; i++) {
            NSDictionary *brand_dic = [brandList objectAtIndex:i];
            NSString *name_brand = [brand_dic objectForKey:@"name"];

            if ([name_brand isEqualToString:[customer objectForKey:@"brand_name"]]) {
                [self.brandView selectRow:i inComponent:0 animated:YES];
                
                NSArray *models_array = [brand_dic objectForKey:@"models"];
                if ((models_array.count >0)&& (![[customer objectForKey:@"model_name"] isKindOfClass:[NSNull class]])) {
                    for (int j=0; j<models_array.count; j++) {
                        NSDictionary *model_dic = [models_array objectAtIndex:j];
                        NSString *name_model = [model_dic objectForKey:@"name"];
                        if ([name_model isEqualToString:[customer objectForKey:@"model_name"]]) {
                            [self.modelView selectRow:j inComponent:0 animated:YES];
                        }
                    }
                }
            }
        }
    }
    
}
-(NSString *)getDoucmentFilePathLittleImageWithName:(NSString *)theName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsDirectory=[paths    objectAtIndex:0];
    NSString *savePath=[documentsDirectory stringByAppendingPathComponent:theName];
    //创建文件管理器
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //判断temp文件夹是否存在
    BOOL fileExists = [fileManager fileExistsAtPath:savePath];
    if (!fileExists) {
        [fileManager createDirectoryAtPath:savePath
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:nil];
    }
    return savePath;
}
//读取plist文件
-(void)getPci {
    NSFileManager *fileManage = [NSFileManager defaultManager];
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *path=[paths    objectAtIndex:0];
    NSString *filename=[path stringByAppendingPathComponent:@"pic.plist"];
    if ([fileManage fileExistsAtPath:filename]) {
        NSMutableArray *array = [[NSMutableArray alloc]initWithContentsOfFile:filename];
        self.dataArray = array;
        [fileManage removeItemAtPath:filename error:nil];
        
	}else {
        NSMutableArray *array = [[NSMutableArray alloc ]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"pic" ofType:@"plist"]];
        self.dataArray = array;
    }
    
    if (self.dataArray.count == 0) {
        self.dataArray = [NSMutableArray array];
    }
}

//把图片保存至沙盒
-(void)savePhotoDataWithfile:(NSString *)theFile andImage:(UIImage *)theImage andName:(NSString *)theName {
    //创建文件管理器
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //判断temp文件夹是否存在
    BOOL fileExists = [fileManager fileExistsAtPath:theFile];
    if (!fileExists) {
        [fileManager createDirectoryAtPath:theFile
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:nil];
    }
    NSString *uniquePath=[theFile stringByAppendingPathComponent:theName];
    [UIImagePNGRepresentation(theImage) writeToFile: uniquePath    atomically:YES];
}
//删除原图文件夹
-(void)deleteImageWithName:(NSString *)name {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsDirectory=[paths objectAtIndex:0];
    NSString *savePath=[documentsDirectory stringByAppendingPathComponent:name];
    //创建文件管理器
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //判断temp文件夹是否存在
    BOOL fileExists = [fileManager fileExistsAtPath:savePath];
    if (fileExists) {
        [fileManager removeItemAtPath:savePath error:nil];
    }
}
-(void)getData {
    STHTTPRequest *r = [STHTTPRequest requestWithURLString:[NSString stringWithFormat:@"%@%@",[DataService sharedService].kHost,kBrandProduct]];
    [r setPOSTDictionary:[NSDictionary dictionaryWithObjectsAndKeys:[DataService sharedService].store_id,@"store_id", nil]];
    [r setPostDataEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    NSString *str = [r startSynchronousWithError:&error];
    NSDictionary *result = [str objectFromJSONString];
    self.brandResult = [NSMutableDictionary dictionaryWithDictionary:result];
    if ([[result objectForKey:@"status"] intValue]==1) {
        self.brandList = [NSMutableArray arrayWithArray:[result objectForKey:@"brands"]];
        self.productList = [NSMutableArray arrayWithArray:[result objectForKey:@"products"]];
    }
    
    [self initData];
}
//刷新
-(IBAction)refreshBtnPressed:(id)sender {
    refresh = YES;
    //删除plist
    NSFileManager *fileManage = [NSFileManager defaultManager];
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *path=[paths    objectAtIndex:0];
    NSString *filename=[path stringByAppendingPathComponent:@"pic.plist"];
    if ([fileManage fileExistsAtPath:filename]) {
        [fileManage removeItemAtPath:filename error:nil];
    }
    //删除图片文件夹
    [self deleteImageWithName:PICTURE];

    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    hud.dimBackground = NO;
    [hud showWhileExecuting:@selector(getData) onTarget:self withObject:nil animated:YES];
    hud.labelText = @"正在努力加载...";
    [self.view addSubview:hud];
}
- (void)initData{
    if ([DataService sharedService].number == 0) {
        self.picArray = [NSMutableArray array];
        [self getPci];
    
        if (self.productList.count>0) {
            NSMutableArray *tempArray = [[NSMutableArray alloc]init];//临时数组
            for (int i=0; i<self.productList.count-1; i++) {
                NSMutableArray *arrayPic = [self.productList objectAtIndex:i];
                NSMutableArray *array = [[NSMutableArray alloc]init];
                if (arrayPic.count>0) {
                    for (int j=0; j<arrayPic.count; j++) {
                        NSDictionary *picDic = [[NSDictionary alloc]initWithDictionary:[arrayPic objectAtIndex:j]];
                        NSString *pic = [NSString stringWithFormat:@"%@",[picDic objectForKey:@"img"]];
                        
                        UIImage *image = nil;
                       
                            if ((![pic isEqualToString:@""]) || (![pic isKindOfClass:[NSNull class]])) {
                                NSString *urlstring = [NSString stringWithFormat:@"%@%@",[DataService sharedService].kDomain,pic];//图片的路径
                                NSString *typeStr = [urlstring substringFromIndex:urlstring.length-4];//取图片的格式
                                NSString *urlStringMd5 = [Utils MD5:urlstring];
                                NSString *picName = [NSString stringWithFormat:@"%@%@",urlStringMd5,typeStr];//保存的图片名称
                                NSDictionary *picDictionary = [NSDictionary dictionaryWithObjectsAndKeys:urlstring,picName, nil];//保存到plist的字典
                                //遍历plist数组，查看本地是否有保存
                                if (self.dataArray.count > 0) {
                                    BOOL exit = NO;
                                    int i=0;
                                    while (i<self.dataArray.count) {
                                        NSDictionary *dictionary = [self.dataArray objectAtIndex:i];
                                        if ([dictionary isEqualToDictionary:picDictionary]) {
                                            exit = YES;
                                            
                                            NSString *picDocument = [self getDoucmentFilePathLittleImageWithName:PICTURE];//保存图片的文件夹
                                            if ([self addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:picDocument]]) {
                                                NSString *picture = [picDocument stringByAppendingPathComponent:picName];//保存图片的路径
                                                //直接从沙盒读取图片
                                                NSData *imageData=[[NSData alloc ]initWithContentsOfFile:picture];
                                                image = [UIImage imageWithData:imageData];
                                                break;
                                            }
                                        }
                                        i++;
                                    }
                                    //不在plist里面
                                    if (exit == NO) {
                                        image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",[DataService sharedService].kDomain,pic]]]];
                                        NSString *picDocument = [self getDoucmentFilePathLittleImageWithName:PICTURE];
                                        if ([self addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:picDocument]]) {
                                            [self savePhotoDataWithfile:picDocument andImage:image andName:picName];//保存图片
                                            [tempArray addObject:picDictionary];
                                        }
                                    }
                                }else {//plist为空
                                    image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",[DataService sharedService].kDomain,pic]]]];
                                    NSString *picDocument = [self getDoucmentFilePathLittleImageWithName:PICTURE];
                                    if ([self addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:picDocument]]) {
                                        [self savePhotoDataWithfile:picDocument andImage:image andName:picName];//保存图片
                                        [tempArray addObject:picDictionary];
                                    }
                                }
                                if (image == nil) {
                                    image = [UIImage imageNamed:@"defualt.jpg"];
                                    [array addObject:image];
                                }else {
                                    [array addObject:image];
                                }
                                
                            }else {
                                image = [UIImage imageNamed:@"defualt.jpg"];
                                [array addObject:image];
                            }
                    }
                }
                [self.picArray addObject:array];
            }
            if (tempArray.count>0) {
                [self.dataArray addObjectsFromArray:tempArray];
            }
            //保存到plist
            NSString *filename=[self getHistoryPath];
            NSMutableArray *arraySave =[[NSMutableArray alloc]initWithContentsOfFile:filename];
            [arraySave addObjectsFromArray:self.dataArray];
            [arraySave writeToFile:filename atomically:YES];
        }
    }
    if (refresh == YES) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self.productsView reloadData];
        refresh = NO;
    }
}
//保存到plist文件
-(NSString*)getHistoryPath {
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *path=[paths    objectAtIndex:0];
    NSString *filename=[path stringByAppendingPathComponent:@"pic.plist"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filename])//判断文件是否已存在
    {
        
    }
    else
    {
        NSMutableArray *array=[NSMutableArray array];
        [array writeToFile:filename atomically:YES];
    }
    return filename;
    
}
- (void)initProdView{
   [self.productsView registerClass:[CollectionCell class] forCellWithReuseIdentifier:@"CollectionCell"];
    [self.productsView registerClass:[CollectionHeader class] forSupplementaryViewOfKind:@"CollectionHeader" withReuseIdentifier:@"CollectionHeader"];
    CollectionViewLayout *layout = [[CollectionViewLayout alloc] init];
    [self.productsView setCollectionViewLayout:layout];
    self.selectedIndexs = [NSMutableArray array];
}

- (void)viewDidLoad
{
    self.picArray = [NSMutableArray array];
    
    //日期得pickerView
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateFormat:@"yyyy-MM-dd"];
    [self initData];
    
    [super viewDidLoad];
    [self initView];
    [self initPicView];
    [self initBrandView];
    [self initProdView];

    if (![self.navigationItem rightBarButtonItem]) {
        [self addRightnaviItemWithImage:@"back"];
    }
    //登记车牌号
    if (self.car_num) {
        self.txtCarNum.text = self.car_num;
    }
    if (self.customer) {
        self.txtCarNum.text = [customer objectForKey:@"carNum"];
        self.txtName.text = [customer objectForKey:@"name"];
        self.txtPhone.text = [customer objectForKey:@"phone"];
        if (![[customer objectForKey:@"email"] isKindOfClass:[NSNull class]]) {
            self.txtEmail.text = [customer objectForKey:@"email"];
        }
        if (![[customer objectForKey:@"birth"] isKindOfClass:[NSNull class]]) {
            self.txtBirth.text = [customer objectForKey:@"birth"];
        }
        if(![[customer objectForKey:@"year"]isKindOfClass:[NSNull class]]){
            self.txtCarYear.text = [NSString stringWithFormat:@"%@",[customer objectForKey:@"year"]];
        }
        
        if(![[customer objectForKey:@"sex"]isKindOfClass:[NSNull class]]) {
            int sexNumber = [[customer objectForKey:@"sex"]intValue];
            if (sexNumber == 0) {
                self.manBtn.tag = TagOn;
                [self.manBtn setImage:[UIImage imageNamed:@"cb_mono_on"] forState:UIControlStateNormal];
                
                self.womanBtn.tag = TagOff;
                [self.womanBtn setImage:[UIImage imageNamed:@"cb_mono_off"] forState:UIControlStateNormal];
            }else if (sexNumber == 1) {
                self.womanBtn.tag = TagOn;
                [self.womanBtn setImage:[UIImage imageNamed:@"cb_mono_on"] forState:UIControlStateNormal];
                
                self.manBtn.tag = TagOff;
                [self.manBtn setImage:[UIImage imageNamed:@"cb_mono_off"] forState:UIControlStateNormal];
            }
        }else {
            self.manBtn.tag = TagOff;
            [self.manBtn setImage:[UIImage imageNamed:@"cb_mono_off"] forState:UIControlStateNormal];
            
            self.womanBtn.tag = TagOff;
            [self.womanBtn setImage:[UIImage imageNamed:@"cb_mono_off"] forState:UIControlStateNormal];

        }
    }else {
        self.manBtn.tag = TagOff;
        [self.manBtn setImage:[UIImage imageNamed:@"cb_mono_off"] forState:UIControlStateNormal];
        
        self.womanBtn.tag = TagOff;
        [self.womanBtn setImage:[UIImage imageNamed:@"cb_mono_off"] forState:UIControlStateNormal];
    }
    
    if (self.step) {
        [self.stepImg setImage:[UIImage imageNamed:[NSString stringWithFormat:@"step_%@",step]]];
    }
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"view_bg"]];
    
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideKeyBord)];
//    [self.view addGestureRecognizer:tap];
}
//-(void)hideKeyBord {
//    [self.txtName resignFirstResponder];
//    [self.txtPhone resignFirstResponder];
//    [self.txtEmail resignFirstResponder];
//    [self.txtCarYear resignFirstResponder];
//    [self.txtCarNum resignFirstResponder];
//    [self.txtBirth resignFirstResponder];
//    
//    CGRect pickerFrame = self.pickView.frame;
//    pickerFrame.origin.y = self.view.frame.size.height;
//    [UIView beginAnimations:nil context:NULL];
//    [UIView setAnimationDuration:kPickerAnimationDuration];
//    [UIView setAnimationDelegate:self];
//    [UIView setAnimationDidStopSelector:@selector(slideDownDidStop)];
//    self.pickView.frame = pickerFrame;
//    [UIView commitAnimations];
//    [DataService sharedService].tagOfBtn = 0;
//    
//    [self.productsView becomeFirstResponder];
//}

-(IBAction)btnPressed:(id)sender {
    [self.txtName resignFirstResponder];
    [self.txtPhone resignFirstResponder];
    [self.txtEmail resignFirstResponder];
    [self.txtCarYear resignFirstResponder];
    [self.txtCarNum resignFirstResponder];
    [self.txtBirth resignFirstResponder];
    
    CGRect pickerFrame = self.pickView.frame;
    pickerFrame.origin.y = self.view.frame.size.height;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:kPickerAnimationDuration];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(slideDownDidStop)];
    self.pickView.frame = pickerFrame;
    [UIView commitAnimations];
    [DataService sharedService].tagOfBtn = 0;
}

-(IBAction)pickerViewDown:(id)sender {
    CGRect pickerFrame = self.pickView.frame;
    pickerFrame.origin.y = self.view.frame.size.height;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:kPickerAnimationDuration];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(slideDownDidStop)];
    self.pickView.frame = pickerFrame;
    [UIView commitAnimations];
    [DataService sharedService].tagOfBtn = 0;
}
-(IBAction)showPicker:(id)sender {
    [self.txtName resignFirstResponder];
    [self.txtPhone resignFirstResponder];
    [self.txtEmail resignFirstResponder];
    [self.txtCarYear resignFirstResponder];
    [self.txtCarNum resignFirstResponder];
    [self.txtBirth resignFirstResponder];
    
    //初识状态
    if(![[customer objectForKey:@"birth"]isKindOfClass:[NSNull class]] && [customer objectForKey:@"birth"] != nil) {
        self.pickerView.date = [self.dateFormatter dateFromString:self.txtBirth.text];
    }else {
        self.pickerView.date = [NSDate date];
    }
    if ([DataService sharedService].tagOfBtn == 0)
    {
        CGRect startFrame = self.pickView.frame;
        CGRect endFrame = self.pickView.frame;
        startFrame.origin.y = self.view.frame.size.height;
        endFrame.origin.y = startFrame.origin.y - endFrame.size.height;
        self.pickView.frame = startFrame;
        [self.view addSubview:self.pickView];
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:kPickerAnimationDuration];
        self.pickView.frame = endFrame;
        [UIView commitAnimations];
        
        [DataService sharedService].tagOfBtn = 1;
    }
}
- (void)textFieldDidEndEditing:(UITextField *)textField {
    if ([textField isEqual:self.txtBirth] || [textField isEqual:self.txtName] || [textField isEqual:self.txtEmail] || [textField isEqual:self.txtPhone]) {
        
        [UIView beginAnimations:nil context:nil];
        CGRect frame = self.stepView_2.frame;
        if (frame.origin.y== 44) {
            frame.origin.y = 104;
        }
        self.stepView_2.frame = frame;
        
        CGRect frame2 = self.label.frame;
        if (frame2.origin.y==48) {
            frame2.origin.y = 6;
        }
        self.label.frame = frame2;
        [UIView commitAnimations];
    }
}
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField.tag == 102) {
    }else {
        CGRect pickerFrame = self.pickView.frame;
        pickerFrame.origin.y = self.view.frame.size.height;
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:kPickerAnimationDuration];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(slideDownDidStop)];
        self.pickView.frame = pickerFrame;
        [UIView commitAnimations];
        
        [DataService sharedService].tagOfBtn = 0;
    }
    if ([textField isEqual:self.txtBirth] || [textField isEqual:self.txtName] || [textField isEqual:self.txtEmail] || [textField isEqual:self.txtPhone]) {
        [UIView beginAnimations:nil context:nil];
        CGRect frame = self.stepView_2.frame;
        if (frame.origin.y==104) {
            frame.origin.y = 44;
        }
        self.stepView_2.frame = frame;
        
        CGRect frame2 = self.label.frame;
        if (frame2.origin.y==6) {
            frame2.origin.y = 48;
        }
        self.label.frame = frame2;
        [UIView commitAnimations];
    }
}
- (IBAction)dateAction:(id)sender
{
	self.txtBirth.text = [self.dateFormatter stringFromDate:self.pickerView.date];
}
- (void)slideDownDidStop
{
	[self.pickView removeFromSuperview];
}
//完成登记
-(void)finishInfo {
    STHTTPRequest *r = [STHTTPRequest requestWithURLString:[NSString stringWithFormat:@"%@%@",[DataService sharedService].kHost,kcheckIn]];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:txtCarNum.text forKey:@"carNum"];
    [dic setObject:txtName.text forKey:@"userName"];
    [dic setObject:txtPhone.text forKey:@"phone"];
    [dic setObject:txtCarYear.text forKey:@"year"];
    if (![self.txtBirth.text isEqualToString:@""]) {
        [dic setObject:txtBirth.text forKey:@"birth"];
    }
    if (![self.txtEmail.text isEqualToString:@""])  {
        [dic setObject:txtEmail.text forKey:@"email"];
    }
    if ((self.manBtn.tag == TagOn) && (self.womanBtn.tag == TagOff)) {
        [dic setObject:@"0" forKey:@"sex"];
    }else if ((self.womanBtn.tag == TagOn) && (self.manBtn.tag == TagOff)) {
        [dic setObject:@"1" forKey:@"sex"];
    }
    [dic setObject:[DataService sharedService].store_id forKey:@"store_id"];
    NSDictionary *brand  = [brandList objectAtIndex:[brandView selectedRowInComponent:0]];
    NSString *brandStr = [brand objectForKey:@"id"];
    NSString *modelStr = @"";
    if ([[brand objectForKey:@"models"] count]>0) {
        modelStr = [[[brand objectForKey:@"models"] objectAtIndex:[modelView selectedRowInComponent:0]] objectForKey:@"id"];
    }
    [dic setObject:[NSString stringWithFormat:@"%@_%@",brandStr,modelStr] forKey:@"brand"];
    [r setPostDataEncoding:NSUTF8StringEncoding];
    [r setPOSTDictionary:dic];
    
    NSError *error = nil;
    NSString *str = [r startSynchronousWithError:&error];
    NSDictionary *result = [str objectFromJSONString];
    DLog(@"%@",result);
    if ([[result objectForKey:@"status"] intValue]==1) {
        [AHAlertView applyCustomAlertAppearance];
        AHAlertView *alertt = [[AHAlertView alloc] initWithTitle:kTip message:@"登记信息成功"];
        __block AHAlertView *alert = alertt;
        [alertt setCancelButtonTitle:@"确定" block:^{
            alert.dismissalStyle = AHAlertViewDismissalStyleTumble;
            alert = nil;
            [self.navigationController popToRootViewControllerAnimated:YES];
        }];
        [alertt show];
        
    }else {
        [AHAlertView applyCustomAlertAppearance];
        AHAlertView *alertt = [[AHAlertView alloc] initWithTitle:kTip message:[result objectForKey:@"content"]];
        __block AHAlertView *alert = alertt;
        [alertt setCancelButtonTitle:@"确定" block:^{
            alert.dismissalStyle = AHAlertViewDismissalStyleTumble;
            alert = nil;
        }];
        [alertt show];
    }
    [MBProgressHUD hideHUDForView:self.view animated:YES];

}
//完成下单
-(void)finishOrder {
    if (selectedIndexs && selectedIndexs.count > 0) {
        STHTTPRequest *r = [STHTTPRequest requestWithURLString:[NSString stringWithFormat:@"%@%@",[DataService sharedService].kHost,kFinish]];
        NSDictionary *brand  = [brandList objectAtIndex:[brandView selectedRowInComponent:0]];
        NSString *brandStr = [brand objectForKey:@"id"];
        NSString *modelStr = @"";
        if (![[brand objectForKey:@"models"] isKindOfClass:[NSNull class]]) {
            modelStr = [[[brand objectForKey:@"models"] objectAtIndex:[modelView selectedRowInComponent:0]] objectForKey:@"id"];
        }
        NSMutableString *prod_ids = [NSMutableString string];
        for (NSIndexPath *idx in selectedIndexs) {
            NSDictionary *prod = [[self.productList objectAtIndex:idx.row] objectAtIndex:idx.section];
            [prod_ids appendFormat:@"%@_%d,",[prod objectForKey:@"id"],idx.row];
        }
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setObject:txtCarNum.text forKey:@"carNum"];
        [dic setObject:txtName.text forKey:@"userName"];
        [dic setObject:txtPhone.text forKey:@"phone"];
        [dic setObject:txtCarYear.text forKey:@"year"];
        if (![self.txtBirth.text isEqualToString:@""] && (![self.txtBirth.text isKindOfClass:[NSNull class]])) {
            [dic setObject:txtBirth.text forKey:@"birth"];
        }
        if (![self.txtEmail.text isEqualToString:@""] && (![self.txtEmail.text isKindOfClass:[NSNull class]]))  {
            [dic setObject:txtEmail.text forKey:@"email"];
        }
        if ((self.manBtn.tag == TagOn) && (self.womanBtn.tag == TagOff)) {
            [dic setObject:@"0" forKey:@"sex"];
        }else if ((self.womanBtn.tag == TagOn) && (self.manBtn.tag == TagOff)) {
            [dic setObject:@"1" forKey:@"sex"];
        }
        
        if ([modelStr intValue] == 0) {
            [dic setObject:[NSString stringWithFormat:@"%@",brandStr] forKey:@"brand"];
        }else {
           [dic setObject:[NSString stringWithFormat:@"%@_%@",brandStr,modelStr] forKey:@"brand"]; 
        }
        
        [dic setObject:prod_ids forKey:@"prod_ids"];
        [dic setObject:[DataService sharedService].store_id forKey:@"store_id"];
        if ([customer objectForKey:@"reserv_at"]) {
            [dic setObject:[customer objectForKey:@"reserv_at"] forKey:@"res_time"];
        }
        
        [r setPostDataEncoding:NSUTF8StringEncoding];
        [r setPOSTDictionary:dic];
        NSError *error = nil;
        
        NSString *dicc = [r startSynchronousWithError:&error];
        NSDictionary *result = [dicc objectFromJSONString]; 

        if ([[result objectForKey:@"status"] intValue]==1) {
            ConfirmViewController *confirmView = [[ConfirmViewController alloc] initWithNibName:@"ConfirmViewController" bundle:nil];
            confirmView.productList = [NSMutableArray array];
            if ([result objectForKey:@"info"]) {
                confirmView.orderInfo = [result objectForKey:@"info"];
            }
            if ([result objectForKey:@"products"]) {
                [confirmView.productList addObjectsFromArray:[result objectForKey:@"products"]];
            }
            if ([result objectForKey:@"sales"]) {
                [confirmView.productList addObjectsFromArray:[result objectForKey:@"sales"]];
            }
            if ([result objectForKey:@"svcards"]) {
                [confirmView.productList addObjectsFromArray:[result objectForKey:@"svcards"]];
            }
            if ([result objectForKey:@"pcards"]) {
                [confirmView.productList addObjectsFromArray:[result objectForKey:@"pcards"]];
            }
            if ([[result objectForKey:@"total"] floatValue] <0) {
                confirmView.total_count = 0.0;
                confirmView.total_count_temp = [[result objectForKey:@"total"] floatValue];
            }else {
                confirmView.total_count = [[result objectForKey:@"total"] floatValue];
            }
            [DataService sharedService].total_count = confirmView.total_count;//总价放到单例去
            [self.navigationController pushViewController:confirmView animated:YES];
        }else{
            [AHAlertView applyCustomAlertAppearance];
            AHAlertView *alertt = [[AHAlertView alloc] initWithTitle:kTip message:[result objectForKey:@"content"]];
            __block AHAlertView *alert = alertt;
            [alertt setCancelButtonTitle:@"确定" block:^{
                alert.dismissalStyle = AHAlertViewDismissalStyleTumble;
                alert = nil;
            }];
            [alertt show];
        }
        
    }else{
        [AHAlertView applyCustomAlertAppearance];
        AHAlertView *alertt = [[AHAlertView alloc] initWithTitle:kTip message:@"请选择所需的产品、服务"];
        __block AHAlertView *alert = alertt;
        [alertt setCancelButtonTitle:@"确定" block:^{
            alert.dismissalStyle = AHAlertViewDismissalStyleTumble;
            alert = nil;
        }];
        [alertt show];
    }
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}
- (IBAction)clickFinished:(id)sender{
    if ([DataService sharedService].number == 1) {
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
           
            NSString *str = @"";
            if(txtName.text.length==0){
                str = @"请输入您的名称";
            }else {
                //判断联系电话
                if(txtPhone.text.length == 0){
                    str = @"请输入联系电话";
                }else {
                    NSString *regexCall = @"((\\d{11})|^((\\d{7,8})|(\\d{4}|\\d{3})-(\\d{7,8})|(\\d{4}|\\d{3})-(\\d{7,8})-(\\d{4}|\\d{3}|\\d{2}|\\d{1})|(\\d{7,8})-(\\d{4}|\\d{3}|\\d{2}|\\d{1}))|(((\\+86)|(86))?+\\d{11})$)";
                    NSPredicate *predicateCall = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regexCall];
                    if ([predicateCall evaluateWithObject:txtPhone.text]) {
                        
                    }else {
                        str = @"请输入准确的联系电话";
                    }
                }
                //判断生日
                if (txtBirth.text.length == 0) {
//                    str = @"请输入出生年月日";
                }else {
                    
                    NSString *regexCall =@"((19[0-9]{2})|(2[0-9]{3})）-((1[0-2])|(0[1-9]))-((0[1-9])|([1-2][0-9])|3[0-1])";
                    NSPredicate *predicateCall = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regexCall];
                    if ([predicateCall evaluateWithObject:txtBirth.text]) {
                        //获取年份
                        NSDate *now = [NSDate date];
                        NSCalendar *calendar = [NSCalendar currentCalendar];
                        NSUInteger unitFlags = NSYearCalendarUnit  | NSMonthCalendarUnit | NSDayCalendarUnit;
                        NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:now];
                        int year = [dateComponent year];
                        int month = [dateComponent month];
                        int day = [dateComponent day];
                        
                        NSArray *arr = [txtBirth.text componentsSeparatedByString:@"-"];
                        int brith_year = [[arr objectAtIndex:0] intValue];
                        int birth_month = [[arr objectAtIndex:1]intValue];
                        int birth_day = [[arr objectAtIndex:2]intValue];
                        
                        if (brith_year > year) {
                            str = @"请输入准确的出生年份";
                        }else if ((brith_year==year) && (birth_month > month)) {
                            str = @"请输入准确的出生月份";
                        }else if ((brith_year==year) && (birth_month == month) && (birth_day >= day)) {
                            str = @"请输入准确的出生日子";
                        }
                    }
                }
                //判断邮箱
                if (self.txtEmail.text.length == 0) {
//                    str = @"请输入QQ/微信/邮箱地址";
                }
            }
            if (self.txtName.text.length==0 || self.txtPhone.text.length==0 || ![str isEqualToString:@""]) {
                [AHAlertView applyCustomAlertAppearance];
                AHAlertView *alertt = [[AHAlertView alloc] initWithTitle:kTip message:str];
                __block AHAlertView *alert = alertt;
                [alertt setCancelButtonTitle:@"确定" block:^{
                    alert.dismissalStyle = AHAlertViewDismissalStyleTumble;
                    alert = nil;
                }];
                [alertt show];
            }else {
                MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
                hud.dimBackground = NO;
                [hud showWhileExecuting:@selector(finishInfo) onTarget:self withObject:nil animated:YES];
                hud.labelText = @"正在努力加载...";
                [self.view addSubview:hud];
            }
        }
    }else {
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
            [hud showWhileExecuting:@selector(finishOrder) onTarget:self withObject:nil animated:YES];
            hud.labelText = @"正在努力加载...";
            [self.view addSubview:hud];
        }
    }
}

//上一步，下一步
- (IBAction)clickNext:(id)sender{
    UIButton *btn = (UIButton *)sender;
    int x = [step intValue];
    
    if (btn.tag == 102) {
        x -= 1;
    }else{
        NSString *str = @"";
        if (x==0 && txtCarNum.text.length==0) {
            str = @"请输入你的车牌号";
        }
        //判断购车时间
        else if(x==1){
            //获取年份
            NSDate *now = [NSDate date];
            NSCalendar *calendar = [NSCalendar currentCalendar];
            NSUInteger unitFlags = NSYearCalendarUnit;
            NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:now];
            int year = [dateComponent year];
            
            if (txtCarYear.text.length == 0) {
                str = @"请输入购车时间";
            }else {
                //判断年份
                NSString *regexCall = @"(19[0-9]{2})|(2[0-9]{3})";
                NSPredicate *predicateCall = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regexCall];
                if ([predicateCall evaluateWithObject:txtCarYear.text]) {
                    int car_year = [txtCarYear.text intValue];
                    if (car_year > year) {
                        str = @"请输入准确的购车时间";
                    }
                }else {
                    str = @"请输入准确的购车时间";
                }
            }
        }
        else if(x==2){
            if(txtName.text.length==0){
                str = @"请输入您的名称";
            }else {
                //判断联系电话
                if(txtPhone.text.length == 0){
                    str = @"请输入联系电话";
                }else {
                    NSString *regexCall = @"((\\d{11})|^((\\d{7,8})|(\\d{4}|\\d{3})-(\\d{7,8})|(\\d{4}|\\d{3})-(\\d{7,8})-(\\d{4}|\\d{3}|\\d{2}|\\d{1})|(\\d{7,8})-(\\d{4}|\\d{3}|\\d{2}|\\d{1}))|(((\\+86)|(86))?+\\d{11})$)";
                    NSPredicate *predicateCall = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regexCall];
                    if ([predicateCall evaluateWithObject:txtPhone.text]) {
                        
                    }else {
                        str = @"请输入准确的联系电话";
                    }
                }
                //判断生日
                if (txtBirth.text.length == 0) {
//                    str = @"请输入出生年月日";
                }else {
                    NSString *regexCall =@"((19[0-9]{2})|(2[0-9]{3})）-((1[0-2])|(0[1-9]))-((0[1-9])|([1-2][0-9])|3[0-1])";
                    NSPredicate *predicateCall = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regexCall];
                    if ([predicateCall evaluateWithObject:txtBirth.text]) {
                        //获取年份
                        NSDate *now = [NSDate date];
                        NSCalendar *calendar = [NSCalendar currentCalendar];
                        NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
                        NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:now];
                        int year = [dateComponent year];
                        int month = [dateComponent month];
                        int day = [dateComponent day];
                        
                        NSArray *arr = [txtBirth.text componentsSeparatedByString:@"-"];
                        int brith_year = [[arr objectAtIndex:0] intValue];
                        int birth_month = [[arr objectAtIndex:1]intValue];
                        int birth_day = [[arr objectAtIndex:2]intValue];
                        
                        if (brith_year > year) {
                            str = @"请输入准确的出生年份";
                        }else if ((brith_year==year) && (birth_month > month)) {
                            str = @"请输入准确的出生月份";
                        }else if ((brith_year==year) && (birth_month == month) && (birth_day >= day)) {
                            str = @"请输入准确的出生日子";
                        }
                    }
                }
                //判断邮箱
                if (self.txtEmail.text.length == 0) {
//                    str = @"请输入邮箱地址";
                }
            }
        }
        if (str.length==0) {
           x += 1; 
        }else{
            [AHAlertView applyCustomAlertAppearance];
            AHAlertView *alertt = [[AHAlertView alloc] initWithTitle:kTip message:str];
            __block AHAlertView *alert = alertt;
            [alertt setCancelButtonTitle:@"确定" block:^{
                alert.dismissalStyle = AHAlertViewDismissalStyleTumble;
                alert = nil;
            }];
            [alertt show];
        }
        
    }
    [self.stepImg setImage:[UIImage imageNamed:[NSString stringWithFormat:@"step_%d",x]]];
    step = [NSString stringWithFormat:@"%d",x];
    [self initView];
}

//拍照
- (void)getCarPicture:(PictureCell *)cell{
    GetPictureFromDevice *pic = [[GetPictureFromDevice alloc] initWithParentViewController:self];
    self.getPic = pic;
    self.getPic.delegate = self;
    self.getPic.fileType = kPhotoType;
    self.getPic.picCell = cell;
    [self.getPic takePhotoWithCamera];
}

- (void)didGetFileWithFile:(GetPictureFromDevice *)getFile{
    PictureCell *cell = (PictureCell *)self.getPic.picCell;
    cell.carImageView.image = [UIImage imageWithData:[getFile fileData]];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerVieww numberOfRowsInComponent:(NSInteger)component{
    
    if ([pickerVieww isEqual:modelView]) {
        NSDictionary *brand  = [brandList objectAtIndex:[brandView selectedRowInComponent:0]];
        if ([[brand objectForKey:@"models"] isKindOfClass:[NSNull class]]) {
            return 0;
        }else {
            return [[brand objectForKey:@"models"] count];
        }
    }
    return self.brandList.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerVieww titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    
    if ([pickerVieww isEqual:modelView]) {
        NSDictionary *brand  = [brandList objectAtIndex:[brandView selectedRowInComponent:0]];
        if ([[brand objectForKey:@"models"] count]>0) {
            return [[[brand objectForKey:@"models"] objectAtIndex:row] objectForKey:@"name"];
        }else{
            return @"";
        }
        
    }else{
        NSDictionary *brand  = [brandList objectAtIndex:row];
        return [brand objectForKey:@"name"];
    }
}

- (void)pickerView:(UIPickerView *)pickerVieww didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    if ([pickerVieww isEqual:brandView]) {
        [modelView reloadAllComponents];
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return 4;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return [[self.brandResult objectForKey:@"count"] integerValue];
}

//产品，服务的单元格
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"CollectionCell";
    CollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.prodName.hidden = YES;
    cell.prodImage.hidden = YES;
    cell.contentView.backgroundColor = [UIColor clearColor];
    for (int x=0; x<4; x++) {
        if (indexPath.row == x) {
            
            int len = [[self.productList objectAtIndex:x] count];
            if (indexPath.section < len) {
                NSDictionary *prod = [[self.productList objectAtIndex:x] objectAtIndex:indexPath.section];
                cell.prodName.text = [NSString stringWithFormat:@"%@",[prod objectForKey:@"name"]];
                cell.prodName.hidden = NO;
                cell.prodImage.hidden = NO;
                //预约页面首次进来  加载此项
                if ([DataService sharedService].ReservationFirst == YES) {
                    if (self.product_ids.count >0  && x<3) {
                        NSString *p_id = [prod objectForKey:@"id"];
                        if ([product_ids containsObject:p_id]) {
                            cell.contentView.backgroundColor = [UIColor redColor];
                            [selectedIndexs addObject:indexPath];
                        }
                    }
                }
                /////////////////
                if ([self isSelected:indexPath]) {
                    cell.contentView.backgroundColor = [UIColor redColor];
                }else{
                    cell.contentView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"collectioncell_bg"]];
                }
                
                if ([DataService sharedService].number == 0){
                    cell.prodImage.image = [[self.picArray objectAtIndex:x]objectAtIndex:indexPath.section];
                }
            }else{
                cell.prodName.hidden = YES;
                cell.prodImage.hidden = YES;
                cell.contentView.backgroundColor = [UIColor clearColor];
            }
        }
    }
    
    //****************判断cell是否已被选中
    if ([self.selectedIndexs containsObject:indexPath]) {
        cell.backgroundColor = [UIColor redColor];
    }else{
        cell.backgroundColor = [UIColor clearColor];
    }

    
    return cell;

}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    if (section==0) {
        return CGSizeZero;
    }
    return CGSizeZero;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    return TRUE;
}

//设置选中效果
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    CollectionCell *cell = (CollectionCell *)[collectionView cellForItemAtIndexPath:indexPath];
    [DataService sharedService].ReservationFirst = NO;
    if (cell.prodName.hidden == NO) {
        if (cell.backgroundColor == [UIColor redColor]) {
            cell.backgroundColor = [UIColor whiteColor];
            if ([self isSelected:indexPath]) {
                [selectedIndexs removeObject:indexPath];
            }
        }else{
            cell.backgroundColor = [UIColor redColor];
            if (![self isSelected:indexPath]) {
                [selectedIndexs addObject:indexPath];
            }
        }
    }
    //***************刷新页面
    [self.productsView reloadData];
}

- (BOOL)isSelected:(NSIndexPath *)indexPath{
    //*****************判断是否选中行已添加进数组
    if ([self.selectedIndexs containsObject:indexPath]) {
        return YES;
    }
    return NO;
}

-(IBAction)manBtnPressed:(id)sender {
    if (self.manBtn.tag == TagOn) {
        self.manBtn.tag = TagOff;
        [self.manBtn setImage:[UIImage imageNamed:@"cb_mono_off"] forState:UIControlStateNormal];
    }else if (self.manBtn.tag == TagOff) {
        self.manBtn.tag = TagOn;
        [self.manBtn setImage:[UIImage imageNamed:@"cb_mono_on"] forState:UIControlStateNormal];
        if (self.womanBtn.tag == TagOn) {
            self.womanBtn.tag = TagOff;
            [self.womanBtn setImage:[UIImage imageNamed:@"cb_mono_off"] forState:UIControlStateNormal];
        }
    }
}
-(IBAction)womanBtnPressed:(id)sender {
    if (self.womanBtn.tag == TagOn) {
        self.womanBtn.tag = TagOff;
        [self.womanBtn setImage:[UIImage imageNamed:@"cb_mono_off"] forState:UIControlStateNormal];
    }else if (self.womanBtn.tag == TagOff) {
        self.womanBtn.tag = TagOn;
        [self.womanBtn setImage:[UIImage imageNamed:@"cb_mono_on"] forState:UIControlStateNormal];
        if (self.manBtn.tag == TagOn) {
            self.manBtn.tag = TagOff;
            [self.manBtn setImage:[UIImage imageNamed:@"cb_mono_off"] forState:UIControlStateNormal];
        }
    }
}
@end
