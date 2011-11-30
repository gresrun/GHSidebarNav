//
//  GHSidebarViewController.h
//  GHSidebarNav
//
//  Created by Greg Haines on 11/20/11.
//

@class GHSidebarSearchViewController;


@interface GHSidebarViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
	GHSidebarSearchViewController *_searchVC;
	UIView *_sidebarView;
	UIView *_contentView;
	UITableView *_menuTableView;
	BOOL _isSidebarShowing;
	BOOL _isSearching;
	UITapGestureRecognizer *_tapRecog;
	CGRect _sidebarOrigFrame;
	NSMutableArray *_menuHeaders;
	NSMutableArray *_menuControllers;
	NSMutableArray *_menuCellInfo;
	UIViewController *_selectedContentVC;
}

- (void)toggleSidebar:(BOOL)show animated:(BOOL)animate;
- (void)toggleSearch:(BOOL)searching animated:(BOOL)animate withSearchTable:(UITableView *)searchTable;

@end
