//
//  g12MasterViewController.m
//  g12 RSS Reader
//
//  Created by Anton on 8/5/14.
//  Copyright (c) 2014 g12-Squad. All rights reserved.
//

#import "g12MasterViewController.h"

#import "g12DetailViewController.h"

@interface g12MasterViewController () {
    NSXMLParser *parser;
    NSMutableArray *feeds;
    NSMutableDictionary *item;
    NSMutableString *title;
    NSMutableString *link;
    NSString *element;
    NSURL *urlUrl;
    BOOL isElement;
    BOOL isParsed;
    UIAlertView *alert;
    
    NSMutableArray *RSSList;
    NSString *ArrayFileName;
}

@end

@implementation g12MasterViewController

- (BOOL) validateUrl: (NSString *) candidate {
    NSString *urlRegEx =
    @"(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+";
    NSPredicate *urlTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", urlRegEx];
    return [urlTest evaluateWithObject:candidate];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    isElement = NO;
    isParsed = NO;
    
    //Creating a file path under iOS:
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    ArrayFileName = [documentsDirectory stringByAppendingPathComponent:RSSFileName];
//    NSError *temperr = [[NSError alloc] init];
//    [[NSFileManager defaultManager] removeItemAtPath:ArrayFileName error:&temperr];
    NSArray *tempArray = [[NSArray alloc] initWithContentsOfFile:ArrayFileName];
    RSSList = [[NSMutableArray alloc] init];
    [RSSList addObjectsFromArray:tempArray];
    if (!_url)
    {
        if (RSSList) {
            _url = RSSList[0];
        }
        else
        {
        _url = @"http://images.apple.com/main/rss/hotnews/hotnews.rss";
        }
    }
    urlUrl = [[NSURL alloc] initWithString:_url];
    
    feeds = [[NSMutableArray alloc] init];
    parser = [[NSXMLParser alloc] initWithContentsOfURL:urlUrl];
    [parser setDelegate:self];
    [parser setShouldResolveExternalEntities:NO];
    [parser parse];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return feeds.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
//    cell.textLabel.text = [NSString stringWithFormat:@"%d", indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%d) %@", indexPath.row, [[feeds objectAtIndex:indexPath.row] objectForKey:@"title"]] ;
    return cell;
}

#pragma mark - parser

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    element = elementName;
    
    if ([element isEqualToString:@"item"])
    {
        item = [[NSMutableDictionary alloc] init];
        title = [[NSMutableString alloc] init];
        link = [[NSMutableString alloc] init];
        isElement = YES;
        isParsed = YES;
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if (isElement) {
        if ([element isEqualToString:@"title"])
        {
            [title appendString:string];
        } else if ([element isEqualToString:@"link"])
        {
            [link appendString:string];
        }
    }
    
}

- (void) parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if ([elementName isEqualToString:@"item"]) {
        [item setObject:title forKey:@"title"];
        [item setObject:link forKey:@"link"];
        isElement = NO;
        
        [feeds addObject:[item copy]];
    }
}

- (void) parserDidEndDocument:(NSXMLParser *)parser
{
    [self.tableView reloadData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSString *string = [feeds[indexPath.row] objectForKey: @"link"];
        [[segue destinationViewController] setUrl:string];        
    }
}


- (IBAction)AddRSS:(UIButton *)sender {
    alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Please enter RSS path:" delegate:self cancelButtonTitle:@"Add RSS" otherButtonTitles:nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField * alertTextField = [alert textFieldAtIndex:0];
    alertTextField.placeholder = @"RSS path";
    alertTextField.text = @"http://lenta.ru/rss";
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView == alert) {
        NSString *enteredUrl = [[alertView textFieldAtIndex:0] text];
        if ([self validateUrl:enteredUrl]) {
            
            feeds = [[NSMutableArray alloc] init];
            urlUrl = [NSURL URLWithString:enteredUrl];
            parser = [[NSXMLParser alloc] initWithContentsOfURL:urlUrl];
            
            [parser setDelegate:self];
            [parser setShouldResolveExternalEntities:NO];
            isParsed = NO;
            [parser parse];
            
            if ( (![RSSList containsObject:enteredUrl]) && (isParsed) ) {
                [RSSList addObject:[enteredUrl copy]];
                [RSSList writeToFile:ArrayFileName atomically:YES];
            }
        }
    }
}

@end
