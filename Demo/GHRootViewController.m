//
//  GHRootViewController.m
//  GHSidebarNav
//
//  Created by Greg Haines on 11/20/11.
//

#import "GHRootViewController.h"
#import "GHRevealViewController.h"


#pragma mark Implementation
@implementation GHRootViewController

#pragma mark Public Methods
- (IBAction)revealSidebar:(id)sender {
    GHRevealViewController *revealVC = (GHRevealViewController *)self.parentViewController.parentViewController;
    [revealVC toggleSidebar:!revealVC.sidebarShowing duration:kGHRevealSidebarDefaultAnimationDuration];
}

@end
