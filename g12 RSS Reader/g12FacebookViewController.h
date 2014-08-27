//
//  g12FacebookViewController.h
//  g12 RSS Reader
//
//  Created by Anton on 8/27/14.
//  Copyright (c) 2014 g12-Squad. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface g12FacebookViewController : UIViewController <FBLoginViewDelegate>

@property (nonatomic) NSManagedObjectContext *managedObjectContext; //init from AppDelegate.m

@end
