#import <UIKit/UIKit.h>

@class AdLibrary_iPadViewController;

@interface AppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    AdLibrary_iPadViewController *viewController;
}

@property (nonatomic, strong) IBOutlet UIWindow *window;
@property (nonatomic, strong) IBOutlet AdLibrary_iPadViewController *viewController;

@end

