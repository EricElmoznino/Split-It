//
//  EEPersonViewController.h
//  SplitIt
//
//  Created by ERIC ELMOZNINO on 2015-07-11.
//  Copyright (c) 2015 Eric Elmoznino. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EEGroup.h"
#import "EEPerson.h"

@interface EEPersonViewController : UIViewController

@property (nonatomic, weak) EEGroup *group;
@property (nonatomic, weak) EEPerson *person;

- (instancetype)initWithNew:(BOOL)isNew;

@end
