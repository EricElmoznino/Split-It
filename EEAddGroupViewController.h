//
//  EEAddGroupViewController.h
//  SplitIt
//
//  Created by ERIC ELMOZNINO on 2015-07-08.
//  Copyright (c) 2015 Eric Elmoznino. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EEGroup.h"

@interface EEAddGroupViewController : UIViewController

@property (nonatomic, weak) EEGroup *group;
@property (nonatomic, copy) void(^pushGroupController)(void);

@end
