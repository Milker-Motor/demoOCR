//
//  MFieldContactCell.m
//  ales_crm
//
//  Created by Matthieu Lemonnier on 04/06/2014.
//  Copyright (c) 2014 Masao. All rights reserved.
//

#import "MFieldContactCell.h"

@interface MFieldContactCell()
{
    SEL     _selector;
}

@property (strong, nonatomic) IBOutlet UILabel      * label;
@property (strong, nonatomic) IBOutlet UITextField  * field;

@end

@implementation MFieldContactCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)loadCellWithLabel:(NSString *)label andValue:(NSString *)field
{

    if([NSLocalizedString(@"Nom", nil) isEqual:label])
        _label.textColor = [UIColor redColor];
    else
        _label.textColor = [UIColor blackColor];
    
    _label.text = [NSString stringWithFormat:@"%@:", label];
    _field.text = field;
    [_field setAutocorrectionType:UITextAutocorrectionTypeNo];
}

@end
