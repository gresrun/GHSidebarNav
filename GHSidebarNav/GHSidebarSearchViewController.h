//
//  GHSidebarSearchViewController.h
//  GHSidebarNav
//
//  Created by Greg Haines on 11/20/11.
//

@class GHSidebarViewController;


@interface GHSidebarSearchViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchDisplayDelegate> {
	@private
	GHSidebarViewController *_sidebarVC;
	NSOperationQueue *_searchQueue;
	NSTimer *_timer;
}

@property(nonatomic, readonly) UISearchBar *searchBar;

- (id)initWithSidebarViewController:(GHSidebarViewController *)sidebarVC;

@end
