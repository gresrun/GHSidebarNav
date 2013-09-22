//
//  GHMenuViewController.h
//  GHSidebarNav
//
//  Created by Greg Haines on 1/3/12.
//  Copyright (c) 2012 Greg Haines. All rights reserved.
//

@class GHRevealViewController;


@interface GHMenuViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

- (id)initWithSidebarViewController:(GHRevealViewController *)sidebarVC 
					  withSearchBar:(UISearchBar *)searchBar 
						withHeaders:(NSArray *)headers 
					withControllers:(NSArray *)controllers 
					  withCellInfos:(NSArray *)cellInfos;

- (void)selectRowAtIndexPath:(NSIndexPath *)indexPath 
					animated:(BOOL)animated 
			  scrollPosition:(UITableViewScrollPosition)scrollPosition;

@end
