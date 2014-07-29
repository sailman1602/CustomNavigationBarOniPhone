//
//  DWNavigationController.m
//  DWNavigationControllerDemo
//
//  Created by seven on 12-10-17.
//  Copyright (c) 2012年 www.dreamingwish.com All rights reserved.
//

#import "DWNavigationController.h"
#import "UIViewAdditions.h"
#import "DWNavgationStackViewControllerProtocol.h"

#define DefaultNavBarViewBGColor    NavBarColor

#pragma mark -
#pragma mark - TNNavigationBar
@interface DWNavigationBar : UIView
@property (nonatomic, retain)UIView *currentNavBarView;
@property (nonatomic, retain)UIView *comingNavBarView;
@end
@implementation DWNavigationBar

- (void)dealloc
{
    [_currentNavBarView release];
    [_comingNavBarView release];
    [super dealloc];
}
@end



#pragma mark -
#pragma mark - TNNavigationController

#define navBarHiddingAnimationDuring    0.35
#define navBarShowingAnimationDuring    0.35

@interface DWNavigationController ()
{
    DWNavigationBar *_tnNavBar;///< weak
    
    BOOL _willShowingComingNavBarView;
    BOOL _willHiddingCurrentNavBarView;
}
@property (nonatomic, readonly)DWNavigationBar *navBar;
@property (nonatomic, retain)NSTimer *pushLockTimer;
@end

@implementation DWNavigationController

#pragma mark - getter/setter
- (UIView *)navBar
{
    if (!_tnNavBar) {
        UINavigationBar *bar = self.navigationBar;
        if (bar) {            
            _tnNavBar = [[[DWNavigationBar alloc] initWithFrame:bar.frame] autorelease];
            _tnNavBar.backgroundColor = bar.tintColor;
            _tnNavBar.origin = CGPointMake(0.0, 0.0);
            [bar addSubview:_tnNavBar];
            _tnNavBar.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        }
    }
    return _tnNavBar;
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"tintColor"]) {
        UIColor *color = [change objectForKey:@"new"];
        if ([color isKindOfClass:[UIColor class]]) {
            self.navBar.backgroundColor = color;
        }
    }
}

#pragma mark - alloc/dealloc
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.navigationBar addObserver:self forKeyPath:@"tintColor" options:NSKeyValueObservingOptionNew context:nil];
        [self navBar];
}

- (void)viewDidUnload
{
    [self.navigationBar removeObserver:self forKeyPath:@"tintColor"];
    [_tnNavBar removeFromSuperview];
    _tnNavBar = nil;
    
    [super viewDidUnload];
}

- (void)dealloc
{
    [self.navigationBar removeObserver:self forKeyPath:@"tintColor"];
    
    [_pushLockTimer invalidate];
    [_pushLockTimer release];
    
    [super dealloc];
}

#pragma mark - some hack
- (void)hackViewControllerStandardNavBar:(UIViewController *)viewController
{
    viewController.navigationItem.hidesBackButton = YES;
    viewController.navigationItem.titleView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
    viewController.navigationItem.rightBarButtonItem = nil;
    viewController.navigationItem.leftBarButtonItem = nil;
}

- (void)pushLockTimerFired
{
    self.pushLockTimer = nil;
}

#pragma mark - Override push/pop functions
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (_pushLockTimer) {
        return;
    }
    
    //The voice recognizer cause the timer not to scheldule, may be a bug in sdk.
    if (self.viewControllers.count != 0) {//if this is the first viewController, we do not start a timer
        dispatch_async(dispatch_get_main_queue(), ^{
            self.pushLockTimer = [NSTimer scheduledTimerWithTimeInterval:navBarShowingAnimationDuring target:self selector:@selector(pushLockTimerFired) userInfo:nil repeats:NO];
        });
    }
    
    [self changeViewControllerFrom:self.topViewController to:viewController forStackOperation:DWStackOperationPush animated:animated];
    [super pushViewController:viewController animated:animated];
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated
{
    NSArray *viewControllers = self.viewControllers;
    if (viewControllers.count > 1) {
        UIViewController *fromViewController = self.topViewController;
        UIViewController *toViewController = [viewControllers objectAtIndex:viewControllers.count-2];
        [self changeViewControllerFrom:fromViewController to:toViewController forStackOperation:DWStackOperationPop animated:animated];
    }
    
    return [super popViewControllerAnimated:animated];
}

