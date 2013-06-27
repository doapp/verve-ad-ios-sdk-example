#import <UIKit/UIKit.h>

@class AdLibrary_iPhoneViewController;

@interface AppDelegate : NSObject <UIApplicationDelegate>
{
    UIWindow *window;
    AdLibrary_iPhoneViewController *viewController;
}

@property (nonatomic, strong) IBOutlet UIWindow *window;
@property (nonatomic, strong) IBOutlet AdLibrary_iPhoneViewController *viewController;

@end

