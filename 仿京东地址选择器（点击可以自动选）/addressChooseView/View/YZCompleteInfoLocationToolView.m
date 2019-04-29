//
//  YZCompleteInfoLocationToolView.m
//  yz
//
//  Created by yz on 2019/2/23.
//  Copyright © 2019年 yz. All rights reserved.
//

#import "YZCompleteInfoLocationToolView.h"
#import "ZHFProvinceModel.h"
#import "ZHFCityModel.h"
#import "CountyModel.h"
#import "YZLoginCompleteAddTitleAddressViewCell.h"
#import "MJExtension.h"

//设备物理尺寸
#define SCW [UIScreen mainScreen].bounds.size.width
#define SCH [UIScreen mainScreen].bounds.size.height
#define RGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface YZCompleteInfoLocationToolView ()<UIScrollViewDelegate,UIGestureRecognizerDelegate,UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,strong)UIScrollView *titleScrollView;
@property(nonatomic,strong)UIScrollView *contentScrollView;
@property(nonatomic,strong)UIButton *radioBtn;
@property(nonatomic,strong)NSMutableArray *titleBtns;
/**被选中后放在上面那个*/
@property(nonatomic,strong)NSMutableArray *titleMarr;
@property(nonatomic,strong)NSMutableArray *tableViewMarr;
@property(nonatomic,strong)UILabel *lineLabel;
@property(nonatomic,strong)NSMutableArray *titleIDMarr;
@property(nonatomic,assign)BOOL isInitalize;
@property(nonatomic,assign)BOOL isclick; //判断是滚动还是点击
@property(nonatomic,strong)NSMutableArray *provinceMarr;//省
@property(nonatomic,strong)NSMutableArray *cityMarr;//市
@property(nonatomic,strong)NSMutableArray *countyMarr;//县
@property(nonatomic,strong)NSArray *resultArr;//本地数组
/**判断是选中还是取消*/
@property (assign, nonatomic) NSInteger selectRow1;
@property (assign, nonatomic) NSInteger selectRow2;
@property (assign, nonatomic) NSInteger selectRow3;
@property (strong, nonatomic) NSMutableArray *multipleTitleArray;
@property (strong, nonatomic) NSMutableArray *beginSelectRowArray;
@end
@implementation YZCompleteInfoLocationToolView
-(UIView *)initAddressViewWithContentString:(NSString *)contentString
{
    //初始化本地数据
    NSString *imagePath = imagePath = [[NSBundle mainBundle] pathForResource:@"location" ofType:@"txt"];
    self.title = @"选择地区";
    NSString *string = [[NSString alloc] initWithContentsOfFile:imagePath encoding:NSUTF8StringEncoding error:nil];
    NSData * resData = [[NSData alloc]initWithData:[string dataUsingEncoding:NSUTF8StringEncoding]];
    _resultArr = [NSJSONSerialization JSONObjectWithData:resData options:NSJSONReadingMutableLeaves error:nil];
    
    NSArray *selectArray= [contentString componentsSeparatedByString:@"-"];
    
    NSString *firsetId = @"0";
    NSString *secondId = @"0";
    
    NSMutableArray *firstArray = [[NSMutableArray alloc] init];
    NSMutableArray *secondArray = [[NSMutableArray alloc] init];
    NSMutableArray *thirdArray = [[NSMutableArray alloc] init];
    
    if (selectArray.count) {
        /**找到parentid为0的所有省*/
        for (int i = 0; i<self.resultArr.count; i++) {
            if ([@"0" isEqualToString:self.resultArr[i][@"parentid"]]) {
                [firstArray addObject:self.resultArr[i]];
            }
        }
        
        /**取得第一个被选中的row，根据名字找到id*/
        for (int i = 0; i<firstArray.count; i++) {
            if ([selectArray[0] isEqualToString:firstArray[i][@"name"]]) {
                [self.beginSelectRowArray addObject:[NSNumber numberWithInteger:i]];
                firsetId = firstArray[i][@"id"];
                break;
            }
        }
        
        /**通过上面的id找到以这个id为parentid的所有数据，加入数组secondArray中*/
        for (int i = 0; i<self.resultArr.count; i++) {
            if ([firsetId isEqualToString:self.resultArr[i][@"parentid"]]) {
                [secondArray addObject:self.resultArr[i]];
            }
        }
        
        if (selectArray.count > 1) {
            /**在secondArray数组中，找到第二个相等的name,并加入到beginSelectRowArray数组中，并根据名字得到id*/
            for (int i = 0; i<secondArray.count; i++) {
                if ([selectArray[1] isEqualToString:secondArray[i][@"name"]]) {
                    [self.beginSelectRowArray addObject:[NSNumber numberWithInteger:i]];
                    secondId = secondArray[i][@"id"];
                    break;
                }
            }
            
            /**通过上面的id找到以这个id为parentid的所有数据，加入数组thirdArray中*/
            for (int i = 0; i<self.resultArr.count; i++) {
                if ([secondId isEqualToString:self.resultArr[i][@"parentid"]]) {
                    [thirdArray addObject:self.resultArr[i]];
                }
            }
            
            if (selectArray.count > 2) {
                /**在thirdArray数组中，找到第三个相等的name,并加入到beginSelectRowArray数组中*/
                for (int i = 0; i<thirdArray.count; i++) {
                    if ([selectArray[2] isEqualToString:thirdArray[i][@"name"]]) {
                        [self.beginSelectRowArray addObject:[NSNumber numberWithInteger:i]];
                        break;
                    }
                }
            }
        }
    }
    
    self.frame = CGRectMake(0, 0, SCW, SCH);
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
    self.hidden = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapBtnAndcancelBtnClick)];
    tap.delegate = self;
    [self addGestureRecognizer:tap];
    //设置添加地址的View
    self.addAddressView = [[UIView alloc]init];
    self.addAddressView.frame = CGRectMake(0, 0, SCW, _defaultHeight);
    self.addAddressView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.addAddressView];
    UILabel * titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 20, SCW - 80, 25)];
    titleLabel.text = _title;
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.textColor = RGB(0x333333);
    titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [self.addAddressView addSubview:titleLabel];
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelBtn.frame =CGRectMake(CGRectGetMaxX(self.addAddressView.frame) - 15 - 12, 25, 12, 12);
    cancelBtn.tag = 1;
    [cancelBtn setImage:[UIImage imageNamed:@"zhuxezuanzeguanbi"] forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(tapBtnAndcancelBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.addAddressView addSubview:cancelBtn];
    
    [self addTableViewAndTitle:0];
    //1.添加标题滚动视图
    [self setupTitleScrollView];
    //2.添加内容滚动视图
    [self setupContentScrollView];
    [self setupAllTitle:0];
    
    if (self.beginSelectRowArray.count) {
        ZHFProvinceModel * provinceModel = self.provinceMarr[[self.beginSelectRowArray[0] intValue]];
        provinceModel.isShowImageView = YES;
        [self.provinceMarr replaceObjectAtIndex:[self.beginSelectRowArray[0] intValue] withObject:provinceModel];
        [self.multipleTitleArray addObject:provinceModel.province_name];
        NSString * provinceID = [NSString stringWithFormat:@"%ld",(long)provinceModel.id];
        [self.titleIDMarr replaceObjectAtIndex:0 withObject:provinceID];
        [self.titleMarr replaceObjectAtIndex:0 withObject:provinceModel.province_name];
        self.selectRow1 = [self.beginSelectRowArray[0] intValue];
        [self getAddressMessageDataAddressID:2 provinceIdOrCityId:provinceID];
        if (self.beginSelectRowArray.count == 1) {
            return self;
        }
        
        ZHFCityModel * cityModel = self.cityMarr[[self.beginSelectRowArray[1] intValue]];
        cityModel.isShowImageView = YES;
        [self.cityMarr replaceObjectAtIndex:[self.beginSelectRowArray[1] intValue] withObject:cityModel];
        [self.multipleTitleArray addObject:cityModel.city_name];
        NSString * cityID = [NSString stringWithFormat:@"%ld",(long)cityModel.id];
        [self.titleIDMarr replaceObjectAtIndex:1 withObject:cityID];
        [self.titleMarr replaceObjectAtIndex:1 withObject:cityModel.city_name];
        self.selectRow2 = [self.beginSelectRowArray[1] intValue];
        [self setupAllTitle:1];
        [self getAddressMessageDataAddressID:3 provinceIdOrCityId:cityID];
        if (self.beginSelectRowArray.count == 2) {
            return self;
        }
        
        CountyModel * countyModel = self.countyMarr[[self.beginSelectRowArray[2] intValue]];
        countyModel.isShowImageView = YES;
        [self.countyMarr replaceObjectAtIndex:[self.beginSelectRowArray[2] intValue] withObject:countyModel];
        [self.multipleTitleArray addObject:countyModel.county_name];
        NSString * countyID = [NSString stringWithFormat:@"%ld",(long)countyModel.id];
        [self.titleIDMarr replaceObjectAtIndex:2 withObject:countyID];
        [self.titleMarr replaceObjectAtIndex:2 withObject:countyModel.county_name];
        self.selectRow3 = [self.beginSelectRowArray[2] intValue];
        [self setupAllTitle:2];
    }
    
    return self;
}

