//
//  g12RSSList.h
//  g12 RSS Reader
//
//  Created by Anton on 8/7/14.
//  Copyright (c) 2014 g12-Squad. All rights reserved.
//

@class g12MasterViewController;

@interface g12RSSList : UITableViewController

@property (nonatomic) g12MasterViewController *masterController;
@property (nonatomic) NSManagedObjectContext *managedObjectContext; //init from AppDelegate.m

@end