#import "AdLibrary_iPadViewController.h"
#import "VWAdvertView.h"
#import "VWInterstitialManager.h"

/* Ad animation names. */
#define kShowAd @"kShowAd"
#define kHideAd @"kHideAd"

@interface AdLibrary_iPadViewController () <VWAdvertViewDelegate>
@property (nonatomic, weak) VWAdvertView *adView;
@property (nonatomic, weak) UIView *adContainer;
@property (nonatomic, weak) VWAdvertView *customAdView;
@end


@implementation AdLibrary_iPadViewController

@synthesize adView;
@synthesize adContainer;
@synthesize customAdView;

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  /*
   * Static example of including location in your request.  (Definitely don't use in
   * a production scenario -- you'll likely just use the CLLocation response from
   * CLLocationManager directly.)
   *
   * Please see VWAdvertView.h for more information about including location.
   */
  CLLocationCoordinate2D coord = {.latitude = 37.33168900, .longitude = -122.03073100};
  CLLocation *loc = [[CLLocation alloc] initWithCoordinate:coord altitude:0.0 horizontalAccuracy:92812.0 verticalAccuracy:0.0 timestamp:[NSDate date]];

  /*
   * Example ad view for a category of News and Information and display block ID 15995.
   * When no partner module ID is available, it may be set to zero.
   *
   * Note that your partner and portal information is set in the Info.plist as the
   * key kVWOnlineAdsBaseURL.  Please see VWAdvertView.h for more information.
   *
   * Possible category values are listed in VWContentCategory.h.
   *
   * To test iAd (if enabled in your Info.plist) or a "no ad" situation, change the
   * partner keyword in the Info.plist's base URL to a bogus value.  The "sampletag"
   * partner generally always returns an ad.
   */
  VWAdvertView *newAdView = [[VWAdvertView alloc] initWithContentCategoryID:VWContentCategoryNewsAndInformation displayBlockID:15995 partnerModuleID:0 location:loc];
  [newAdView setDelegate:self];
  [newAdView setHidden:YES];
  [self setAdView:newAdView];
  
  [[self view] addSubview:newAdView];
  newAdView = nil;
  
  /*
   * Here we're making a custom-sized ad view (300x250, a standard IAB size).
   * Note that you'll want to be careful about using custom sizes, as ad inventory
   * is typically only available for certain industry standard sizes.
   */
  UIView *newAdContainer = [[UIView alloc] initWithFrame:CGRectMake(25.0, 25.0, 300.0, 250.0)];
  [newAdContainer setBackgroundColor:[UIColor blueColor]];
  
  newAdView = [[VWAdvertView alloc] initWithContentCategoryID:VWContentCategorySportsBaseball displayBlockID:15995 partnerModuleID:0 location:loc];
  [newAdView setDelegate:self];
  [newAdView setCustomAdSize:[newAdContainer bounds]];
  [newAdView setHidden:YES];
  
  [newAdContainer addSubview:newAdView];
  [self setCustomAdView:newAdView];
  newAdView = nil;
  
  [[self view] addSubview:newAdContainer];
  [self setAdContainer:newAdContainer];
  newAdContainer = nil;
  
  UIButton *refreshButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
  [refreshButton setFrame:CGRectMake(25.0, 285.0, 300.0, 40.0)];
  [refreshButton setTitle:@"Refresh Custom Ad" forState:UIControlStateNormal];	
	[refreshButton addTarget:self action:@selector(refreshCustom:) forControlEvents:UIControlEventTouchUpInside];
	[[self view] addSubview:refreshButton];
  
  refreshButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
  [refreshButton setFrame:CGRectMake(25.0, 345.0, 300.0, 40.0)];
  [refreshButton setTitle:@"Refresh Banner Ad" forState:UIControlStateNormal];	
	[refreshButton addTarget:self action:@selector(refreshBanner:) forControlEvents:UIControlEventTouchUpInside];
	[[self view] addSubview:refreshButton];
  
  refreshButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
  [refreshButton setFrame:CGRectMake(25.0, 405.0, 300.0, 40.0)];
  [refreshButton setTitle:@"Simple Transition" forState:UIControlStateNormal];
	[refreshButton addTarget:self action:@selector(simpleTransition:) forControlEvents:UIControlEventTouchUpInside];
	[[self view] addSubview:refreshButton];

  refreshButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
  [refreshButton setFrame:CGRectMake(25.0, 465.0, 300.0, 40.0)];
  [refreshButton setTitle:@"Managed Transition" forState:UIControlStateNormal];
	[refreshButton addTarget:self action:@selector(managedTransition:) forControlEvents:UIControlEventTouchUpInside];
	[[self view] addSubview:refreshButton];
  
  loc = nil;
}

