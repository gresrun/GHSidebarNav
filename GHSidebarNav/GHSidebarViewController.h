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
	BOOL _isSidebarShowing;
	BOOL _isSearching;
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

@property(nonatomic, readonly) BOOL sidebarShowing;
@property(nonatomic, readonly) BOOL searching;

- (id)initWithHeaders:(NSArray *)headers withContollers:(NSArray *)controllers withCellInfos:(NSArray *)cellInfos;
- (void)toggleSidebar:(BOOL)show animated:(BOOL)animate;
- (void)toggleSearch:(BOOL)searching withSearchTable:(UITableView *)searchTable animated:(BOOL)animate;

@end
