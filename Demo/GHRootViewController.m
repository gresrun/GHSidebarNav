//
//  GHRootViewController.m
//  GHSidebarNav
//
//  Created by Greg Haines on 11/20/11.
//

#import "GHRootViewController.h"
#import "GHPushedViewController.h"
#import "GHRevealViewController.h"


#pragma mark Private Interface
@interface GHRootViewController ()
- (void)doPush;
@end

#pragma mark Implementation
@implementation GHRootViewController

#pragma mark Properties
@synthesize pushButton;

#pragma mark Memory Management
- (id)initWithTitle:(NSString *)title {
    if (self = [super initWithNibName:nil bundle:nil]) {
		self.title = title;
        self.navigationItem.leftBarButtonItem =
            [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                          target:self
                                                          action:@selector(revealSidebar:)];
        [self.pushButton addTarget:self action:@selector(doPush) forControlEvents:UIControlEventTouchUpInside];
	}
	return self;
}

#pragma mark UIViewController
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([@"PushIt" isEqualToString:segue.identifier]) {
        UIViewController *vc = segue.destinationViewController;
        vc.title = [self.title stringByAppendingString:@" - Pushed"];
    }
}

#pragma mark Public Methods
- (IBAction)revealSidebar:(id)sender {
    GHRevealViewController *revealVC = (GHRevealViewController *)self.parentViewController.parentViewController;
    [revealVC toggleSidebar:!revealVC.sidebarShowing duration:kGHRevealSidebarDefaultAnimationDuration];
}

#pragma mark Private Methods
- (void)doPush {
    UIViewController *vc = [[GHPushedViewController alloc] initWithNibName:nil bundle:nil];
    vc.title = [self.title stringByAppendingString:@" - Pushed"];
}

@end
