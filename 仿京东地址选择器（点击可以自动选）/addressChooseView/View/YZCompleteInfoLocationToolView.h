//
//  YZCompleteInfoLocationToolView.h
//  yz
//
//  Created by yz on 2019/2/23.
//  Copyright © 2019年 yz. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol  ZHFAddTitleAddressViewDelegate <NSObject>
-(void)cancelBtnClick:(NSString *)titleAddress titleID:(NSString *)titleID;
@end
@interface YZCompleteInfoLocationToolView : UIView
@property(nonatomic,assign)id<ZHFAddTitleAddressViewDelegate>delegate;
@property(nonatomic,assign)NSUInteger defaultHeight;
@property(nonatomic,assign)CGFloat titleScrollViewH;
@property(nonatomic,copy)NSString *title;
@property(nonatomic,strong)UIView *addAddressView;
@property (strong, nonatomic) NSArray *zhuanyeArray;
@property (strong, nonatomic) NSArray *positionArray;
-(UIView *)initAddressViewWithContentString:(NSString *)contentString;
-(void)addAnimate;
@end

NS_ASSUME_NONNULL_END
