//
//  g12MasterViewController.h
//  g12 RSS Reader
//
//  Created by Anton on 8/5/14.
//  Copyright (c) 2014 g12-Squad. All rights reserved.
//

#import "defines.h"
#import "g12RSSList.h"

@interface g12MasterViewController : UITableViewController <NSXMLParserDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (copy) NSString *url;
@property BOOL refreshList;
@property NSMutableArray *RSSList; //RSS list from file
@property NSString *ArrayFileName; //Name of file

- (BOOL) validateUrl: (NSString *) candidate;
- (IBAction)AddRSS:(UIBarButtonItem *)sender;
- (void) fadeOutLabel;

@end
