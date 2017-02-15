//
//  EEMoreViewController.m
//  SplitIt
//
//  Created by GAD ELMOZNINO on 2015-07-20.
//  Copyright (c) 2015 Eric Elmoznino. All rights reserved.
//

#import "EEMoreViewController.h"
#import "EEHelpViewController.h"
#import "EECopyrightViewController.h"

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

@interface EEMoreViewController ()
<MFMailComposeViewControllerDelegate>

@end

@implementation EEMoreViewController

- (instancetype)init {
    self = [super initWithStyle:UITableViewStylePlain];
    
    if (self) {
        self.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemMore tag:0];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
    
    //Hide empty cells
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //Erase the add button created by the other tabbed view controllers
    self.tabBarController.navigationItem.rightBarButtonItem = nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    
    cell.textLabel.font = [UIFont systemFontOfSize:17];
    cell.textLabel.textColor = [UIColor colorWithRed:0
                                               green:0.47843137
                                                blue:1
                                               alpha:1];
    
    if (indexPath.row == 0) {
        cell.textLabel.text = @"Help";
        cell.imageView.image = [UIImage imageNamed:@"Help"];
    }
    else if (indexPath.row == 1) {
        cell.textLabel.text = @"Copyright";
        cell.imageView.image = [UIImage imageNamed:@"Copyright"];
    }
    else {
        cell.textLabel.text = @"Feedback";
        [cell.imageView setTintColor:[UIColor colorWithRed:0
                                                     green:0.47843137
                                                      blue:1
                                                     alpha:1]];
        UIImage *image = [UIImage imageNamed:@"Feedback"];
        image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        cell.imageView.image = image;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UINavigationController *nc = self.tabBarController.navigationController;
    
    if (indexPath.row == 0) {
        EEHelpViewController *helpVC = [[EEHelpViewController alloc] init];
        [nc pushViewController:helpVC animated:YES];
    }
    else if (indexPath.row == 1) {
        EECopyrightViewController *copyrightVC = [[EECopyrightViewController alloc] init];
        [nc pushViewController:copyrightVC animated:YES];
    }
    else {
        if ([MFMailComposeViewController canSendMail]) {
            //Email Subject
            NSString *emailSubject = @"SplitIT Feedback";
            
            //To Addresses
            NSArray *toRecipient = @[@"elmosoftenterprises@gmail.com"];
            
            //Email Body
            NSString *messageBody = @"";
            
            //Create the email view controller
            MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
            mc.mailComposeDelegate = self;
            [mc setSubject:emailSubject];
            [mc setToRecipients:toRecipient];
            [mc setMessageBody:messageBody isHTML:NO];
            
            //Present the mail view controller on screen
            [self presentViewController:mc animated:YES completion:nil];
        }
        else {
            if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
                UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Email Not Setup On Device"
                                                                     message:@"Feedback is sent through email. Please associate a valid email address with your device"
                                                                    delegate:nil
                                                           cancelButtonTitle:@"OK"
                                                           otherButtonTitles: nil];
                [errorAlert show];
            }
            else {
                UIAlertController *alertController = [UIAlertController
                                                      alertControllerWithTitle:@"Email Not Setup On Device" message:@"Feedback is sent through email. Please associate a valid email address with your device" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *cancelAction = [UIAlertAction
                                               actionWithTitle:@"OK"
                                               style:UIAlertActionStyleCancel
                                               handler:nil];
                [alertController addAction:cancelAction];
                [self presentViewController:alertController animated:YES completion:nil];
            }
            
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result) {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    //Clsoe the Mail Interface
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
