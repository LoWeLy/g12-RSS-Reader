//
//  g12MasterViewController.h
//  g12 RSS Reader
//
//  Created by Anton on 8/5/14.
//  Copyright (c) 2014 g12-Squad. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "defines.h"

@interface g12MasterViewController : UITableViewController <NSXMLParserDelegate>

- (BOOL) validateUrl: (NSString *) candidate;

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (copy) NSString *url;

- (IBAction)AddRSS:(UIBarButtonItem *)sender;

@end
