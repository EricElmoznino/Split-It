//
//  EESplitItTableCell.h
//  SplitIt
//
//  Created by GAD ELMOZNINO on 2015-07-15.
//  Copyright (c) 2015 Eric Elmoznino. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EESplitItTableCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *payerLabel;
@property (weak, nonatomic) IBOutlet UILabel *amountLabel;
@property (weak, nonatomic) IBOutlet UILabel *receiverLabel;

@end