-(void)addAnimate{
    self.hidden = NO;
    
    self.addAddressView.frame = CGRectMake(0, SCH, self.addAddressView.frame.size.width, self.addAddressView.frame.size.height);
    [UIView animateWithDuration:0.3 animations:^{
        self.addAddressView.frame = CGRectMake(0, SCH - self.defaultHeight, SCW, self.defaultHeight);
    }];
}

-(void)tapBtnAndcancelBtnClick{
    self.hidden = NO;
    [UIView animateWithDuration:0.2 animations:^{
        self.addAddressView.frame = CGRectMake(0, SCH, SCW, 200);
    } completion:^(BOOL finished) {
        self.hidden = YES;
        
        NSMutableString * titleAddress = [[NSMutableString alloc]init];
        NSMutableString * titleID = [[NSMutableString alloc]init];
        NSInteger  count = 0;
        NSString * str = self.titleMarr[self.titleMarr.count - 1];
        if ([str isEqualToString:@"请选择"]) {
            count = self.titleMarr.count - 1;
        }else{
            count = self.titleMarr.count;
        }
        
        for (int i = 0; i<self.titleMarr.count ; i++) {
            [titleAddress appendString:[[NSString alloc]initWithFormat:@"%@-",self.titleMarr[i]]];
            [titleID appendString:[[NSString alloc]initWithFormat:@"%@-",self.titleIDMarr[i]]];
        }
        
        if (count) {
            [self.delegate cancelBtnClick:[titleAddress substringToIndex:titleAddress.length - 1] titleID:[titleID substringToIndex:titleID.length - 1]];
        }
    }];
}

