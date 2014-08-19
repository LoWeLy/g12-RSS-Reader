//
//  g12RSSList.m
//  g12 RSS Reader
//
//  Created by Anton on 8/7/14.
//  Copyright (c) 2014 g12-Squad. All rights reserved.
//

#import "g12RSSListViewController.h"
#import "g12MasterViewController.h"
#import "RssEntity.h"

@interface g12RSSList ()
{
    NSMutableArray *RSSItems;
    NSString *ArrayFileName;
#ifdef __CoreDataSupport
    NSMutableArray *fetchedArray;
    int idCounter;
#endif
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

    self.navigationItem.rightBarButtonItem = self.editButtonItem;
#ifdef __CoreDataSupport
    _managedObjectContext = [_masterController managedObjectContext]; //Get managed object context from master
    NSError *error;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"RssEntity"];
    fetchedArray = [NSMutableArray arrayWithArray:[_managedObjectContext executeFetchRequest:fetchRequest error:&error]];
#else
    RSSItems = [_masterController RSSList]; //Get RSS list from master
    ArrayFileName = [_masterController ArrayFileName]; //Get file name from master
#endif

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
#ifdef __CoreDataSupport
    return fetchedArray.count;
#else
    return RSSItems.count;
#endif
} //Rows count

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger row = indexPath.row;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RSSCell" forIndexPath:indexPath];
#ifdef __CoreDataSupport
    cell.textLabel.text = [NSString stringWithFormat:@"%@", [fetchedArray[row] rssUrl]];
#else
    cell.textLabel.text = [NSString stringWithFormat:@"%d) %@", row + 1, [RSSItems objectAtIndex:row]];
#endif
    return cell;
} //Displays all cells

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger row = indexPath.row;
#ifdef __CoreDataSupport
    [_masterController setUrl:[fetchedArray[row] rssUrl]];
#else
    [_masterController setUrl:RSSItems[row]];
#endif
    [_masterController setRefreshList:YES];
    [self.navigationController popViewControllerAnimated:YES];
} //Go back with selected RSS

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
} //YES

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = indexPath.row;
    if (editingStyle == UITableViewCellEditingStyleDelete) {
#ifdef __CoreDataSupport
        NSError *error;
        RssEntity *rssRow = fetchedArray[row];
        [_managedObjectContext deleteObject:rssRow];
        [fetchedArray removeObjectAtIndex:row];
        if (![_managedObjectContext save:&error]) {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
#else
        [RSSItems removeObjectAtIndex:row];
        [RSSItems writeToFile:ArrayFileName atomically:YES];
#endif
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
} //Enable row deleting

@end
