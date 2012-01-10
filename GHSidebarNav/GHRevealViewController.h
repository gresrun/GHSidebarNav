//
//  GHSidebarViewController.h
//  GHSidebarNav
//
//  Created by Greg Haines on 11/20/11.
//

#import <Foundation/Foundation.h>

extern const NSTimeInterval kGHRevealSidebarDefaultAnimationDuration;
extern const CGFloat kGHRevealSidebarWidth;

@interface GHRevealViewController : UIViewController {
@private
	UIView *_sidebarView;
	UIView *_contentView;
	UITapGestureRecognizer *_tapRecog;
}

@property (nonatomic, readonly, getter = isSidebarShowing) BOOL sidebarShowing;
@property (nonatomic, readonly, getter = isSearching) BOOL searching;
@property (nonatomic, strong) UIViewController *sidebarViewController;
@property (nonatomic, strong) UIViewController *contentViewController;

- (void)toggleSidebar:(BOOL)show duration:(NSTimeInterval)duration;
- (void)toggleSidebar:(BOOL)show duration:(NSTimeInterval)duration completion:(void (^)(BOOL finished))completion;
- (void)toggleSearch:(BOOL)showSearch withSearchView:(UIView *)searchView duration:(NSTimeInterval)duration;
- (void)toggleSearch:(BOOL)showSearch withSearchView:(UIView *)searchView duration:(NSTimeInterval)duration completion:(void (^)(BOOL finished))completion;

@end