-(void)setupTitleScrollView{
    //TitleScrollView和分割线
    self.titleScrollView = [[UIScrollView alloc]init];
    self.titleScrollView.frame = CGRectMake(0, 45, SCW, _titleScrollViewH);
    [self.addAddressView addSubview:self.titleScrollView];
    UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.titleScrollView.frame), SCW, 0.5)];
    lineView.backgroundColor = RGB(0xEEF1F7);
    [self.addAddressView addSubview:(lineView)];
}

-(void)setupContentScrollView{//ContentScrollView
    CGFloat y  =  CGRectGetMaxY(self.titleScrollView.frame) + 1;
    self.contentScrollView = [[UIScrollView alloc]init];
    self.contentScrollView.frame = CGRectMake(0, y, SCW, self.defaultHeight - y);
    [self.addAddressView addSubview:self.contentScrollView];
    self.contentScrollView.delegate = self;
    self.contentScrollView.pagingEnabled = YES;
    self.contentScrollView.bounces = NO;
}

-(void)setupAllTitle:(NSInteger)selectId{
    for ( UIView * view in [self.titleScrollView subviews]) {
        [view removeFromSuperview];
    }
    [self.titleBtns removeAllObjects];
    CGFloat btnH = self.titleScrollViewH;
    _lineLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 1, 1)];
    _lineLabel.backgroundColor = RGB(0x86B93F);
    [self.titleScrollView addSubview:(_lineLabel)];
    CGFloat x = 32;
    NSLog(@"%@",self.titleMarr);
    for (int i = 0; i < self.titleMarr.count ; i++) {
        NSString   *title = self.titleMarr[i];
        CGFloat titlelenth = title.length * 15;
        UIButton *titleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [titleBtn setTitle:title forState:UIControlStateNormal];
        titleBtn.tag = i;
        [titleBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [titleBtn setTitleColor:RGB(0x86B93F) forState:UIControlStateSelected];
        titleBtn.selected = NO;
        titleBtn.frame = CGRectMake(x, 0, titlelenth, btnH);
        x  = titlelenth + 10 + x;
        [titleBtn.titleLabel setFont:[UIFont systemFontOfSize:13.0]];
        [titleBtn addTarget:self action:@selector(titleBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.titleBtns addObject:titleBtn];
        if (i == selectId) {
            [self titleBtnClick:titleBtn];
        }
        [self.titleScrollView addSubview:(titleBtn)];
        self.titleScrollView.contentSize =CGSizeMake(x, 0);
        self.titleScrollView.showsHorizontalScrollIndicator = NO;
        self.contentScrollView.contentSize = CGSizeMake(self.titleMarr.count * SCW, 0);
        self.contentScrollView.showsHorizontalScrollIndicator = NO;
    }
}

-(void)titleBtnClick:(UIButton *)titleBtn{
    self.radioBtn.selected = NO;
    titleBtn.selected = YES;
    [self setupOneTableView:titleBtn.tag];
    CGFloat x  = titleBtn.tag * SCW;
    self.contentScrollView.contentOffset = CGPointMake(x, 0);
    self.lineLabel.frame = CGRectMake(CGRectGetMinX(titleBtn.frame) + 6, self.titleScrollViewH - 1,titleBtn.frame.size.width - 6*2, 1);
    self.radioBtn = titleBtn;
    self.isclick = YES;
}

-(void)setupOneTableView:(NSInteger)btnTag{
    UITableView  *contentView = self.tableViewMarr[btnTag];
    if  (btnTag == 0) {
        [self getAddressMessageDataAddressID:1 provinceIdOrCityId:0];
    }
    if (contentView.superview != nil) {
        return;
    }
    CGFloat  x= btnTag * SCW;
    contentView.frame = CGRectMake(x, 0, SCW, self.contentScrollView.bounds.size.height);
    contentView.delegate = self;
    contentView.dataSource = self;
    
    NSInteger beginSelectRow = 0;
    switch (btnTag) {
        case 0:
            beginSelectRow = self.selectRow1;
            break;
        case 1:
            beginSelectRow = self.selectRow2;
            break;
        case 2:
            beginSelectRow = self.selectRow3;
            break;
        default:
            break;
    }
    
    if (beginSelectRow > 0) {
        [contentView selectRowAtIndexPath:[NSIndexPath indexPathForItem:beginSelectRow inSection:0] animated:YES scrollPosition:UITableViewScrollPositionTop];
    }
    
    
    [self.contentScrollView addSubview:(contentView)];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    NSInteger leftI  = scrollView.contentOffset.x / SCW;
    if (scrollView.contentOffset.x / SCW != leftI){
        self.isclick = NO;
    }
    if (self.isclick == NO) {
        if (scrollView.contentOffset.x / SCW == leftI){
            UIButton * titleBtn  = self.titleBtns[leftI];
            [self titleBtnClick:titleBtn];
        }
    }
}

#pragma mark - UITableViewDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView.tag == 0) {
        return self.provinceMarr.count;
    }else if (tableView.tag == 1) {
        return self.cityMarr.count;
    }else if (tableView.tag == 2){
        return self.countyMarr.count;
    }else{
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    YZLoginCompleteAddTitleAddressViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"YZLoginCompleteAddTitleAddressViewCell"];
    if (tableView.tag == 0) {
        ZHFProvinceModel * provinceModel = self.provinceMarr[indexPath.row];
        cell.provinceModel = provinceModel;
        
    }
    else if (tableView.tag == 1) {
        ZHFCityModel *cityModel = self.cityMarr[indexPath.row];
        cell.cityModel = cityModel;
    }
    else if (tableView.tag == 2){
        CountyModel * countyModel  = self.countyMarr[indexPath.row];
        cell.countyModel = countyModel;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView.tag == 0 || tableView.tag == 1 || tableView.tag == 2){
        if (tableView.tag == 0){
            if (self.selectRow1 >= 0 && (self.selectRow1<self.provinceMarr.count)) {
                ZHFProvinceModel *provinceModel = self.provinceMarr[self.selectRow1];
                YZLoginCompleteAddTitleAddressViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.selectRow1 inSection:0]];
                provinceModel.isShowImageView = NO;
                cell.provinceModel = provinceModel;
            }
            
            ZHFProvinceModel *provinceModel = self.provinceMarr[indexPath.row];
            
            NSString * provinceID = [NSString stringWithFormat:@"%ld",(long)provinceModel.id];
            //1. 修改选中ID
            if (self.titleIDMarr.count > 0){
                [self.titleIDMarr replaceObjectAtIndex:tableView.tag withObject:provinceID];
            }else{
                [self.titleIDMarr addObject:provinceID];
            }
            //2.修改标题
            [self.titleMarr replaceObjectAtIndex:tableView.tag withObject:provinceModel.province_name];
            
            YZLoginCompleteAddTitleAddressViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            provinceModel.isShowImageView = YES;
            cell.provinceModel = provinceModel;
            
            self.selectRow1 = indexPath.row;
            self.selectRow2 = -1;
            self.selectRow3 = -1;
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self getAddressMessageDataAddressID:2 provinceIdOrCityId:provinceID];
            });
        }else if (tableView.tag == 1){
            
            if (self.selectRow2 >= 0 && self.selectRow2<self.cityMarr.count) {
                ZHFCityModel * cityModel = self.cityMarr[self.selectRow2];
                YZLoginCompleteAddTitleAddressViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.selectRow2 inSection:0]];
                cityModel.isShowImageView = NO;
                cell.cityModel = cityModel;
            }
            
            ZHFCityModel * cityModel = self.cityMarr[indexPath.row];
            NSString * cityID = [NSString stringWithFormat:@"%ld",(long)cityModel.id];
            [self.titleMarr replaceObjectAtIndex:tableView.tag withObject:cityModel.city_name];
            //1. 修改选中ID
            if (self.titleIDMarr.count > 1){
                [self.titleIDMarr replaceObjectAtIndex:tableView.tag withObject:cityID];
            }else{
                [self.titleIDMarr addObject:cityID];
            }
            
            [self setupAllTitle:tableView.tag];
            
            YZLoginCompleteAddTitleAddressViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            cityModel.isShowImageView = YES;
            cell.cityModel = cityModel;
            
            self.selectRow2 = indexPath.row;
            self.selectRow3 = -1;
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self getAddressMessageDataAddressID:3 provinceIdOrCityId:cityID];
            });
        }else if (tableView.tag == 2) {
            
            if (self.selectRow3 >= 0 && self.selectRow3<self.countyMarr.count) {
                CountyModel * countyModel = self.countyMarr[self.selectRow3];
                YZLoginCompleteAddTitleAddressViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.selectRow3 inSection:0]];
                countyModel.isShowImageView = NO;
                cell.countyModel = countyModel;
            }
            
            CountyModel * countyModel = self.countyMarr[indexPath.row];
            NSString * countyID = [NSString stringWithFormat:@"%ld",(long)countyModel.id];
            [self.titleMarr replaceObjectAtIndex:tableView.tag withObject:countyModel.county_name];
            //1. 修改选中ID
            if (self.titleIDMarr.count > 2){
                [self.titleIDMarr replaceObjectAtIndex:tableView.tag withObject:countyID];
            }else{
                [self.titleIDMarr addObject:countyID];
            }
            
            [self setupAllTitle:tableView.tag];
            
            YZLoginCompleteAddTitleAddressViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            countyModel.isShowImageView = YES;
            cell.countyModel = countyModel;
            
            self.selectRow3 = indexPath.row;
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self tapBtnAndcancelBtnClick];
            });
        }
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return  35;
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([NSStringFromClass(touch.view.classForCoder) isEqualToString: @"UITableViewCellContentView"] || touch.view == self.addAddressView || touch.view == self.titleScrollView) {
        return NO;
    }
    return YES;
}

