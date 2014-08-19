//
//  RssEntity.h
//  g12 RSS Reader
//
//  Created by Anton on 8/18/14.
//  Copyright (c) 2014 g12-Squad. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface RssEntity : NSManagedObject

@property (nonatomic) NSDate *id;
@property (nonatomic) NSString *rssUrl;

@end
