#import <UIKit/UIKit.h>

@class AdLibrary_iPadViewController;

@interface AppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    AdLibrary_iPadViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet AdLibrary_iPadViewController *viewController;

@end

