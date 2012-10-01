//
//  GHMenuViewController.h
//  GHSidebarNav
//
//  Created by Greg Haines on 1/3/12.
//  Copyright (c) 2012 Greg Haines. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface GHMenuViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *menuTableView;

- (void)selectRowAtIndexPath:(NSIndexPath *)indexPath 
					animated:(BOOL)animated 
			  scrollPosition:(UITableViewScrollPosition)scrollPosition;

@end
