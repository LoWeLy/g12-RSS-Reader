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
    
    ArrayFileName = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:RSSFileName]; //Get full file name
    RSSItems = [[NSMutableArray alloc] initWithArray:[[NSArray alloc] initWithContentsOfFile:ArrayFileName]]; //Restore RSS list from file to array
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

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
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *string = RSSItems[indexPath.row];
    [_masterController setUrl:string];
    [_masterController setRefreshList:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
} //YES

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [RSSItems removeObjectAtIndex:indexPath.row];
        [RSSItems writeToFile:ArrayFileName atomically:YES];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

//#pragma mark - Navigation
//
//// In a storyboard-based application, you will often want to do a little preparation before navigation
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//{
//    // Get the new view controller using [segue destinationViewController].
//    // Pass the selected object to the new view controller.
//    if ([[segue identifier] isEqualToString:@"returnToMain"]) {
//        
//        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
//        NSString *string = RSSItems[indexPath.row];
//        [[segue destinationViewController] setUrl:string];
//        [[segue destinationViewController] setIsNewRSS:YES];
//    }
//}

@end
