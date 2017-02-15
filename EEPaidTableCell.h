//
//  EEPaidTableCell.h
//  SplitIt
//
//  Created by GAD ELMOZNINO on 2015-07-12.
//  Copyright (c) 2015 Eric Elmoznino. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EEPerson.h"

@interface EEPaidTableCell : UITableViewCell

@property (nonatomic, weak) EEPerson *person;

@property (nonatomic, weak) NSMutableDictionary *contributions;
@property (nonatomic, weak) NSMutableDictionary *included;

@property (nonatomic, copy) void(^updateCostActionBlock)(void);
@property (nonatomic, copy) void(^updatePurchasePermittedBlock)(void);
@property (nonatomic, copy) void(^reloadTableBlock)(void);

@property (nonatomic) BOOL evenSplitting;

@property (nonatomic) BOOL canGoBack;

@property (weak, nonatomic) IBOutlet UILabel *shouldPayNextLabel;

@end
