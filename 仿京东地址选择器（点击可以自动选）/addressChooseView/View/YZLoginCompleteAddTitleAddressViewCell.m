//
//  YZLoginCompleteAddTitleAddressViewCell.m
//  yz
//
//  Created by yz on 2019/1/30.
//  Copyright © 2019年 yz. All rights reserved.
//

#import "YZLoginCompleteAddTitleAddressViewCell.h"
#define RGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@implementation YZLoginCompleteAddTitleAddressViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGSize size = CGSizeMake(MAXFLOAT, MAXFLOAT);//设置高度宽度的最大限度
    CGRect rect = [self.titleLabel.text boundingRectWithSize:size options:NSStringDrawingUsesFontLeading|NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:13]} context:nil];
    
    CGPoint tempPoint = self.imageView.frame.origin;
    self.imageView.frame = CGRectMake(32 + rect.size.width + 5, tempPoint.y, self.imageView.frame.size.width, self.imageView.frame.size.height);
}

- (void)setProvinceModel:(ZHFProvinceModel *)provinceModel
{
    _provinceModel = provinceModel;
    self.titleLabel.text = provinceModel.province_name;
    
    if (provinceModel.isShowImageView) {
        self.imageView.hidden = NO;
        self.titleLabel.textColor = RGB(0x86B93F);
    }else{
        self.imageView.hidden = YES;
        self.titleLabel.textColor = RGB(0x333333);
    }
}

- (void)setCityModel:(ZHFCityModel *)cityModel
{
    _cityModel = cityModel;
    self.titleLabel.text = cityModel.city_name;
    
    if (cityModel.isShowImageView) {
        self.imageView.hidden = NO;
        self.titleLabel.textColor = RGB(0x86B93F);
    }else{
        self.imageView.hidden = YES;
        self.titleLabel.textColor = RGB(0x333333);
    }
}

- (void)setCountyModel:(CountyModel *)countyModel
{
    _countyModel = countyModel;
    self.titleLabel.text = countyModel.county_name;
    
    if (countyModel.isShowImageView) {
        self.imageView.hidden = NO;
        self.titleLabel.textColor = RGB(0x86B93F);
    }else{
        self.imageView.hidden = YES;
        self.titleLabel.textColor = RGB(0x333333);
    }
}

@end
