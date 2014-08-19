//
//  g12MasterViewController.m
//  g12 RSS Reader
//
//  Created by Anton on 8/5/14.
//  Copyright (c) 2014 g12-Squad. All rights reserved.
//

#import "g12MasterViewController.h"
#import "g12DetailViewController.h"
#import "g12RSSListViewController.h"
#import "RssEntity.h"

@interface g12MasterViewController () {
    NSXMLParser *parser; //Parser
    NSMutableArray *feeds; //Stuff for parsing
    NSMutableDictionary *item; //Stuff for parsing
    NSMutableString *title; //Stuff for parsing
    NSMutableString *link; //Stuff for parsing
    NSMutableString *date; //Stuff for parsing
    NSString *element; //Stuff for parsing
    NSURL *urlUrl; //NSURL
    BOOL isItem; //Switch for parsing
    BOOL isParsed; //Switch for parsing
    UIAlertView *alert; //Alert window
    UILabel *welcomeLabel; //Black screen with text when loading
    UIWindow *mainWindow; //Main window for borders and sublayering it
    NSDate *dateDate; //Date in NSDate format
    NSDateFormatter *dateFormatter; //Date formatter
}

@end

@implementation g12MasterViewController

/////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////// M Y   F U N C S ////////////////
/////////////////////////////////////////////////////////////////////////////////////
#pragma mark - My Funtions
- (BOOL)validateUrl: (NSString *) candidate {
    NSString *urlRegEx =
    @"(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+";
    NSPredicate *urlTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", urlRegEx];
    return [urlTest evaluateWithObject:candidate];
} //Checking for correct URL

- (void)fadeOutLabel {
    [UIView animateWithDuration:0.5
                          delay:0.0  /* do not add a delay because we will use performSelector. */
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^ {
                         welcomeLabel.alpha = 0.0;
                     }
                     completion:^(BOOL finished) {
                         [welcomeLabel removeFromSuperview];
                     }];
} //Animation of fade

- (void)fadeBlackScreen {
    welcomeLabel = [[UILabel alloc] initWithFrame:mainWindow.bounds];
    [welcomeLabel setTextColor:[UIColor whiteColor]];
    [welcomeLabel setBackgroundColor:[UIColor blackColor]];
    [welcomeLabel setFont:[UIFont fontWithName: @"Trebuchet MS" size: 56.0f]];
    [welcomeLabel setText:[NSString stringWithFormat:@"Loading: \n%@",_url]];
    [welcomeLabel setTextAlignment:NSTextAlignmentCenter];
    [welcomeLabel setAdjustsFontSizeToFitWidth:YES];
    [welcomeLabel setNumberOfLines:2];
    [welcomeLabel setMinimumScaleFactor:0.1];
    [welcomeLabel setShadowColor:[UIColor grayColor]];
    [welcomeLabel setShadowOffset:CGSizeMake( 1.5, 1.5)];
    [welcomeLabel setCenter:self.view.center];
    [mainWindow addSubview:welcomeLabel];
//    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(fadeOutLabel) userInfo:nil repeats:NO];
} //Fade black screen with text when loading

/////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////// V I E W   L O A D //////////////
/////////////////////////////////////////////////////////////////////////////////////
#pragma mark - View Funtions

- (void)viewDidLoad {
    
    [super viewDidLoad];
    dateDate = [[NSDate alloc]init]; //Init NSDate
    dateFormatter = [[NSDateFormatter alloc]init]; //Init date formatter
    _refreshList = YES; //Init refresh switch
    mainWindow = [[UIApplication sharedApplication].delegate window]; //Get main window
    if (!_url) {
#ifdef __CoreDataSupport
        NSError *error;
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"RssEntity"];
        NSArray *fetchedArray = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
        for (RssEntity *rssRow in fetchedArray) {
            NSLog(@"%@ - %@", rssRow.id, rssRow.rssUrl);
        }
        
        if (fetchedArray.count) {
            RssEntity *rssRow = fetchedArray[0];
            _url = rssRow.rssUrl;
        } else {
            RssEntity *rssRow = [NSEntityDescription insertNewObjectForEntityForName:@"RssEntity" inManagedObjectContext:_managedObjectContext];
            rssRow.id = [NSDate date];
            _url = @"http://images.apple.com/main/rss/hotnews/hotnews.rss";
            rssRow.rssUrl = _url;
            if (![_managedObjectContext save:&error]) {
                NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
            }
        }
#else
        _ArrayFileName = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:RSSFileName]; //Get full file name
        _RSSList = [[NSMutableArray alloc] initWithArray:[[NSArray alloc] initWithContentsOfFile:_ArrayFileName]]; //Restore RSS list from file to array
        
        if (_RSSList.count) {
            _url = _RSSList[0];
        } else {
            _url = @"http://images.apple.com/main/rss/hotnews/hotnews.rss";
            [_RSSList addObject:[_url copy]];
            [_RSSList writeToFile:_ArrayFileName atomically:YES];
        }
        
#endif
    } //Init URL
} //Various inits

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    if (!urlUrl) urlUrl = [[NSURL alloc] initWithString:_url]; //Getting URL as NSURL from file or string
    
    if (![urlUrl.absoluteString isEqualToString:_url] || _refreshList) {
        
        urlUrl = [NSURL URLWithString:_url];
        [self fadeBlackScreen];
    }
} //Fade black screen with text if reloading other link or Refresh is YES (->)

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    if (![urlUrl.absoluteString isEqualToString:_url] || _refreshList) {
        
        _refreshList = NO;
        isItem = NO;
        isParsed = NO; //Init switches for parsing
        feeds = [[NSMutableArray alloc] init];
        parser = [[NSXMLParser alloc] initWithContentsOfURL:urlUrl];
        [parser setDelegate:self];
        [parser setShouldResolveExternalEntities:NO];
        [parser parse]; //Parser start
    }
} //(->) and parsing it a bit later

