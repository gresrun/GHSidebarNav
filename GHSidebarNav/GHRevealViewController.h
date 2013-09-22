//
//  GHSidebarViewController.h
//  GHSidebarNav
//
//  Created by Greg Haines on 11/20/11.
//


extern const NSTimeInterval kGHRevealSidebarDefaultAnimationDuration;
extern const CGFloat kGHRevealSidebarWidth;

@interface GHRevealViewController : UIViewController

@property (nonatomic, readonly, getter = isSidebarShowing) BOOL sidebarShowing;
@property (nonatomic, readonly, getter = isSearching) BOOL searching;
@property (strong, nonatomic) UIViewController *sidebarViewController;
@property (strong, nonatomic) UIViewController *contentViewController;

- (void)dragContentView:(UIPanGestureRecognizer *)panGesture;
- (void)toggleSidebar:(BOOL)show duration:(NSTimeInterval)duration;
- (void)toggleSidebar:(BOOL)show duration:(NSTimeInterval)duration completion:(void (^)(BOOL finished))completion;
- (void)toggleSearch:(BOOL)showSearch withSearchView:(UIView *)searchView duration:(NSTimeInterval)duration;
- (void)toggleSearch:(BOOL)showSearch withSearchView:(UIView *)searchView duration:(NSTimeInterval)duration completion:(void (^)(BOOL finished))completion;

@end