- (NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    NSArray *viewControllers = self.viewControllers;
    if (viewControllers.count > 1 && viewController != self.topViewController && [viewControllers indexOfObject:viewController] != NSNotFound) {
        [self changeViewControllerFrom:self.topViewController to:viewController forStackOperation:DWStackOperationPop animated:animated];
    }
    
    return [super popToViewController:viewController animated:animated];
}

- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated
{
    NSArray *viewControllers = self.viewControllers;
    if (viewControllers.count > 1) {
        UIViewController *fromViewController = self.topViewController;
        UIViewController *toViewController = [viewControllers objectAtIndex:0];
        [self changeViewControllerFrom:fromViewController to:toViewController forStackOperation:DWStackOperationPop animated:animated];
    }
    return [super popToRootViewControllerAnimated:animated];
    //return [self popToViewController:[self.viewControllers objectAtIndex:0] animated:animated];
}

- (void)setViewControllers:(NSArray *)viewControllers
{
    [self setViewControllers:viewControllers animated:NO];
}

- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated
{
    //the following logic obeys the <<iOS Documentation Set>>
    if (viewControllers.count > 0) {
        UIViewController *fromViewController = self.topViewController;
        UIViewController *toViewController = viewControllers.lastObject;
        if (fromViewController != toViewController) {
            DWStackOperation stackOperation;
            if ([self.viewControllers indexOfObject:toViewController] == NSNotFound) {
                stackOperation = DWStackOperationPush;
            } else {
                stackOperation = DWStackOperationPop;
            }
            [self changeViewControllerFrom:fromViewController to:toViewController forStackOperation:stackOperation animated:animated];
        }
    }
    
    [super setViewControllers:viewControllers animated:animated];
}

#pragma mark - navBar animation

- (void)changeViewControllerFrom:(UIViewController *)fromViewController to:(UIViewController *)toViewController forStackOperation:(DWStackOperation)stackOperation animated:(BOOL)animated
{
    if (fromViewController == toViewController) {
        return;
    }
    
    //We will enable this after showing and hidding animation are finished.
    self.navBar.userInteractionEnabled = NO;
    
    //setup flags first
    if (fromViewController) {
        _willHiddingCurrentNavBarView = YES;
    }
    if (toViewController) {
        _willShowingComingNavBarView = YES;
        [self hackViewControllerStandardNavBar:toViewController];
    }
    
    //then we commit the animation
    if (fromViewController) {
        [self hideNavBarForViewController:(UIViewController<DWNavgationStackViewControllerProtocol> *)fromViewController forStackOperation:stackOperation animated:animated];
    }
    
    if (toViewController) {
        [self showNavBarForViewController:(UIViewController<DWNavgationStackViewControllerProtocol> *)toViewController forStackOperation:stackOperation animated:animated];
    }    
}

#define defaultAnimationMovingLength        150.0
#define defaultAnimationTransparentAlpha    0.0
#define defaultAnimationOpaqueAlpha         1.0

- (void)hideNavBarForViewController:(UIViewController<DWNavgationStackViewControllerProtocol> *)viewController forStackOperation:(DWStackOperation)stackOperation animated:(BOOL)animated
{
    if (!self.navBar.currentNavBarView) {
        [self hiddingNavBarViewFinished];
        return;
    }
    
    //Show the navBarView animated or directly
    if (animated) {
        //Prepare for animation
        if ([viewController respondsToSelector:@selector(prepareHiddingNavBarView:forStackOperation:)]) {
            [viewController prepareHiddingNavBarView:self.navBar.currentNavBarView forStackOperation:stackOperation];
        } else {
            self.navBar.currentNavBarView.left = 0.0;
            self.navBar.currentNavBarView.alpha = defaultAnimationOpaqueAlpha;
        }
        
        //Commit animation
        [UIView animateWithDuration:navBarShowingAnimationDuring delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            if ([viewController respondsToSelector:@selector(hideNavBarView:forStackOperation:)]) {
                [viewController hideNavBarView:self.navBar.currentNavBarView forStackOperation:stackOperation];
            } else {
                if (stackOperation == DWStackOperationPush) {
                    self.navBar.currentNavBarView.left -= defaultAnimationMovingLength;
                } else {
                    self.navBar.currentNavBarView.left += defaultAnimationMovingLength;
                }
                self.navBar.currentNavBarView.alpha = defaultAnimationTransparentAlpha;
            }
        } completion:^(BOOL finished) {
            [self.navBar.currentNavBarView removeFromSuperview];
            self.navBar.currentNavBarView = nil;
            
            [self hiddingNavBarViewFinished];
        }];
    } else {
        if ([viewController respondsToSelector:@selector(hideNavBarView:forStackOperation:)]) {
            [viewController hideNavBarView:self.navBar.currentNavBarView forStackOperation:stackOperation];
        } else {
            [self.navBar.currentNavBarView removeFromSuperview];
            self.navBar.currentNavBarView = nil;
            
            [self hiddingNavBarViewFinished];
        }
    }
}



