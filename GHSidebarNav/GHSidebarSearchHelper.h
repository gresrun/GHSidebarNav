//
//  GHSidebarSearchViewController.h
//  GHSidebarNav
//
//  Created by Greg Haines on 11/20/11.
//

#import <Foundation/Foundation.h>
@class GHRevealViewController;
@protocol GHSidebarSearchViewControllerDelegate;

extern const NSTimeInterval kGHSidebarDefaultSearchDelay;

@interface GHSidebarSearchHelper : NSObject <UITableViewDataSource, UITableViewDelegate, UISearchDisplayDelegate>

@property (weak, nonatomic) IBOutlet id<GHSidebarSearchViewControllerDelegate> searchDelegate;
@property (strong, nonatomic) GHRevealViewController *sidebarVC;
@property (nonatomic) NSTimeInterval searchDelay;

@end