//添加tableView和title
-(void)addTableViewAndTitle:(NSInteger)tableViewTag{
    UITableView * tableView2 = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCW, 200) style:UITableViewStylePlain];
    [tableView2 registerNib:[UINib nibWithNibName:@"YZLoginCompleteAddTitleAddressViewCell" bundle:nil] forCellReuseIdentifier:@"YZLoginCompleteAddTitleAddressViewCell"];
    tableView2.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView2.tag = tableViewTag;
    [self.tableViewMarr addObject:tableView2];
    [self.titleMarr addObject:@"请选择"];
    [self.titleIDMarr addObject:@"-1"];
}

//改变title
-(void)changeTitle:(NSInteger)replaceTitleMarrIndex{
    [self.titleMarr replaceObjectAtIndex:replaceTitleMarrIndex withObject:@"请选择"];
    NSInteger index = [self.titleMarr indexOfObject:@"请选择"];
    NSInteger count = self.titleMarr.count;
    NSInteger loc = index + 1;
    NSInteger range = count - index;
    [self.titleMarr removeObjectsInRange:NSMakeRange(loc, range - 1)];
    [self.tableViewMarr removeObjectsInRange:NSMakeRange(loc, range - 1)];
}

//移除多余的title和tableView,收回选择器
-(void)removeTitleAndTableViewCancel:(NSInteger)index{
    NSInteger indexAddOne = index + 1;
    NSInteger indexsubOne = index - 1;
    if (self.tableViewMarr.count >= indexAddOne){
        [self.titleMarr removeObjectsInRange:NSMakeRange(index, self.titleMarr.count - indexAddOne)];
        [self.tableViewMarr removeObjectsInRange:NSMakeRange(index, self.tableViewMarr.count - indexAddOne)];
    }
    [self setupAllTitle:indexsubOne];
    [self tapBtnAndcancelBtnClick];
}

