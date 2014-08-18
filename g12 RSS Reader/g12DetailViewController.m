//
//  g12DetailViewController.m
//  g12 RSS Reader
//
//  Created by Anton on 8/5/14.
//  Copyright (c) 2014 g12-Squad. All rights reserved.
//

#import "g12DetailViewController.h"

@implementation g12DetailViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString: [_url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]]]; //Load web to screen
}

@end
