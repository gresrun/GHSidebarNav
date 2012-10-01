//
//  GHSidebarSearchViewControllerDelegate.h
//  GHSidebarNav
//
//  Created by Greg Haines on 1/7/12.
//

#import <Foundation/Foundation.h>

typedef void (^SearchResultsBlock)(NSArray *);

@protocol GHSidebarSearchViewControllerDelegate <NSObject>
@required
- (void)searchBegan;
- (void)searchEnded;
- (void)searchResultsForText:(NSString *)text withScope:(NSString *)scope callback:(SearchResultsBlock)callback;
- (void)searchController:(UISearchDisplayController *)controller selectedResult:(id)result atIndexPath:(NSIndexPath *)indexPath;
- (UITableViewCell *)searchResultCellForEntry:(id)entry atIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView;
@end