/////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////// T O P   B A R //////////////////
/////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Top Bar Items

- (void)AddRSS {
    
    [self AddRSSWithText:@"http://"];
}

- (void)AddRSSWithText: (NSString *)text {
    
    alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Please enter correct RSS path:" delegate:self cancelButtonTitle:@"Add RSS" otherButtonTitles:@"Cancel", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField * alertTextField = [alert textFieldAtIndex:0];
    alertTextField.placeholder = @"http://news.tut.by/rss/all.rss";
    alertTextField.text = text;
    [alert show];
}

- (IBAction)AddRSS:(UIButton *)sender {
    
    [self AddRSS];
} //Create alert window to receive new RSS

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        if (alertView == alert) {
            _url = [[alertView textFieldAtIndex:0] text];
            if ([self validateUrl:_url]) {
                
                urlUrl = [NSURL URLWithString:_url];
                feeds = [[NSMutableArray alloc] init];
                parser = [[NSXMLParser alloc] initWithContentsOfURL:urlUrl];
                [parser setDelegate:self];
                [parser setShouldResolveExternalEntities:NO];
                isParsed = NO;
                [self fadeBlackScreen];
                [parser parse];
                
                if (isParsed) {
                    
#ifdef __CoreDataSupport
                    NSError *error;
                    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"RssEntity"];
                    NSPredicate *isEqualToUrl = [NSPredicate predicateWithFormat:@"rssUrl == %@", _url];
                    [fetchRequest setPredicate:isEqualToUrl];
                    [fetchRequest setResultType:NSCountResultType];
                    NSArray *count = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
                    if (![count[0] intValue]) {
                        RssEntity *rssRow = [NSEntityDescription insertNewObjectForEntityForName:@"RssEntity" inManagedObjectContext:_managedObjectContext];
                        rssRow.id = [NSDate date];
                        rssRow.rssUrl = _url;
                        if (![_managedObjectContext save:&error]) {
                            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
                        }
                    }
#else
                    if (![_RSSList containsObject:_url]) {
                        [_RSSList addObject:[_url copy]];
                        [_RSSList writeToFile:_ArrayFileName atomically:YES];
                    }
#endif
                } else {
                    [self AddRSSWithText:_url];
                    [self fadeOutLabel];
                }
            } else {
                [self AddRSSWithText:_url];
            }
        }
        
    }
 } //Processing alert window link

/////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////// T A B L E //////////////////////
/////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
} //1

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return feeds.count;
} //feeds.count

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger row = indexPath.row;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.textLabel.text = [[feeds objectAtIndex:row] objectForKey:@"title"];
    dateDate = [[feeds objectAtIndex:row] objectForKey:@"date"];
    [dateFormatter setDateFormat:@"dd.MM - HH:mm (VVVV)"];
    cell.detailTextLabel.text = [dateFormatter stringFromDate:dateDate];
    
    cell.backgroundColor = Rgb2UIColor(255, (double) 128 + (row + 1) * 127 / feeds.count, (double) 0 + (row + 1) * 255 / feeds.count);
    return cell;
} //Displays all cells and making them gradient

/////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////// P A R S E R ////////////////////
/////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Parser

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    
    element = elementName;
    
    if ([element isEqualToString:@"item"]) {
        item = [[NSMutableDictionary alloc] init];
        title = [[NSMutableString alloc] init];
        link = [[NSMutableString alloc] init];
        date = [[NSMutableString alloc] init];
        isItem = YES;
        isParsed = YES;
    }
} //Gets element

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    
    if (isItem) {
        if (([element isEqualToString:@"title"]) && ([string rangeOfString:@"\n"].location == NSNotFound)) {
            string = [string stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@" "];
            [title appendString:string];
        } else if (([element isEqualToString:@"link"]) && ([string rangeOfString:@"\n"].location == NSNotFound)) {
            [link appendString:string];
        } else if (([element isEqualToString:@"pubDate"]) && ([string rangeOfString:@"\n"].location == NSNotFound)) {
            [date appendString:string];
        }
    }
    
} //Fill title and link

- (void) parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    
    if ([elementName isEqualToString:@"item"]) {
        [item setObject:title forKey:@"title"];
        [item setObject:link forKey:@"link"];
        
        [dateFormatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss Z"]; // @"Sun, 24 Mar 2013 00:42:13 +0200";
        dateDate = [dateFormatter dateFromString:date];
        if (!dateDate)
        {
            [dateFormatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss z"]; // @"Tue, 29 Jul 2014 12:34:16 PDT"
            dateDate = [dateFormatter dateFromString:date];
        }
        [item setObject:dateDate forKey:@"date"];
        

        isItem = NO;
        
        [feeds addObject:[item copy]];
    }
} //Fill feeds array with filled dictionary item

- (void) parserDidEndDocument:(NSXMLParser *)parser {
    [self.tableView reloadData];
    [self fadeOutLabel]; //Parse finished so let's show results
} //Refresh table view

/////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////// S E G U E //////////////////////
/////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        [[segue destinationViewController] setUrl:[feeds[[self.tableView indexPathForSelectedRow].row] objectForKey: @"link"]];
    } else if ([[segue identifier] isEqualToString:@"ShowRSS"]){
        [[segue destinationViewController] setMasterController:self];
    }
} //Do stuff for segue

@end
