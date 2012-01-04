//
//  GHSidebarViewController.h
//  GHSidebarNav
//
//  Created by Greg Haines on 11/20/11.
//

extern const CGFloat kSidebarWidth;

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

- (void)toggleSidebar:(BOOL)show animated:(BOOL)animated;
- (void)toggleSidebar:(BOOL)show animated:(BOOL)animated completion:(void (^)(BOOL finsihed))completion;
- (void)toggleSearch:(BOOL)showSearch withSearchView:(UIView *)searchView animated:(BOOL)animated;
- (void)toggleSearch:(BOOL)showSearch withSearchView:(UIView *)searchView animated:(BOOL)animated completion:(void (^)(BOOL finsihed))completion;

@end