//本地数据
-(void)getAddressMessageDataAddressID:(NSInteger)addressID  provinceIdOrCityId:(NSString *)provinceIdOrCityId{
    if (addressID == 1) {
        [self caseProvinceArr:_resultArr];
    }
    else if(addressID == 2){
        [self caseCityArr:_resultArr withSelectedID:provinceIdOrCityId];
    }
    else if(addressID == 3){
        [self caseCountyArr:_resultArr withSelectedID:provinceIdOrCityId];
    }
    if (self.tableViewMarr.count >= addressID){
        UITableView* tableView1   = self.tableViewMarr[addressID - 1];
        [tableView1 reloadData];
    }
}

/**初始化加载本地数据*/
-(void)caseProvinceArr:(NSArray *)provinceArr{
    if (self.provinceMarr.count) {
        return;
    }
    [self.provinceMarr removeAllObjects];
    if (provinceArr.count > 0){
        for (NSDictionary *dic in provinceArr)
        {
            if ([dic[@"parentid"] isEqualToString:@"0"] || [dic[@"pid"] isEqualToString:@"0"]) {
                NSDictionary * dic1 = @{@"id":dic[@"id"],
                                        @"province_name":dic[@"name"]};
                ZHFProvinceModel *provinceModel = [ZHFProvinceModel mj_objectWithKeyValues:dic1];
                [self.provinceMarr addObject:provinceModel];
            }
        }
    }else{
        [self tapBtnAndcancelBtnClick];
    }
}

