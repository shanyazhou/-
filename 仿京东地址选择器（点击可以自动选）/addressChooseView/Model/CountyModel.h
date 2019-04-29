#import <Foundation/Foundation.h>

@interface CountyModel : NSObject
@property(nonatomic,assign)NSInteger city_id;
@property(nonatomic,copy)NSString *county_name;
@property(nonatomic,assign)NSInteger id;

@property (assign, nonatomic) BOOL isShowImageView;
@end