- (void)viewDidUnload
{
  [self setAdView:nil];
  [self setCustomAdView:nil];
  [self setAdContainer:nil];
  
  [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  return YES;
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  
  [[self adView] adWillAppear];
  [[self customAdView] adWillAppear];
}

- (void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
  
  if ([[self adView] isHidden]) {
    CGRect upperFrame = [[self view] frame];
    CGRect newFrame = [[self adView] frame];
    
    newFrame.origin.y = upperFrame.origin.y + upperFrame.size.height;
    newFrame.size.width = upperFrame.size.width;
    [[self adView] setFrame:newFrame];
  }
  
  [[self adView] adDidAppear];
  [[self customAdView] adDidAppear];
}

- (void)viewWillDisappear:(BOOL)animated
{
  [super viewWillDisappear:animated];
  
  [[self adView] adWillDisappear];
  [[self customAdView] adWillDisappear];
}

- (void)viewDidDisappear:(BOOL)animated
{
  [super viewDidDisappear:animated];
  
  [[self adView] adDidDisappear];
  [[self customAdView] adDidDisappear];
}

/*
 * Rotation has no effect on custom ad units.
 */
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
  [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
  
  [[self adView] willRotateAd];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
  [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
  
  [[self adView] didRotateAd];
}

/*
 * Ordinarily you want to try to use refreshWithContentCategory... methods to swap out
 * ads (instead of refreshAd) since they take care of hiding and showing the ad.  Otherwise,
 * if you use refreshAd, you need to manually call adWillDisappear and adDidDisappear beforehand.
 *
 * If you don't include location in your refreshWithContentCategory..., the location set upon
 * initialization will be preserved.
 */
- (void)refreshCustom:(id)sender
{
  [[self adContainer] setBackgroundColor:[UIColor blueColor]];
  [[self customAdView] refreshWithContentCategoryID:VWContentCategorySportsBaseball displayBlockID:15995 partnerModuleID:0];
}

- (void)refreshBanner:(id)sender
{
  [[self adView] refreshWithContentCategoryID:VWContentCategoryNewsAndInformation displayBlockID:15995 partnerModuleID:0];
}

#pragma mark -
#pragma mark Interstitial Button methods

- (void)simpleTransition:(id)sender
{
  [[VWInterstitialManager defaultManager] transitionWithContentCategoryID:VWContentCategoryNewsAndInformation displayBlockID:15995 partnerModuleID:0];
}

- (void)managedTransition:(id)sender
{
  VWInterstitialManager* manager = [VWInterstitialManager defaultManager];

  [manager countTransitionWithContentCategoryID:VWContentCategoryNewsAndInformation displayBlockID:15995 partnerModuleID:0];

  if (![manager isInterstitialPresentable]) return;

  // We have an interstitial ready, now we'll make it obvious that it's being managed:
  [UIView animateWithDuration:1.0f animations:^{
    [sender setAlpha:0.0f];
  } completion:^(BOOL finished) {
    
    // Present from a nil view controller, trusting that the manager's delegate knows
    // what view controller to use.
    [manager presentFromViewController:nil withCompletion:^(BOOL presentationCancelled) {
      // This block executes when the presentation has finished. Here we will make
      // the button visible again but we will set a 0.0 animation duration if the 
      // presentation was cancelled (which we do if you put the app in the background
      // while the interstitial is visible).
      NSTimeInterval animationInterval = (presentationCancelled) ? 0.0f : 1.0f;
      [UIView animateWithDuration:animationInterval animations:^{
        [sender setAlpha:1.0f];
      }];
    }];
  }];
}

#pragma mark -
#pragma mark VWAdViewDelegate Methods

/*
 * Library has an ad ready for display; animate it in.
 */
- (void)adReadyForAdView:(VWAdvertView *)advertView
{
  if (advertView == [self customAdView]) {
    [[self adContainer] setBackgroundColor:[UIColor clearColor]];
    [[self customAdView] layoutSubviews];
    [[self customAdView] setHidden:NO];
    
  } else if (advertView == [self adView]) {
    CGRect myBounds = [[self view] bounds];
    
    CGRect adFrame = [[self adView] frame];
    adFrame.origin.y = myBounds.origin.y + myBounds.size.height;
    adFrame.size.width = myBounds.size.width;
    adFrame.origin.x = 0.0f;
    
    [[self adView] setFrame:adFrame];
    [[self adView] setHidden:NO];
    
    adFrame.origin.y = myBounds.size.height - adFrame.size.height;
    
    [UIView animateWithDuration:0.2 animations:^{
      [[self adView] setFrame:adFrame];
    }];
  }
}

/*
 * Library wants to remove the ad from view; remove it from the screen.
 */
- (void)adRemovedForAdView:(VWAdvertView *)advertView animateHiding:(BOOL)animateHiding
{
  if (advertView == [self customAdView]) {
    DLog(@"custom ad removed");
    [[self adContainer] setBackgroundColor:[UIColor blueColor]];
    [[self customAdView] setHidden:YES];

  } else if (advertView == [self adView]) {
    DLog(@"banner ad removed (animated: %@)", animateHiding ? @"YES" : @"NO");
    if (animateHiding) {
      [UIView beginAnimations:kHideAd context:nil];
    }
    
    CGRect myBounds = [[self view] bounds];
    
    CGRect adFrame = [[self adView] frame];
    adFrame.origin.y = myBounds.origin.y + myBounds.size.height;
    
    [[self adView] setFrame:adFrame];
    [[self adView] setHidden:YES];
    
    if (animateHiding) {
      [UIView commitAnimations];
    }
  }
}

/*
 * Ad response view.  Normally you shouldn't need to even implement this method, but if
 * you have problems with the library's modal view presentation, you can try presenting
 * it on your own.
 */
- (BOOL)advertView:(VWAdvertView *)adView shouldPresentAdResponseViewController:(UIViewController *)viewController
{
  DLog(@"fired");
  [self presentModalViewController:viewController animated:YES];
  return (NO);
}

/*
 * No ad available.
 */
- (void)advertView:(VWAdvertView *)anAdView didFailToReceiveAdWithError:(NSError *)error
{
  if (anAdView == [self adView]) {
    DLog(@"no banner ad: %@", error);
  } else if (anAdView == [self customAdView]) {
    DLog(@"no custom ad: %@", error);
    [[self adContainer] setBackgroundColor:[UIColor redColor]];
  }
}

@end