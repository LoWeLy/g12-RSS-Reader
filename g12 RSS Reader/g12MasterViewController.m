//
//  g12MasterViewController.m
//  g12 RSS Reader
//
//  Created by Anton on 8/5/14.
//  Copyright (c) 2014 g12-Squad. All rights reserved.
//

#import "g12MasterViewController.h"
#import "g12DetailViewController.h"
#import "g12RSSList.h"

@interface g12MasterViewController () {
    NSXMLParser *parser; //Parser
    NSMutableArray *feeds; //Stuff for parsing
    NSMutableDictionary *item; //Stuff for parsing
    NSMutableString *title; //Stuff for parsing
    NSMutableString *link; //Stuff for parsing
    NSString *element; //Stuff for parsing
    NSURL *urlUrl; //NSURL
    BOOL isItem; //Switch for parsing
    BOOL isParsed; //Switch for parsing
    UIAlertView *alert; //Alert window
    UILabel *welcomeLabel; //Black screen with text when loading
    UIWindow *mainWindow; //Main window for borders and sublayering it
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
    
    _refreshList = YES; //Init refresh switch
    mainWindow = [[UIApplication sharedApplication].delegate window]; //Get main window
    _ArrayFileName = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:RSSFileName]; //Get full file name
    _RSSList = [[NSMutableArray alloc] initWithArray:[[NSArray alloc] initWithContentsOfFile:_ArrayFileName]]; //Restore RSS list from file to array
    if (!_url) {
        if (_RSSList.count) {
            _url = _RSSList[0];
        } else {
            _url = @"http://images.apple.com/main/rss/hotnews/hotnews.rss";
            [_RSSList addObject:[_url copy]];
            [_RSSList writeToFile:_ArrayFileName atomically:YES];
        }
    } //Init URL
} //Various inits

- (void)viewWillAppear:(BOOL)animated {
    
    if (!urlUrl) urlUrl = [[NSURL alloc] initWithString:_url]; //Getting URL as NSURL from file or string
    
    if (![urlUrl.absoluteString isEqualToString:_url] || _refreshList) {
        
        urlUrl = [NSURL URLWithString:_url];
        [self fadeBlackScreen];
    }
} //Fade black screen with text if reloading other link or Refresh is YES (->)

- (void)viewDidAppear:(BOOL)animated {
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

- (IBAction)AddRSS:(UIButton *)sender {
    
    alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Please enter RSS path:" delegate:self cancelButtonTitle:@"Add RSS" otherButtonTitles:nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField * alertTextField = [alert textFieldAtIndex:0];
    alertTextField.placeholder = @"RSS path";
    alertTextField.text = @"http://news.tut.by/rss/all.rss";
    [alert show];
} //Create alert window to receive new RSS

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
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
            
            if ( (![_RSSList containsObject:_url]) && (isParsed) ) {
                [_RSSList addObject:[_url copy]];
                [_RSSList writeToFile:_ArrayFileName atomically:YES];
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
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.textLabel.text = [NSString stringWithFormat:@"%d) %@", indexPath.row + 1, [[feeds objectAtIndex:indexPath.row] objectForKey:@"title"]];

    cell.backgroundColor = Rgb2UIColor(255, (double) 128 + (indexPath.row + 1) * 127 / feeds.count, (double) 0 + (indexPath.row + 1) * 255 / feeds.count);
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
        }
    }
    
} //Fill title and link

- (void) parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    
    if ([elementName isEqualToString:@"item"]) {
        [item setObject:title forKey:@"title"];
        [item setObject:link forKey:@"link"];
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