-(void)caseCityArr:(NSArray *)cityArr withSelectedID:(NSString *)selectedID{
    [self.cityMarr removeAllObjects];
    for (NSDictionary *dic in cityArr) {
        if ([dic[@"parentid"] isEqualToString:selectedID] || [dic[@"pid"] isEqualToString:selectedID]) {
            NSDictionary * dic1 = @{@"id":dic[@"id"],
                                    @"city_name":dic[@"name"]};
            ZHFCityModel *CityModel = [ZHFCityModel mj_objectWithKeyValues:dic1];
            [self.cityMarr addObject:CityModel];
        }
    }
    
    if (self.tableViewMarr.count >= 2){
        [self changeTitle:1];
    }else{
        [self addTableViewAndTitle:1];
    }
    
    if (self.cityMarr.count > 0) {
        [self setupAllTitle:1];
    }else{
        //没有对应的市
        [self removeTitleAndTableViewCancel:1];
    }
}

-(void)caseCountyArr:(NSArray *)countyArr withSelectedID:(NSString *)selectedID{
    [self.countyMarr removeAllObjects];
    for (NSDictionary *dic in countyArr) {
        if ([dic[@"parentid"] isEqualToString:selectedID]) {
            NSDictionary * dic1 = @{@"id":dic[@"id"],
                                    @"county_name":dic[@"name"]};
            CountyModel *countyModel =  [CountyModel mj_objectWithKeyValues:dic1];
            [self.countyMarr addObject:countyModel];
        }
    }
    if (self.tableViewMarr.count >= 3){
        [self changeTitle:2];
    }else{
        [self addTableViewAndTitle:2];
    }
    
    if (self.countyMarr.count > 0){
        [self setupAllTitle:2];
    }else{//没有对应的县
        [self removeTitleAndTableViewCancel:2];
    }
}

