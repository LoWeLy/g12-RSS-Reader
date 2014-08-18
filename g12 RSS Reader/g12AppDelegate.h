//
//  g12AppDelegate.h
//  g12 RSS Reader
//
//  Created by Anton on 8/5/14.
//  Copyright (c) 2014 g12-Squad. All rights reserved.
//

@interface g12AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
//Core Data
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end
