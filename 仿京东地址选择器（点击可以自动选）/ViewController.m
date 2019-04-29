//
//  ViewController.m
//  仿京东地址选择器（点击可以自动选）
//
//  Created by lsdt on 2019/4/29.
//  Copyright © 2019年 yz. All rights reserved.
//

#import "ViewController.h"
#import "YZCompleteInfoLocationToolView.h"

@interface ViewController ()<ZHFAddTitleAddressViewDelegate, UITextFieldDelegate>
@property(nonatomic,strong)YZCompleteInfoLocationToolView * locationView;
@property (weak, nonatomic) UITextField *textField;
@property (copy, nonatomic) NSString *address;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupTextField];
    [self loadData];
}

- (void)setupTextField
{
    UITextField *textField = [[UITextField alloc] init];
    self.textField = textField;
    self.textField.frame = CGRectMake(50, 100, 240, 44);
    self.textField.borderStyle = UITextBorderStyleLine;
    self.textField.placeholder = @"请输入地址";
    self.textField.delegate = self;
    [self.view addSubview:self.textField];
}

- (void)loadData
{
    /**网络请求获得网络数据，假如获取的地址是：北京市-北京市-朝阳区*/
    self.address = @"北京市-北京市-朝阳区";
    self.textField.text = self.address;
}

- (void)showTitleAddressView
{
    UIWindow *rootWindow = [UIApplication sharedApplication].keyWindow;
    [self.locationView addAnimate];
    [UIView animateWithDuration:0.5 animations:^{
        [rootWindow addSubview:self.locationView];
    }];
    [rootWindow makeKeyWindow];
}

#pragma mark - ZHFAddTitleAddressViewDelegate
-(void)cancelBtnClick:(NSString *)titleAddress titleID:(NSString *)titleID
{
    self.textField.text = titleAddress;
    NSLog(@"%@,%@",titleAddress,titleID);
    /**
     拿到地址信息后，就可以传到自己服务器了
     */
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [self showTitleAddressView];
    return NO;
}

#pragma mark - get
- (YZCompleteInfoLocationToolView *)locationView
{
    if (_locationView == nil) {
        _locationView = [[YZCompleteInfoLocationToolView alloc] init];
        _locationView.title = @"选择地区";
        _locationView.delegate = self;
        _locationView.defaultHeight = [UIScreen mainScreen].bounds.size.height - 118;
        _locationView.titleScrollViewH = 36;
        _locationView.frame = [UIScreen mainScreen].bounds;
        _locationView = [_locationView initAddressViewWithContentString:self.address];
    }
    return _locationView;
}

@end
