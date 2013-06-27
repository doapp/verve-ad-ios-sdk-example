#import <CoreLocation/CoreLocation.h>

@interface VWAdminFunctionsManager : NSObject

+ (VWAdminFunctionsManager*)vwAdminFunctionsManager;
+ (NSDictionary*)identifierParams;

@property (assign, nonatomic, getter = isAdFeedbackEnabled) BOOL adFeedbackEnabled;

@property (assign, nonatomic, getter = isLocationOverrideEnabled) BOOL locationOverrideEnabled;
@property (assign, nonatomic) CLLocationCoordinate2D locationOverrideCoordinate;

- (CLLocation*)locationOverride; // Returns a CLLocation with the locationOverrideCooridinate, an accuracy of 0 (perfect accuracy), and a date of now.

@end