#pragma mark - get
-(NSMutableArray *)titleBtns
{
    if (_titleBtns == nil) {
        _titleBtns = [[NSMutableArray alloc]init];
    }
    return _titleBtns;
}
-(NSMutableArray *)titleMarr
{
    if (_titleMarr == nil) {
        _titleMarr = [[NSMutableArray alloc]init];
    }
    return _titleMarr;
}

-(NSMutableArray *)tableViewMarr
{
    if (_tableViewMarr == nil) {
        _tableViewMarr = [[NSMutableArray alloc]init];
    }
    return _tableViewMarr;
}
-(NSMutableArray *)titleIDMarr
{
    if (_titleIDMarr == nil) {
        _titleIDMarr = [[NSMutableArray alloc]init];
    }
    return _titleIDMarr;
}
-(NSMutableArray *)provinceMarr
{
    if (_provinceMarr == nil) {
        _provinceMarr = [[NSMutableArray alloc]init];
    }
    return _provinceMarr;
}
-(NSMutableArray *)cityMarr
{
    if (_cityMarr == nil) {
        _cityMarr = [[NSMutableArray alloc]init];
    }
    return _cityMarr;
}
-(NSMutableArray *)countyMarr
{
    if (_countyMarr == nil) {
        _countyMarr = [[NSMutableArray alloc]init];
    }
    return _countyMarr;
}

- (NSMutableArray *)multipleTitleArray
{
    if (_multipleTitleArray == nil) {
        _multipleTitleArray = [[NSMutableArray alloc] init];
    }
    return _multipleTitleArray;
}

- (NSMutableArray *)beginSelectRowArray
{
    if (_beginSelectRowArray == nil) {
        _beginSelectRowArray = [[NSMutableArray alloc] init];
    }
    return _beginSelectRowArray;
}
@end
