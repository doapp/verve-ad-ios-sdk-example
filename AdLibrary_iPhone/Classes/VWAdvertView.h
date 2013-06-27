/*
 *
 * VWAdvertView
 *
 * Advertising view.
 *
 * (c) 2011 Verve Wireless, Inc.
 *
 */

#import <CoreLocation/CoreLocation.h>
#import <iAd/iAd.h>
#import "VWContentCategory.h"

/*
 * Name of string value in Info.plist containing the base URL
 * used for ad requests.  Typically this will look something like:
 *
 *   http://adcel.vrvm.com/banner?b=dailyplanet&p=iphn
 *
 * This base URL should specify your Verve-assigned partner (b=)
 * and portal (p=) keywords.
 *
 * When not using the Verve Content API, this value must be set
 * prior to creating a VWAdvertView.
 */
#define kVWOnlineAdsBaseURL @"kVWOnlineAdsBaseURL"

/*
 * Name of boolean value in Info.plist indicating whether the Apple
 * iAd service should be used when a Verve request doesn't return
 * an ad.  Note that use of this service requires activation with Apple.
 * Also note that debug and ad hoc builds of apps will show test iAd
 * advertisements.
 */
#define kVWiAdEnabled @"kVWiAdEnabled"

extern NSString * const VWFullScreenAdImpressionNotification;

extern NSString * const VWAdvertErrorDomain;

/* Possible error codes for VWAdvertErrorDomain. */
typedef enum {
  VWAdvertErrorUnknown = 0,
  VWAdvertErrorInventoryUnavailable = 1,
} VWAdvertError;


/* Possible values for ad position (default is Unknown). */
typedef enum {
  VWAdvertPositionUnknown = 0,
  VWAdvertPositionTop,
  VWAdvertPositionInline,
  VWAdvertPositionBottom
} VWAdvertPosition;


/*
 * Possible values for specialized ad presentations (default is Regular).
 * Note that this affects the types of ads returned and should only be used
 * after consultation with Verve ad operations.
 */
typedef enum {
  VWAdvertTypeRegular = 0,
  VWAdvertTypeSponsorship,
  VWAdvertTypeInterstitial,
  VWAdvertTypeSplashSponsorship,
} VWAdvertType;


@class VWAdvertView;


/*
 * Delegate methods for handling display and removal of the ad view.
 * Your view controller should display or hide the ad view in a manner
 * appropriate for your UI.
 */

@protocol VWAdvertViewDelegate

@optional

- (void)advertView:(VWAdvertView *)adView didFailToReceiveAdWithError:(NSError *)error;

/*
 * These methods are optional but should only be used when your app needs to
 * present viewController a specific way.  If you return NO for either, you're
 * responsible showing or dismissing viewController.  The response view must be
 * presented full screen.
 *
 * Also, you don't have to implement both methods.  If shouldDismiss is unimplemented
 * (or returns YES), viewController will simply be dismissed with
 * dismissModalViewControllerAnimated:animated.
 */
- (BOOL)advertView:(VWAdvertView *)adView shouldPresentAdResponseViewController:(UIViewController *)viewController;
- (BOOL)advertView:(VWAdvertView *)adView shouldDismissAdResponseViewController:(UIViewController *)viewController animated:(BOOL)animated;

/*
 * If your app is interested, the iAd bannerViewActionShouldBegin:willLeaveApplication:
 * delegate gets passed through to this method.  Note that it only gets invoked on an iAd,
 * not a Verve ad.  If unimplemented, the default return is YES.
 */
- (BOOL)advertViewiAdActionShouldBegin:(VWAdvertView *)adView willLeaveApplication:(BOOL)willLeave;

@required

- (void)adReadyForAdView:(VWAdvertView *)adView;
- (void)adRemovedForAdView:(VWAdvertView *)adView animateHiding:(BOOL)animateHiding;

@end


@interface VWAdvertView : UIView 

@property (readonly) VWContentCategory contentCategoryID;
@property (readonly) NSInteger displayBlockID;
@property (readonly) NSInteger partnerModuleID;

/*
 * These are properties you can set as appropriate.
   --
 * This location is ignored when VWAdminFunctionsManager's location override
 * capability is used.
 */
@property (nonatomic, strong) CLLocation *location;
@property (nonatomic, weak) id <VWAdvertViewDelegate, NSObject> delegate;
@property (nonatomic, assign) VWAdvertPosition adPosition;  /* Defaults to VWAdvertPositionUnknown. */
@property (nonatomic, strong) NSString *postalCode;         /* Useful if you don't have lat/long handy. */

/* Only set this value if told to do so by Verve Ad Operations. */
@property (nonatomic, assign) VWAdvertType adType;