- (void)showNavBarForViewController:(UIViewController<DWNavgationStackViewControllerProtocol> *)viewController forStackOperation:(DWStackOperation)stackOperation animated:(BOOL)animated
{
    if (![viewController respondsToSelector:@selector(navBarViewForContainerSize:)]) {
        [self showingNavBarViewFinished];
        return;
    }
    //Get the navBarView, if we can't get one, we just return and do nothing.
    UIView *navBarView = [viewController navBarViewForContainerSize:self.navBar.frame.size];
    //we reset the origin and alpha
    navBarView.origin = CGPointZero;
    navBarView.alpha = defaultAnimationOpaqueAlpha;
    if (!navBarView) {
        [self showingNavBarViewFinished];
        return;
    }
    [self.navBar addSubview:navBarView];
    self.navBar.comingNavBarView = navBarView;
    
    //Show the navBarView animated or directly
    if (animated) {
        //Prepare animation
        if ([viewController respondsToSelector:@selector(prepareShowingNavBarView:forStackOperation:)]) {
            [viewController prepareShowingNavBarView:self.navBar.comingNavBarView forStackOperation:stackOperation];
        } else {
            if (stackOperation == DWStackOperationPush) {
                self.navBar.comingNavBarView.left = defaultAnimationMovingLength;
            } else {
                self.navBar.comingNavBarView.left = -defaultAnimationMovingLength;
            }
            self.navBar.comingNavBarView.alpha = defaultAnimationTransparentAlpha;
        }
        //Commit animation
        [UIView animateWithDuration:navBarShowingAnimationDuring delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            if ([viewController respondsToSelector:@selector(showNavBarView:forStackOperation:)]) {
                [viewController showNavBarView:self.navBar.comingNavBarView forStackOperation:stackOperation];
            } else {
                self.navBar.comingNavBarView.left = 0.0;
                self.navBar.comingNavBarView.alpha = defaultAnimationOpaqueAlpha;
            }
        } completion:^(BOOL finished) {
            [self showingNavBarViewFinished];
        }];
    } else {
        if ([viewController respondsToSelector:@selector(showNavBarView:forStackOperation:)]) {
            [viewController showNavBarView:self.navBar.comingNavBarView forStackOperation:stackOperation];
        } else {
            //Do nothing.
        }
        [self showingNavBarViewFinished];
    }
}

- (void)showingNavBarViewFinished
{
    _willShowingComingNavBarView = NO;
    if (!_willHiddingCurrentNavBarView) {
        [self bothShowAndHideNavBarAnimationAreCompleted];
    }
}

- (void)hiddingNavBarViewFinished
{
    _willHiddingCurrentNavBarView = NO;
    if (!_willShowingComingNavBarView) {
        [self bothShowAndHideNavBarAnimationAreCompleted];
    }
}

- (void)bothShowAndHideNavBarAnimationAreCompleted
{
    self.navBar.currentNavBarView = self.navBar.comingNavBarView;
    self.navBar.comingNavBarView = nil;
    self.navBar.userInteractionEnabled = YES;
    //A ugly hack
    [self checkDuplicatedBarView];
}

- (void)checkDuplicatedBarView
{
    NSArray *arr = [self.navBar.subviews copy];
    if (arr.count <= 1) {
        return;
    }
    for (UIView *navBarView in arr) {
        if (navBarView != self.navBar.currentNavBarView) {
            [navBarView removeFromSuperview];
        }
    }
}

@end





