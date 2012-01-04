//
//  GHSidebarSearchViewController.h
//  GHSidebarNav
//
//  Created by Greg Haines on 11/20/11.
//

@class GHRevealViewController;
@protocol GHSidebarSearchViewControllerDelegate;

@interface GHSidebarSearchViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchDisplayDelegate> {
@private
	GHRevealViewController *_sidebarVC;
	NSOperationQueue *_searchQueue;
	NSTimer *_timer;
	UIView *_searchBarSuperview;
	NSUInteger _searchBarSuperIndex;
}

@property (nonatomic, readonly) UISearchBar *searchBar;
@property (nonatomic, weak) id<GHSidebarSearchViewControllerDelegate> searchDelegate;

- (id)initWithSidebarViewController:(GHRevealViewController *)sidebarVC;

@end

@protocol GHSidebarSearchViewControllerDelegate <NSObject>
@required
- (NSArray *)searchResultsForText:(NSString *)text withScope:(NSString *)scope;
@end
