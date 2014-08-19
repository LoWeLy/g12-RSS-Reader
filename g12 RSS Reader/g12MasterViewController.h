//
//  g12MasterViewController.h
//  g12 RSS Reader
//
//  Created by Anton on 8/5/14.
//  Copyright (c) 2014 g12-Squad. All rights reserved.
//

@interface g12MasterViewController : UITableViewController <NSXMLParserDelegate>

@property (nonatomic)           IBOutlet UITableView *tableView;
@property (nonatomic, copy)     NSString *url;
@property (nonatomic, assign)   BOOL refreshList;

#ifdef __CoreDataSupport
@property (nonatomic)           NSManagedObjectContext *managedObjectContext; //init from AppDelegate.m
#else
@property (nonatomic)           NSMutableArray *RSSList; //RSS list from file
@property (nonatomic)           NSString *ArrayFileName; //Name of file
#endif

- (BOOL) validateUrl: (NSString *) candidate;
- (IBAction)AddRSS:(UIBarButtonItem *)sender;
- (void) fadeOutLabel;

@end