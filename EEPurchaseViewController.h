//
//  EEPurchaseViewController.h
//  SplitIt
//
//  Created by ERIC ELMOZNINO on 2015-07-11.
//  Copyright (c) 2015 Eric Elmoznino. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EEGroup.h"
#import "EEPurchase.h"

@interface EEPurchaseViewController : UIViewController

@property (nonatomic, weak) EEGroup *group;
@property (nonatomic, weak) EEPurchase *purchase;
@property (nonatomic, strong) NSMutableDictionary *contributionsCopy;
@property (nonatomic, strong) NSMutableDictionary *includedCopy;

- (instancetype)initWithNew:(BOOL)isNew;

@end
