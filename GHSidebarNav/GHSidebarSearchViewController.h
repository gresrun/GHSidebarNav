//
//  GHSidebarSearchViewController.h
//  GHSidebarNav
//
//  Created by Greg Haines on 11/20/11.
//

#import <Foundation/Foundation.h>
#import "GHSidebarSearchViewControllerDelegate.h"
@class GHRevealViewController;

extern const NSTimeInterval kGHSidebarDefaultSearchDelay;

@interface GHSidebarSearchViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchDisplayDelegate> {
@private
	GHRevealViewController *_sidebarVC;
	NSOperationQueue *_searchQueue;
	NSTimer *_timer;
	UIView *_searchBarSuperview;
	NSUInteger _searchBarSuperIndex;
}

@property (nonatomic, readonly) UISearchBar *searchBar;
@property (nonatomic, readonly) NSArray *entries;
@property (weak, nonatomic) id<GHSidebarSearchViewControllerDelegate> searchDelegate;
@property (nonatomic) NSTimeInterval searchDelay;

- (id)initWithSidebarViewController:(GHRevealViewController *)sidebarVC;

@end
