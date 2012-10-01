//
//  GHSidebarSearchViewController.h
//  GHSidebarNav
//
//  Created by Greg Haines on 11/20/11.
//

#import <Foundation/Foundation.h>
@protocol GHSidebarSearchViewControllerDelegate;

extern const NSTimeInterval kGHSidebarDefaultSearchDelay;

@interface GHSidebarSearchHelper : NSObject <UITableViewDataSource, UITableViewDelegate, UISearchDisplayDelegate>

@property (weak, nonatomic) IBOutlet id<GHSidebarSearchViewControllerDelegate> searchDelegate;
@property (nonatomic) NSTimeInterval searchDelay;

@end
