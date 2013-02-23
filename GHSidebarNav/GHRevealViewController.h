//
//  GHSidebarViewController.h
//  GHSidebarNav
//
//  Created by Greg Haines on 11/20/11.
//

#import <Foundation/Foundation.h>

extern const NSTimeInterval kGHRevealSidebarDefaultAnimationDuration;
extern const CGFloat kGHRevealSidebarWidth;

@interface GHRevealViewController : UIViewController

@property (nonatomic, readonly, getter = isSidebarShowing) BOOL sidebarShowing;
@property (nonatomic, readonly, getter = isSearching) BOOL searching;
@property (strong, nonatomic) IBOutlet UIView *sidebarView;
@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (strong, nonatomic) UIViewController *sidebarViewController;
@property (strong, nonatomic) UIViewController *contentViewController;

@property BOOL searchIsShowing;

- (void)dragContentView:(UIPanGestureRecognizer *)panGesture;
- (void)toggleSidebar:(BOOL)show duration:(NSTimeInterval)duration;
- (void)toggleSidebar:(BOOL)show duration:(NSTimeInterval)duration completion:(void (^)(BOOL finished))completion;
- (void)toggleSearch:(BOOL)showSearch duration:(NSTimeInterval)duration;
- (void)toggleSearch:(BOOL)showSearch duration:(NSTimeInterval)duration completion:(void (^)(BOOL finished))completion;

@end
