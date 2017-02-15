//
//  EEGroupsViewController.m
//  SplitIt
//
//  Created by GAD ELMOZNINO on 2015-07-22.
//  Copyright (c) 2015 Eric Elmoznino. All rights reserved.
//

#import "EEGroupsViewController.h"
#import "EEAddGroupViewController.h"
#import "EEPeopleViewController.h"
#import "EEPurchasesViewController.h"
#import "EESplitItViewController.h"
#import "EEMoreViewController.h"
#import "EECopyrightViewController.h"
#import "EEHelpViewController.h"
#import "EEGroupStore.h"
#import "EEGroup.h"
#import "EEGroupTableCell.h"

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

@interface EEGroupsViewController ()
<MFMailComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation EEGroupsViewController

- (instancetype)init {
    self = [super init];
    
    if (self) {
        self.navigationItem.title = @"Groups";
        
        UIBarButtonItem *addButton = [[UIBarButtonItem alloc]
                                      initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                      target:self
                                      action:@selector(addNewGroup:)];
        self.navigationItem.rightBarButtonItem = addButton;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UINib *nib = [UINib nibWithNibName:@"EEGroupTableCell" bundle:nil];
    [self.tableView registerNib:nib
         forCellReuseIdentifier:@"EEGroupTableCell"];
    
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    
    [self.tableView setEditing:editing animated:animated];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[EEGroupStore sharedStore] allGroups] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EEGroupTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EEGroupTableCell"
                                                             forIndexPath:indexPath];
    
    NSArray *groups = [[EEGroupStore sharedStore] allGroups];
    EEGroup *group = groups[indexPath.row];
    
    cell.nameLabel.text = group.name;
    
    static NSDateFormatter *dateFormatter = nil;
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateStyle = NSDateFormatterMediumStyle;
        dateFormatter.timeStyle = NSDateFormatterNoStyle;
    }
    cell.dateLabel.text = [dateFormatter stringFromDate:group.dateCreated];
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterNoStyle;
    NSNumber *numberOfPeople = [NSNumber numberWithInteger:[group.allPeople count]];
    cell.numberOfPeopleLabel.text = [formatter stringFromNumber:numberOfPeople];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSArray *groups = [[EEGroupStore sharedStore] allGroups];
        EEGroup *group = groups[indexPath.row];
        [[EEGroupStore sharedStore] removeGroup:group];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    [[EEGroupStore sharedStore] moveItemAtIndex:fromIndexPath.row toIndex:toIndexPath.row];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *groups = [[EEGroupStore sharedStore] allGroups];
    EEGroup *group = groups[indexPath.row];
    
    EEPeopleViewController *peopleVC = [[EEPeopleViewController alloc] init];
    EEPurchasesViewController *purchasesVC = [[EEPurchasesViewController alloc] init];
    EESplitItViewController *splitItVC = [[EESplitItViewController alloc] init];
    EEMoreViewController *moreVC = [[EEMoreViewController alloc] init];
    peopleVC.group = group;
    purchasesVC.group = group;
    splitItVC.group = group;
    
    //Configure the TabBarController
    UITabBarController *tbc = [[UITabBarController alloc] init];
    [tbc setViewControllers:@[peopleVC,purchasesVC,splitItVC,moreVC] animated:YES];
    tbc.navigationItem.title = [NSString stringWithFormat:@"%@", group.name];
    
    //Prevent content from being displayed undernearth navigation and tab bars
    tbc.tabBar.translucent = NO;
    self.navigationController.navigationBar.translucent = NO;
    
    tbc.restorationIdentifier = NSStringFromClass([tbc class]);
    
    [self.navigationController pushViewController:tbc animated:YES];
}


- (void)addNewGroup:(id)sender
{
    EEGroup *group = [[EEGroup alloc] init];
    [[EEGroupStore sharedStore] addGroup:group];
    
    EEAddGroupViewController *avc = [[EEAddGroupViewController alloc] init];
    avc.group = group;
    
    avc.pushGroupController = ^{
        EEPeopleViewController *peopleVC = [[EEPeopleViewController alloc] init];
        EEPurchasesViewController *purchasesVC = [[EEPurchasesViewController alloc] init];
        EESplitItViewController *splitItVC = [[EESplitItViewController alloc] init];
        EEMoreViewController *moreVC = [[EEMoreViewController alloc] init];
        peopleVC.group = group;
        purchasesVC.group = group;
        splitItVC.group = group;
        
        //Configure the TabBarController
        UITabBarController *tbc = [[UITabBarController alloc] init];
        [tbc setViewControllers:@[peopleVC,purchasesVC,splitItVC,moreVC] animated:YES];
        tbc.navigationItem.title = [NSString stringWithFormat:@"%@", group.name];
        
        //Prevent content from being displayed undernearth navigation and tab bars
        tbc.tabBar.translucent = NO;
        self.navigationController.navigationBar.translucent = NO;
        
        [self.navigationController pushViewController:tbc animated:YES];
    };
    
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:avc];
    
    [self presentViewController:nc animated:YES completion:nil];
}

- (IBAction)pushCopyright:(id)sender
{
    EECopyrightViewController *copyrightVC = [[EECopyrightViewController alloc] init];
    [self.navigationController pushViewController:copyrightVC animated:YES];
}

- (IBAction)pushHelp:(id)sender
{
    EEHelpViewController *helpVC = [[EEHelpViewController alloc] init];
    [self.navigationController pushViewController:helpVC animated:YES];
}

- (IBAction)sendFeedback:(id)sender
{
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