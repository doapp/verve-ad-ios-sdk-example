//
//  VWInterstitialManager.h
//  VWAdLibrary
//
//  Copyright (c) 2012 Verve Wireless, Inc.
//

/*
 * A VWInterstitialManager is a long-lived object which you typically use to 
 * control the frequency and display of interstitials based on screen transitions.
 *
 * You configure the overall display policy and then notify the manager of each 
 * important screen transition. The manager will create interstititials as appropriate
 * and notify you (via delegate callbacks) when an interstitial is ready for presentation.
 *
 * You can create as many interstitials as you like, but you typically would never need
 * more than one application-wide manager. The library provides a shared default manager
 * for such use.
 *
 * For the most part, you will simply configure the interstitial policy at application
 * startup and then inform the manager that a transition occurred. If an interstitial 
 * is ready at transition-time, the manager will immediately inform its delegate, expecting 
 * that the interstitial will be immediately presented.
 *
 * This allows most of your code to remain unaware of the intricacies of interstitial
 * display, simply informing the manager of transitions.
 *
 * However, there may be certain situations where you need to exert more control over
 * what happens at transition time. A good example of this is pausing auto-play of videos
 * when you know an interstitial is going to be displayed, as well as starting the 
 * video when the interstitial has finished its presentation.
 *
 * In that case, the relevant controllers in your application can assume some of the 
 * presentation responsibilities normally performed by the delegate. They can tell the
 * manager to 'count' the transition and then query the manager to see if there is an 
 * interstitial ready for presentation. 
 *
 * They can then call presentFromViewController:withCompletion: allowing them to be notified 
 * (in addition to the delegate) that the interstitial has been dismissed.
 *
 * Note: interactions with a VWInterstitialManager should occur on the main thread only.
 *
 */

#import "VWInterstitial.h"

@protocol VWInterstitialManagerDelegate;

@interface VWInterstitialManager : NSObject

@property (nonatomic, weak) id delegate;

/* Each interstitial manager should have a unique defaultsPrefix which
 * is used to namespace key/value pairs stored in user defaults. If you
 * simply use the defaultManager then this detail is taken care of for you.
 */
@property (nonatomic, copy, readonly) NSString* defaultsPrefix;

/*
 * By default, VWInterstitialManagers are disabled. Your application code
 * can safely interact with a manager (recording transitions etc) without having
 * to check isEnabled.
 */
@property (nonatomic, assign, getter=isEnabled) BOOL enabled;

/*
 * The loadFrequency controls how many transitions must occur before an interstitial
 * is requested.
 */
@property (nonatomic, assign) NSUInteger loadFrequency;

/*
 * The impressionInterval is the minimum amount of time which must pass after a
 * full-screen ad impression before an interstitial can be requested or presented.
 *
 * The purpose of this value is to ensure users are not overloaded with full-screen
 * interruptions. The value has an effect across application restarts.
 *
 * It's important to note that full-screen landing pages for VWAdvertView banner ads 
 * count as a full-screen ad impression.
 */
@property (nonatomic, assign) NSTimeInterval impressionInterval;

/*
 * Location is optional, but its inclusion will allow for more reliable targeting.
 * Two recommendations regarding location: if you're attempting to collect location,
 * make sure your app has a feature (other than advertising) that makes use of it --
 * Apple may reject otherwise.  Also, don't continuously collect location; just
 * collect it once per session.  Location collection is tough on the battery and
 * advertising won't benefit from minor adjustments to the location.
 *
 * Setting the postalCode is useful for targeting if you don't have lat/long values.
 */
@property (nonatomic, retain) CLLocation *location;
@property (nonatomic, copy) NSString *postalCode; /* Useful if you don't have lat/long handy. */

/*
 * Responds YES if an interstitial ad response is loaded and ready. However this 
 * accessor does not account for whether the manager is currently enabled.
 */
@property (nonatomic, readonly, getter=isInterstitialLoaded) BOOL interstitialLoaded;

/*
 * Responds YES if the manager is enabled and there is an interstitial loaded and ready.
 * You would typically use this accessor to decide whether or not to call presentFromViewController:
 */
@property (nonatomic, readonly, getter=isInterstitialPresentable) BOOL interstitialPresentable;

/*
 * Responds YES if the manager is currently displaying an interstitial on screen.
 */
@property (nonatomic, readonly, getter=isInterstitialPresenting) BOOL interstitialPresenting;

/*
 * The default shared VWInterstitialManager instance.
 */
+ (VWInterstitialManager*)defaultManager;

