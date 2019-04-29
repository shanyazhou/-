#import <Foundation/Foundation.h>

@interface ZHFCityModel : NSObject
@property(nonatomic,copy)NSString *city_name;
@property(nonatomic,assign)NSInteger id;
@property(nonatomic,assign)NSInteger province_id;

@property (assign, nonatomic) BOOL isShowImageView;
@end
