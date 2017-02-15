//
//  EEPurchaseTableCell.h
//  SplitIt
//
//  Created by GAD ELMOZNINO on 2015-07-14.
//  Copyright (c) 2015 Eric Elmoznino. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EEPurchaseTableCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *thumbnailView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *costLabel;
@property (nonatomic, copy) void(^showImageBlock)(void);

@end