/*
 * If you are creating multiple interstitial managers, you must supply a user-defaults prefix
 * that will be prepended to all keys stored in user defaults.
 */
- (id)initWithUserDefaultsPrefix:(NSString*)defaultsPrefix;

/*
 * Tell the interstitial manager to count a transition. If the current transition policy 
 * dictates it, the manager will request an interstitial ad from the server.
 *
 * If an interstitital is currently ready for display, it will notify the delegate that it 
 * is time to present an interstitial.
 *
 * An intersitital transition must always have positive, non-zero content category and
 * display block values associated.
 *
 * Definitely include partner module ID if you have a set of values assigned for
 * your content, though it is optional.
 *
 */
- (void)transitionWithContentCategoryID:(VWContentCategory)contentCategory displayBlockID:(NSInteger)displayBlock;
- (void)transitionWithContentCategoryID:(VWContentCategory)contentCategory displayBlockID:(NSInteger)displayBlock partnerModuleID:(NSInteger)partnerModule;

/*
 * Tell the interstitial manager to count a transition. If the current transition policy 
 * dictates it, the manager will request an interstitial ad from the server.
 *
 * Unlike transitionWithContentCategoryID: the delegate will *not* be informed of the
 * transition if there is an interstitial ready for display.
 *
 * It is your responsibility to check isInterstitialPresentable and to call the relevant
 * presentFromViewController: method.
 */
- (void)countTransitionWithContentCategoryID:(VWContentCategory)contentCategory displayBlockID:(NSInteger)displayBlock;
- (void)countTransitionWithContentCategoryID:(VWContentCategory)contentCategory displayBlockID:(NSInteger)displayBlock partnerModuleID:(NSInteger)partnerModule;

/*
 * If an interstitial is presentable, calling presentFromViewController: will cause the interstital
 * to be displayed.
 *
 * The delegate may optionally override the viewController you pass to this method. See the
 * verveInterstitialManager:shouldPresentFromViewController: delegate method for more information
 *
 * If you pass nil as the viewController, the delegate must respond with a non-nil value in
 * verveInterstitialManager:shouldPresentFromViewController: to ensure the interstitial actually
 * displays.
 */
- (BOOL)presentFromViewController:(UIViewController *)viewController;

/*
 * This method behaves identically to presentFromViewController: with the addition of a completion
 * block which will be called after the interstitial has been dismissed.
 *
 * The completion block takes a single BOOL parameter which is a hint that the interstitial was
 * dismissed in response to a call to cancelPresentation.
 */
- (BOOL)presentFromViewController:(UIViewController *)viewController withCompletion:(VWInterstitialCompletionBlock)completionBlock;

/* 
 * Once you have presented the interstitial you can forcibly dismiss the interstitial view by calling
 * cancelPresentation. This may be useful for situations like dismissing a visible interstitial
 * in response to the user putting the application into the background.
 *
 * The verveInterstitialManager:didDismissPresentationAsCancellation: method will fire, as will any completion
 * block you may have supplied via presentFromViewController:withCompletion:
 */
- (void)cancelPresentation;

/*
 * Reset loadFrequency and impressionInterval to their default values
 */
- (void)resetConfiguration;

@end

@protocol VWInterstitialManagerDelegate <NSObject>
@optional

/*
 * This callback informs you that an interstitial is ready for presentation.
 * The typical response is to immediately call presentFromViewController:
 */
- (void)verveInterstitialManagerTransitionedWithPresentableInterstital:(VWInterstitialManager*)manager;

/*
 * This callback gives the delegate the opportunity to override the view controller 
 * which will be used to present the interstitial.
 *
 * The interstitial will be presented modally on the specified view controller
 * but you should not rely on that particular implementation detail.
 *
 * If you return nil, the interstitial will not be presented.
 */
- (UIViewController *)verveInterstitialManager:(VWInterstitialManager*)manager shouldPresentFromViewController:(UIViewController *)viewController;

/*
 * You can use this callback as a signal to pause general application activity while
 * an interstitial is on screen.
 */
- (void)verveInterstitialManager:(VWInterstitialManager*)manager didPresentFromViewController:(UIViewController *)viewController;

/*
 * You can use this callback as a signal to resume application activity after the
 * interstitial has been dismissed.
 *
 * The cancellation parameter is a hint that cancelPresentation was called, allowing
 * you to adjust your response. For example, you may not wish to resume certain
 * activities if you typically call cancelPresentation when the application has been
 * put into the background.
 */
- (void)verveInterstitialManager:(VWInterstitialManager*)manager didDismissPresentationAsCancellation:(BOOL)cancellation;
@end
