/*
 * This is a sample app demonstrating use of the Verve advertising library.
 * Two keys should be set in your Info.plist:
 *
 * - kVWOnlineAdsBaseURL: string, mandatory
 * - kVWiAdEnabled: boolean, optional
 *
 * DO NOT use the example base URL in this app's Info.plist in your own app.
 * Verve will assign you partner and portal keywords for your app (though, in general,
 * you should use the portal keyword "iphn" for iPhone apps).
 *
 * Also, please check the build settings for this example project.  Under "Other
 * Linker Flags" you need either "-force_load ../../VWAdLibrary/libVerveAd.a" (adjusted
 * as appropriate for the library's location) or "-all_load".  Otherwise you may see
 * crashes related to unrecognized selectors for some of the categories included in
 * the library.
 *
 * See VWAdView.h for more information.
 */
 
#import "AppDelegate.h"
#import "AdLibrary_iPhoneViewController.h"
#import "VWInterstitialManager.h"

@interface AppDelegate () <VWInterstitialManagerDelegate>
@end

@implementation AppDelegate

@synthesize window;
@synthesize viewController;


#pragma mark -
#pragma mark Application lifecycle

- (void)dealloc
{
  [viewController release];
  [window release];
  [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  [self.window setRootViewController:viewController];
  [self.window makeKeyAndVisible];

  /*
   * Set up the application-wide interstitial manager. Typically you would only use one interstitial
   * manager so we provide a single shared instance as defaultManager.
   */
  
  VWInterstitialManager* manager = [VWInterstitialManager defaultManager];

  [manager setDelegate:self];
  [manager setEnabled:YES];  
  [manager setImpressionInterval:15];
  [manager setLoadFrequency:2];

  /*
   * Because the interstitial manager is a long-lived object, you can configure the current location
   * in response to location changes, rather than set it with every transition. Subsequent requests 
   * for interstitial ads will include the updated location information.
   *
   * In the example below, we use the same location information that is set for the banner ads in
   * AdLibrary_iPhoneViewController.m.  You do not, of course, want to use this static example in
   * a production app!
   */
  CLLocationCoordinate2D coord = {.latitude = 37.33168900, .longitude = -122.03073100};
  CLLocation *loc = [[CLLocation alloc] initWithCoordinate:coord altitude:0.0 horizontalAccuracy:92812.0 verticalAccuracy:0.0 timestamp:[NSDate date]];
  
  [manager setLocation:loc];
  [manager setPostalCode:@"77005"];
  [loc release], loc = nil;
  
  return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
  // We want to dismiss any currently-presenting interstitial. There's no need to actually check if one
  // is presenting first, just make the call:
  NSLog(@"Cancelling any existing interstitial presentation (it %@ presenting)", [[VWInterstitialManager defaultManager] isInterstitialPresenting] ? @"was" : @"was not");
  [[VWInterstitialManager defaultManager] cancelPresentation];
}

/*
 * This delegate callback is informing you that the manager was notified of a screen transition and
 * that the manager has an interstitial ready for immediate display.
 *
 * It is your responsibility to tell the manager to display the interstitial, passing the viewController
 * which can be used for presentation.
 */
- (void)verveInterstitialManagerTransitionedWithPresentableInterstital:(VWInterstitialManager*)manager
{
  [manager presentFromViewController:[self.window rootViewController]];
}

/* 
 * This delegate callback is provided to allow you to override the viewController value passed
 * to presentFromViewController:
 *
 * In the example below, we always ignore the passed viewController and return the application's 
 * rootViewController. This way, other parts of the application can tell the shared defaultManager
 * to presentFromViewController without needing to know the 'correct' viewController to pass.
 */
- (UIViewController *)verveInterstitialManager:(VWInterstitialManager*)manager shouldPresentFromViewController:(UIViewController *)viewController
{
  return [self.window rootViewController];
}

@end
