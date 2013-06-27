#import "AdLibrary_iPhoneViewController.h"
#import "VWAdvertView.h"
#import "VWInterstitialManager.h"

/* Ad animation names. */
#define kShowAd @"kShowAd"
#define kHideAd @"kHideAd"


@interface AdLibrary_iPhoneViewController () <VWAdvertViewDelegate>
@property (nonatomic, assign) VWAdvertView *adView;
@property (nonatomic, retain) NSTimer *stressTimer;
@property (nonatomic, assign) UIButton *stressButton;
@end


@implementation AdLibrary_iPhoneViewController

@synthesize adView;
@synthesize stressTimer;
@synthesize stressButton;

- (void)createAdView
{
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
  
  /*
   * This ad is clearly and always at the bottom of the page.  Therefore, it's appropriate
   * for us to indicate its position.  When in doubt or the possible position values don't
   * clearly describe the ad's position on the page, just don't set this value.
   */
  [newAdView setAdPosition:VWAdvertPositionBottom];
  
  /*
   * Sometimes we may have a ZIP code when, e.g., a user chooses a location for weather
   * or local news.  Since not every user is going to consent to lat/long collection,
   * passing along ZIP when available is a nice fallback.
   */
  [newAdView setPostalCode:@"77005"];
  
  [newAdView setHidden:YES];
  [self setAdView:newAdView];
  
  [[self view] addSubview:newAdView];
  [newAdView release], newAdView = nil;
  [loc release], loc = nil;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
  [button setFrame:CGRectMake(25.0, 25.0, 200.0, 40.0)];
  [button setTitle:@"Start Stress Test" forState:UIControlStateNormal];
  [button setTitle:@"Stop Stress Test" forState:UIControlStateSelected];
	[button addTarget:self action:@selector(toggleStressTimer:) forControlEvents:UIControlEventTouchUpInside];
	[[self view] addSubview:button];
  [self setStressButton:button];
  button = nil;

  button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
  [button setFrame:CGRectMake(25.0, 100.0, 200.0, 40.0)];
  [button setTitle:@"Simple Transition" forState:UIControlStateNormal];
	[button addTarget:self action:@selector(simpleTransition:) forControlEvents:UIControlEventTouchUpInside];
	[[self view] addSubview:button];
  button = nil;

  button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
  [button setFrame:CGRectMake(25.0, 175.0, 200.0, 40.0)];
  [button setTitle:@"Managed Transition" forState:UIControlStateNormal];
	[button addTarget:self action:@selector(managedTransition:) forControlEvents:UIControlEventTouchUpInside];
	[[self view] addSubview:button];
  button = nil;

  [self createAdView];
}

- (void)viewDidUnload
{
  [self setAdView:nil];
  [self setStressButton:nil];
  [[self stressTimer] invalidate];
  [self setStressTimer:nil];
  
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
}

- (void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
  
  if ([[self adView] isHidden]) {
    CGRect upperFrame = [[self view] frame];
    CGRect newFrame = [[self adView] frame];
    
    newFrame.origin.y = upperFrame.origin.y + upperFrame.size.height;
    [[self adView] setFrame:newFrame];
  }
  
  [[self adView] adDidAppear];
}

- (void)viewWillDisappear:(BOOL)animated
{
  [super viewWillDisappear:animated];
  
  [[self adView] adWillDisappear];
}

- (void)viewDidDisappear:(BOOL)animated
{
  [super viewDidDisappear:animated];
  
  [[self adView] adDidDisappear];
}

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
#pragma mark Stress Test Methods

- (void)toggleStressTimer:(id)sender
{
  if (![self stressTimer]) {
    DLog(@"starting stress test");
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(rebuildAd) userInfo:nil repeats:YES];
    [self setStressTimer:timer];
    [[self stressButton] setSelected:YES];
    
  } else {
    [[self stressTimer] invalidate];
    [self setStressTimer:nil];
    [[self stressButton] setSelected:NO];
    DLog(@"stopped stress test");
  }
}

- (void)rebuildAd
{
  if (![self stressTimer]) return;

  DLog(@"rebuilding ad view...");
  [[self adView] adWillDisappear];
  [[self adView] adDidDisappear];
  [[self adView] removeFromSuperview];
  [self setAdView:nil];

  [self createAdView];
  
  [[self adView] adWillAppear];
  
  CGRect upperFrame = [[self view] frame];
  CGRect newFrame = [[self adView] frame];
  newFrame.origin.y = upperFrame.origin.y + upperFrame.size.height;
  [[self adView] setFrame:newFrame];

  [[self adView] adDidAppear];
}

#pragma mark -
#pragma mark VWAdViewDelegate Methods

/*
 * Library has an ad ready for display; animate it in.
 */
- (void)adReadyForAdView:(VWAdvertView *)anAdView
{
  if (![anAdView isEqual:[self adView]]) {
    return;
  }
  
  [[self adView] setBackgroundColor:[UIColor clearColor]];
  CGRect myBounds = [[self view] bounds];
  
  CGRect oldAdFrame = [[self adView] frame];
  oldAdFrame.origin.y = myBounds.origin.y + myBounds.size.height;
  
  [[self adView] setFrame:oldAdFrame];
  [[self adView] setHidden:NO];
  
  CGRect adFrame = [[self adView] frame];
  adFrame.origin.y = myBounds.size.height - adFrame.size.height;
  
  [UIView beginAnimations:kShowAd context:nil];
  [UIView setAnimationDelegate:self];
  [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
  
  [[self adView] setFrame:adFrame];
  
  [UIView commitAnimations];
}

/*
 * Library wants to remove the ad from view; remove it from the screen.
 */
- (void)adRemovedForAdView:(VWAdvertView *)anAdView animateHiding:(BOOL)animateHiding
{
  if (![anAdView isEqual:[self adView]]) {
    return;
  }
  
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

/*
 * No ad available.
 */
- (void)advertView:(VWAdvertView *)adView didFailToReceiveAdWithError:(NSError *)error
{
  DLog(@"no ad: %@", error);
}

/*
 * iAd delegate pass-through.
 */
- (BOOL)advertViewiAdActionShouldBegin:(VWAdvertView *)adView willLeaveApplication:(BOOL)willLeave
{
  DLog(@"fired");
  return (YES);
}

@end
