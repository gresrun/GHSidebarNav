//
//  GHRootViewController.h
//  GHSidebarNav
//
//  Created by Greg Haines on 11/20/11.
//

#import <Foundation/Foundation.h>

typedef void (^RevealBlock)();

@interface GHRootViewController : UIViewController {
@private
	RevealBlock _revealBlock;
}

- (id)initWithTitle:(NSString *)title withRevealBlock:(RevealBlock)revealBlock;

@end
