//
//  EEImageViewController.h
//  SplitIt
//
//  Created by GAD ELMOZNINO on 2015-07-15.
//  Copyright (c) 2015 Eric Elmoznino. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EEImageStore.h"
#import "EEPurchase.h"
#import "EEPerson.h"

@interface EEImageViewController : UIViewController

@property (nonatomic, weak) EEPurchase *purchase;
@property (nonatomic, weak) EEPerson *person;

@end