/*
 * This value will default to whatever kVWiAdEnabled is set to in your Info.plist, so
 * there's usually no need to touch this if you have the default configured correctly.
 * However, if you want to conditionalize when iAd should be used, you may twiddle
 * this value after VWAdvertView has been initialized.  (Only applicable for non-custom
 * ad sizes.)  kVWiAdEnabled should be set to YES if this value will ever be YES.
 */
@property (nonatomic, assign, getter=shouldUseiAds) BOOL useiAds;

/*
 * An ad request must always have positive, non-zero content category and display
 * block values associated.
 *
 * Definitely include partner module ID if you have a set of values assigned for
 * your content, though it is optional.
 *
 * Location is optional, but its inclusion will allow for more reliable targeting.
 * Two recommendations regarding location: if you're attempting to collect location,
 * make sure your app has a feature (other than advertising) that makes use of it --
 * Apple may reject otherwise.  Also, don't continuously collect location; just
 * collect it once per session.  Location collection is tough on the battery and
 * advertising won't benefit from minor adjustments to the location.
 *
 * If location changes after you've created your VWAdvertView, you should change it
 * by setting the location ivar: [advertview setLocation:myLocation];
 */

- (id)initWithContentCategoryID:(VWContentCategory)contentCategory displayBlockID:(NSInteger)displayBlock;
- (id)initWithContentCategoryID:(VWContentCategory)contentCategory displayBlockID:(NSInteger)displayBlock partnerModuleID:(NSInteger)partnerModule;

- (id)initWithContentCategoryID:(VWContentCategory)contentCategory displayBlockID:(NSInteger)displayBlock location:(CLLocation *)location;
- (id)initWithContentCategoryID:(VWContentCategory)contentCategory displayBlockID:(NSInteger)displayBlock partnerModuleID:(NSInteger)partnerModule location:(CLLocation *)location;

/* Deprecated; please use the above to pass CLLocation instead. */
- (id)initWithContentCategoryID:(VWContentCategory)contentCategory displayBlockID:(NSInteger)displayBlock atLocation:(CLLocationCoordinate2D)atLocation __deprecated;
- (id)initWithContentCategoryID:(VWContentCategory)contentCategory displayBlockID:(NSInteger)displayBlock partnerModuleID:(NSInteger)partnerModule atLocation:(CLLocationCoordinate2D)atLocation __deprecated;

/* 
 * If the ad unit is not a standard MMA banner size (usually 320x50), you may set
 * a custom size.  Note that ad inventory is typically only available for standard
 * MMA banners and some IAB ad units (on, e.g., the iPad).  Please consult Verve
 * prior to utilizing custom ad units.
 *
 * Note: if you're setting the background color/opacity of your VWAdvertView, you
 * need to do it before calling setCustomAdSize.
 */

- (void)setCustomAdSize:(CGRect)frame;

/*
 * Use these methods to tell the ad view when to perform its actions.
 * Call them from your view controller's viewWill*, viewDid*, willRotate*,
 * and didRotate* methods.
 */

- (void)willRotateAd;
- (void)didRotateAd;

- (void)adWillDisappear;
- (void)adDidDisappear;
- (void)adWillAppear;
- (void)adDidAppear;

/*
 * Calling one of these refresh methods will trigger an ad refresh.
 */

- (void)refreshWithContentCategoryID:(VWContentCategory)contentCategory displayBlockID:(NSInteger)displayBlock;
- (void)refreshWithContentCategoryID:(VWContentCategory)contentCategory displayBlockID:(NSInteger)displayBlock partnerModuleID:(NSInteger)partnerModule;

- (void)refreshWithContentCategoryID:(VWContentCategory)contentCategory displayBlockID:(NSInteger)displayBlock location:(CLLocation *)location;
- (void)refreshWithContentCategoryID:(VWContentCategory)contentCategory displayBlockID:(NSInteger)displayBlock partnerModuleID:(NSInteger)partnerModule location:(CLLocation *)location;

/* Deprecated; please use the above to pass CLLocation instead. */
- (void)refreshWithContentCategoryID:(VWContentCategory)contentCategory displayBlockID:(NSInteger)displayBlock atLocation:(CLLocationCoordinate2D)atLocation __deprecated;
- (void)refreshWithContentCategoryID:(VWContentCategory)contentCategory displayBlockID:(NSInteger)displayBlock partnerModuleID:(NSInteger)partnerModule atLocation:(CLLocationCoordinate2D)atLocation __deprecated;

/*
 * Call refreshAd when you need to force the ad to refresh.  This should be used
 * only when no ad parameters have changed.  Also, note that you're responsible for
 * tearing down an existing ad.  In general, you'll probably want to use one of the
 * refreshWithContentCategoryID methods.
 */

- (void)refreshAd;

@end

