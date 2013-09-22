//
//  GHSidebarSearchViewController.h
//  GHSidebarNav
//
//  Created by Greg Haines on 11/20/11.
//

#import "GHSidebarSearchViewControllerDelegate.h"
@class GHRevealViewController;


extern const NSTimeInterval kGHSidebarDefaultSearchDelay;

@interface GHSidebarSearchViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchDisplayDelegate>

@property (nonatomic, readonly) UISearchBar *searchBar;
@property (nonatomic, readonly) NSArray *entries;
@property (weak, nonatomic) id<GHSidebarSearchViewControllerDelegate> searchDelegate;
@property (nonatomic) NSTimeInterval searchDelay;

- (id)initWithSidebarViewController:(GHRevealViewController *)sidebarVC;

@end
