//
//  MAddContactTableViewController.m
//  ales_crm
//
//  Created by Matthieu Lemonnier on 04/06/2014.
//  Copyright (c) 2014 Masao. All rights reserved.
//

#import "MAddContactTableViewController.h"
#import "MFieldContactCell.h"

@interface MAddContactTableViewController ()
{
    NSArray *keys;
    NSMutableDictionary *objectsToShow;
    NSMutableDictionary *additionalHeader;
    NSMutableArray *name;
}

@end

@implementation MAddContactTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    keys = [[NSArray alloc] initWithObjects:@"Name", @"E-mail", @"Phones", @"Web", @"Address", @"Job", nil];
    name = [[NSMutableArray alloc] init];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return objectsToShow.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [objectsToShow[keys[section]] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *textLabel = @"";
    MFieldContactCell *cellField = [tableView dequeueReusableCellWithIdentifier:@"FieldContactCell" forIndexPath:indexPath];
    
    if (indexPath.section == 0)
    {
        textLabel = name[indexPath.row];
//        if (indexPath.row == 0)
//            textLabel = @"First Name";
//        else if (indexPath.row == 1)
//            textLabel = @"Last Name";
//        else
//            textLabel = @"Other";
    }
    else
    {
        textLabel = keys[indexPath.section];
    }
    
    if ([additionalHeader[keys[indexPath.section]] containsObject:objectsToShow[keys[indexPath.section]][indexPath.row]])
    {
        cellField.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else
        cellField.accessoryType = UITableViewCellAccessoryNone;
    
    [cellField loadCellWithLabel:textLabel andValue:objectsToShow[keys[indexPath.section]][indexPath.row]];
    return  cellField;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.accessoryType == UITableViewCellAccessoryNone)
    {
        [additionalHeader[keys[indexPath.section]] addObject:objectsToShow[keys[indexPath.section]][indexPath.row]];
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    }
    else
    {
        [additionalHeader[keys[indexPath.section]] removeObject:objectsToShow[keys[indexPath.section]][indexPath.row]];
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
    [self.tableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 25;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *returnString = keys[section];
    for (NSString *string in additionalHeader[keys[section]])
    {
        returnString = [NSString stringWithFormat:@"%@ %@", returnString, string];
    }
    return returnString;
}

- (void) dataFromImage:(NSDictionary *)dict
{
    _objects = [[NSMutableDictionary alloc] initWithDictionary:dict];
    
    objectsToShow = [[NSMutableDictionary alloc] init];
    additionalHeader = [[NSMutableDictionary alloc] init];
    
    additionalHeader[keys[0]] = [[NSMutableArray alloc] init];
    objectsToShow[keys[0]] = [[NSMutableArray alloc] init];
    
    NSArray *object = _objects[@"First Name"];
    [objectsToShow[keys[0]] addObject:object.count ? object[0] : @""];
    [name addObject:@"First Name"];
    if (object.count)
    {
        [additionalHeader[keys[0]] addObject:object[0]];
    }
    
    object = _objects[@"Middle Name"];
    if (object.count)
    {
        [objectsToShow[keys[0]] addObject:object[0]];
        [additionalHeader[keys[0]] addObject:object[0]];
        [name addObject:@"Middle Name"];
    }
    
    object = _objects[@"Last Name"];
    [objectsToShow[keys[0]] addObject:object.count ? object[0] : @""];
    [name addObject:@"Last Name"];
    if (object.count)
    {
        [additionalHeader[keys[0]] addObject:object[0]];
    }
    
    object = _objects[@"Extra Name"];
    if (object.count)
    {
        [objectsToShow[keys[0]] addObject:object[0]];
        [additionalHeader[keys[0]] addObject:object[0]];
        [name addObject:@"Extra Name"];
    }
    
    [additionalHeader[keys[0]] addObject:objectsToShow[keys[0]][1]];
    
    object = _objects[@"E-mail"];
    additionalHeader[keys[1]] = [[NSMutableArray alloc] init];
    objectsToShow[keys[1]] = [[NSMutableArray alloc] init];
    objectsToShow[keys[1]] = object;
    
    if (object.count)
        [additionalHeader[keys[1]] addObject:object[0]];
    
    additionalHeader[keys[2]] = [[NSMutableArray alloc] init];
    objectsToShow[keys[2]] = [[NSMutableArray alloc] init];
    for (NSString *value in _objects[@"Phone"])
    {
        [objectsToShow[keys[2]] addObject:value];
    }
    for (NSString *value in _objects[@"Mobile"])
    {
        [objectsToShow[keys[2]] addObject:value];
    }
    if ([objectsToShow[keys[2]] count])
        [additionalHeader[keys[2]] addObject:objectsToShow[keys[2]][0]];
    
    object = _objects[@"Web"];
    additionalHeader[keys[3]] = [[NSMutableArray alloc] init];
    objectsToShow[keys[3]] = [[NSMutableArray alloc] init];
    objectsToShow[keys[3]] = object;
    if (object.count)
        [additionalHeader[keys[3]] addObject:object[0]];
    
    object = _objects[@"Address"];
    additionalHeader[keys[4]] = [[NSMutableArray alloc] init];
    objectsToShow[keys[4]] = [[NSMutableArray alloc] init];
    objectsToShow[keys[4]] = object;
    if (object.count)
        [additionalHeader[keys[4]] addObject:object[0]];
    
    object = _objects[@"Job"];
    additionalHeader[keys[5]] = [[NSMutableArray alloc] init];
    objectsToShow[keys[5]] = [[NSMutableArray alloc] init];
    objectsToShow[keys[5]] = object;
    if (object.count)
        [additionalHeader[keys[5]] addObject:object[0]];
    
    [self.tableView reloadData];
}

@end
