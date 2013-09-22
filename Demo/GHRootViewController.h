//
//  GHRootViewController.h
//  GHSidebarNav
//
//  Created by Greg Haines on 11/20/11.
//


typedef void (^RevealBlock)();

@interface GHRootViewController : UIViewController

- (id)initWithTitle:(NSString *)title withRevealBlock:(RevealBlock)revealBlock;

@end
