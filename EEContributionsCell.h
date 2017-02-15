//
//  EEContributionsCell.h
//  SplitIt
//
//  Created by GAD ELMOZNINO on 2015-07-14.
//  Copyright (c) 2015 Eric Elmoznino. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EEContributionsCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *thumbailView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *costLabel;
@property (weak, nonatomic) IBOutlet UILabel *paidLabel;
@property (weak, nonatomic) IBOutlet UIImageView *thumbnailView;

@end
