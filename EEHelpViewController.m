//
//  EEHelpViewController.m
//  SplitIt
//
//  Created by GAD ELMOZNINO on 2015-07-20.
//  Copyright (c) 2015 Eric Elmoznino. All rights reserved.
//

#import "EEHelpViewController.h"

@interface EEHelpViewController ()

@property (weak, nonatomic) IBOutlet UILabel *helpLabel;

@end

@implementation EEHelpViewController

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        self.navigationItem.title = @"Help";
    }
    
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:self.helpLabel
                                                                      attribute:NSLayoutAttributeLeading
                                                                      relatedBy:0
                                                                         toItem:self.view
                                                                      attribute:NSLayoutAttributeLeading
                                                                     multiplier:1.0
                                                                       constant:20];
    [self.view addConstraint:leftConstraint];
    
    NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:self.helpLabel
                                                                       attribute:NSLayoutAttributeTrailing
                                                                       relatedBy:0
                                                                          toItem:self.view
                                                                       attribute:NSLayoutAttributeTrailing
                                                                      multiplier:1.0
                                                                        constant:-20];
    [self.view addConstraint:rightConstraint];
}

@end
