//
//  VWSplashAdvertView.h
//  VWAdLibrary
//
//  Copyright (c) 2012 Verve Wireless, Inc.//
#import <CoreLocation/CoreLocation.h>
#import "VWContentCategory.h"

@class VWSplashAdvertPolicy;
@protocol VWSplashAdvertViewDelegate;

@interface VWSplashAdvertView : UIView
@property (nonatomic, weak) id <VWSplashAdvertViewDelegate> delegate;
@property (nonatomic) CLLocation *location;
@property (nonatomic, copy) NSString *postalCode; /* Useful if you don't have lat/long handy. */

+ (VWSplashAdvertView*)splashAdvertViewWithFrame:(CGRect)frame contentCategoryID:(VWContentCategory)contentCategory displayBlockID:(NSInteger)displayBlock;
- (void)loadWithDelegate:(id<VWSplashAdvertViewDelegate>)delegate;
@end

@interface VWSplashAdvertPolicy : NSObject
@property (nonatomic, assign, getter=isEnabled) BOOL enabled;
@property (nonatomic, assign) NSUInteger impressionFrequency;
@property (nonatomic, assign) NSTimeInterval impressionInterval;
@property (nonatomic, assign) NSTimeInterval loadTimeout;
@property (nonatomic, assign) NSUInteger displaySeconds;

+ (VWSplashAdvertPolicy*)sharedPolicy;
- (void)resetConfiguration;
@end

@protocol VWSplashAdvertViewDelegate <NSObject>
- (void)verveSplashAdvertView:(VWSplashAdvertView*)advertView didFinishAfterDisplay:(BOOL)advertDisplayed;
@end
