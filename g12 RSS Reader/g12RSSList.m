//
//  g12RSSList.m
//  g12 RSS Reader
//
//  Created by Anton on 8/7/14.
//  Copyright (c) 2014 g12-Squad. All rights reserved.
//

#import "g12RSSList.h"

@interface g12RSSList ()
{
    NSMutableArray *RSSItems;
    NSString *ArrayFileName;
}
@end

@implementation g12RSSList

/////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////// V I E W   L O A D //////////////
/////////////////////////////////////////////////////////////////////////////////////
#pragma mark - View Funtions
- (void)viewDidLoad
{
    [super viewDidLoad];

    RSSItems = [_masterController RSSList]; //Get RSS list from master
    ArrayFileName = [_masterController ArrayFileName]; //Get file name from master
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
} //Various inits

/////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////// T A B L E //////////////////////
/////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Table view

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
} //1

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return RSSItems.count;
} //RSSItems.count

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RSSCell" forIndexPath:indexPath];
    cell.textLabel.text = [NSString stringWithFormat:@"%d) %@", indexPath.row + 1, [RSSItems objectAtIndex:indexPath.row]] ;
    return cell;
} //Displays all cells

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [_masterController setUrl:RSSItems[indexPath.row]];
    [_masterController setRefreshList:YES];
    [self.navigationController popViewControllerAnimated:YES];
} //Go back with selected RSS

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
} //YES

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [RSSItems removeObjectAtIndex:indexPath.row];
        [RSSItems writeToFile:ArrayFileName atomically:YES];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
} //Enable row deleting

@end
