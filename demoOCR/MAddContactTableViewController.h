//
//  MAddContactTableViewController.h
//  ales_crm
//
//  Created by Matthieu Lemonnier on 04/06/2014.
//  Copyright (c) 2014 Masao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MAddContactTableViewController : UITableViewController

@property (strong, nonatomic) NSMutableDictionary *objects;

- (void) dataFromImage:(NSDictionary *)dict;

@end
