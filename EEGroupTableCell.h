//
//  EEGroupTableCell.h
//  SplitIt
//
//  Created by GAD ELMOZNINO on 2015-07-15.
//  Copyright (c) 2015 Eric Elmoznino. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EEGroupTableCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberOfPeopleLabel;

@end
