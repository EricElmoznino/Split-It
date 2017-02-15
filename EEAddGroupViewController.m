//
//  EEAddGroupViewController.m
//  SplitIt
//
//  Created by ERIC ELMOZNINO on 2015-07-08.
//  Copyright (c) 2015 Eric Elmoznino. All rights reserved.
//

#import "EEAddGroupViewController.h"
#import "EEGroupStore.h"

@interface EEAddGroupViewController ()

@property (weak, nonatomic) IBOutlet UITextField *groupNameField;

@end

@implementation EEAddGroupViewController

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        self.navigationItem.title = @"New Group";
        
        UIBarButtonItem *doneItem = [[UIBarButtonItem alloc]
                                     initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                     target:self
                                     action:@selector(save:)];
        self.navigationItem.rightBarButtonItem = doneItem;
        
        UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                       target:self
                                       action:@selector(cancel:)];
        self.navigationItem.leftBarButtonItem = cancelItem;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.groupNameField.text = @"New Group";
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.view endEditing:YES];
    
    self.group.name = self.groupNameField.text;
}

- (void)save:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:NO completion:self.pushGroupController];
}

- (void)cancel:(id)sender
{
    [[EEGroupStore sharedStore] removeGroup:self.group];
    
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if ([self.groupNameField.text isEqualToString:@"New Group"]) {
        self.groupNameField.text = @"";
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if ([self.groupNameField.text isEqualToString:@""]) {
        self.groupNameField.text = @"New Group";
    }
    
    return YES;
}

- (IBAction)backGroundTapped:(id)sender
{
    [self.view endEditing:YES];
}

@end
