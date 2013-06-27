#import <UIKit/UIKit.h>

@class AdLibrary_iPhoneViewController;

@interface AppDelegate : NSObject <UIApplicationDelegate>
{
    UIWindow *window;
    AdLibrary_iPhoneViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet AdLibrary_iPhoneViewController *viewController;

@end

