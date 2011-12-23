//
//  GHSidebarViewController.h
//  GHSidebarNav
//
//  Created by Greg Haines on 11/20/11.
//

@class GHSidebarSearchViewController;


extern NSString const *kSidebarCellTextKey;
extern NSString const *kSidebarCellImageKey;


@interface GHSidebarViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
@private
	NSArray *_menuHeaders;
	NSArray *_menuControllers;
	NSArray *_menuCellInfos;
	GHSidebarSearchViewController *_searchVC;
	UIView *_sidebarView;
	UIView *_contentView;
	UITableView *_menuTableView;
	UITapGestureRecognizer *_tapRecog;
	UIViewController *_selectedContentVC;
}

@property(nonatomic, readonly, getter = isSidebarShowing) BOOL sidebarShowing;
@property(nonatomic, readonly, getter = isSearching) BOOL searching;

- (id)initWithHeaders:(NSArray *)headers withContollers:(NSArray *)controllers withCellInfos:(NSArray *)cellInfos;
- (void)toggleSidebar:(BOOL)show animated:(BOOL)animate;
- (void)toggleSearch:(BOOL)showSearch withSearchTable:(UITableView *)searchTable animated:(BOOL)animate;

@end
