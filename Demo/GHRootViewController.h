//
//  GHRootViewController.h
//  GHSidebarNav
//
//  Created by Greg Haines on 11/20/11.
//

#import <Foundation/Foundation.h>

@interface GHRootViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *pushButton;

- (id)initWithTitle:(NSString *)title;

- (IBAction)revealSidebar:(id)sender;

@end
