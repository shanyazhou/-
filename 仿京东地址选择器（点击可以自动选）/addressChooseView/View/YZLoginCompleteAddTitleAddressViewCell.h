//
//  YZLoginCompleteAddTitleAddressViewCell.h
//  yz
//
//  Created by yz on 2019/1/30.
//  Copyright © 2019年 yz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZHFProvinceModel.h"
#import "ZHFCityModel.h"
#import "CountyModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface YZLoginCompleteAddTitleAddressViewCell : UITableViewCell
@property (strong, nonatomic) ZHFProvinceModel *provinceModel;
@property (strong, nonatomic) ZHFCityModel *cityModel;
@property (strong, nonatomic) CountyModel *countyModel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@end

NS_ASSUME_NONNULL_END
