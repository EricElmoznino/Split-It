//
//  EESplitItViewController.m
//  SplitIt
//
//  Created by ERIC ELMOZNINO on 2015-07-09.
//  Copyright (c) 2015 Eric Elmoznino. All rights reserved.
//

#import "EESplitItViewController.h"
#import "EESplitItTableCell.h"

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)


@interface EESplitItViewController ()
<MFMailComposeViewControllerDelegate>

//Temporary people array that will be a copy of group.people
//and will be shortened as debts are settled
@property (nonatomic, strong) NSMutableArray *people;

//To sort the people based on balance
@property (nonatomic, strong) NSArray *sortDescriptors;

//Array with all transactions
@property (nonatomic, strong) NSMutableArray *payers;
@property (nonatomic, strong) NSMutableArray *amounts;
@property (nonatomic, strong) NSMutableArray *receivers;

@end

@implementation EESplitItViewController

- (instancetype)init {
    self = [super initWithStyle:UITableViewStylePlain];
    
    if (self) {
        self.tabBarItem.title = @"Split It";
        self.tabBarItem.image = [UIImage imageNamed:@"SplitIt"];
        
        NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"balance" ascending:NO];
        self.sortDescriptors = @[sd];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"EESplitItTableCell"];
    
    UINib *nib = [UINib nibWithNibName:@"EESplitItTableCell" bundle:nil];
    [self.tableView registerNib:nib
                    forCellReuseIdentifier:@"EESplitItTableCell"];
    self.tableView.allowsSelection = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //Recompute balances
    [self.group updateBalances];
    
    //Make a copy of the people with their balances, names, and email
    //so that the splitting algorithm does not affect the balances
    //of the real people objects
    self.people = [[NSMutableArray alloc] init];
    for (EEPerson *person in self.group.allPeople) {
        EEPerson *personCopy = [[EEPerson alloc] init];
        personCopy.name = person.name;
        personCopy.emailAddress = person.emailAddress;
        personCopy.balance = person.balance;
        
        [self.people addObject:personCopy];
    }
    
    self.payers = [[NSMutableArray alloc] init];
    self.amounts = [[NSMutableArray alloc] init];
    self.receivers = [[NSMutableArray alloc] init];
    [self createTransactions];
    
    [self.tableView reloadData];
    
    //Erase the add button created by the other tabbed view controllers
    self.tabBarController.navigationItem.rightBarButtonItem = nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.payers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EESplitItTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EESplitItTableCell"
                                                               forIndexPath:indexPath];
    
    cell.payerLabel.text = self.payers[indexPath.row];
    cell.amountLabel.text = self.amounts[indexPath.row];
    cell.receiverLabel.text = self.receivers[indexPath.row];
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *label = [[UILabel alloc] init];
    label.text = @"Debts";
    label.font = [UIFont systemFontOfSize:20];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor colorWithRed:0
                                      green:0.47843137
                                       blue:1
                                      alpha:1];
    label.frame = CGRectMake(0, 8, tableView.frame.size.width, 24);
    
    UIView *view = [[UIView alloc] initWithFrame:
                    CGRectMake(0, 0, tableView.frame.size.width, 40)];
    [view addSubview:label];
    view.backgroundColor = [UIColor colorWithRed:0.97
                                           green:0.97
                                            blue:0.97
                                           alpha:1];
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:
                          CGRectMake(0, 0, tableView.frame.size.width, 44)];
    
    UIBarButtonItem *composeEmail = [[UIBarButtonItem alloc]
                                     initWithImage:[UIImage imageNamed:@"Email"]
                                     style:UIBarButtonItemStylePlain
                                     target:self
                                     action:@selector(emailResults)];
    UIBarButtonItem *leftSpace = [[UIBarButtonItem alloc]
                                  initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                  target:nil
                                  action:nil];
    UIBarButtonItem *rightSpace = [[UIBarButtonItem alloc]
                                   initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                   target:nil
                                   action:nil];
    
    toolbar.items = @[leftSpace, composeEmail, rightSpace];
    
    return toolbar;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 44;
}

- (void)createTransactions
{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterCurrencyStyle;
    
    [self.people sortUsingDescriptors:self.sortDescriptors];
    
    //Eliminate all the people with a zero balance
    for (int i=(int)[self.people count]-1; i>=0; i--) {
        EEPerson *person = self.people[i];
        if (fabs(person.balance) < 0.01) {
            [self.people removeObjectAtIndex:i];
        }
    }
    
    while ([self.people count]) {
        [self.people sortUsingDescriptors:self.sortDescriptors];
        
        //Find people who cancel eachother out
        BOOL stopMainLoop = NO;
        for (int i=0; i<((int)self.people.count - 1) && !stopMainLoop; i++) {
            EEPerson *positivePerson = self.people[i];
            if (positivePerson.balance < 0) {
                stopMainLoop = YES;
            }
            
            BOOL stopSubLoop = NO;
            for (int j=(int)self.people.count - 1;
                 j>=i+1 && !stopMainLoop && !stopSubLoop;
                 j--) {
                EEPerson *negativePerson = self.people[j];
                if (negativePerson.balance > 0) {
                    stopSubLoop = YES;
                }
                else if (positivePerson.balance + negativePerson.balance == 0) {
                    //Add the transaction
                    NSString *amountToPay = [formatter stringFromNumber:
                                             [NSNumber numberWithDouble:positivePerson.balance]];
                    [self.payers addObject:negativePerson.name];
                    [self.amounts addObject:amountToPay];
                    [self.receivers addObject:positivePerson.name];
                    
                    //Remove the two people from the array
                    [self.people removeObjectAtIndex:i];
                    [self.people removeObjectAtIndex:j-1];  //-1 due to previous line
                    
                    //New unchecked object has moved into index i because of deletion
                    i--;
                    
                    //Stop the search for this number
                    stopSubLoop = YES;
                }
            }
        }
        
        //No cancellations left at the moment. Match the people who have the
        //largest balance seperations and eliminate one of them
        if ([self.people count]) {
            [self.people sortUsingDescriptors:self.sortDescriptors];
            
            EEPerson *positivePerson = [self.people firstObject];
            EEPerson *negativePerson = [self.people lastObject];
            
            //If one person's balance is less that 1 cent,
            //both people's balances are less than one cent
            //and they should be removed from the list of people.
            //This is because the algorithm takes people with the largest
            //differential. If one person has a remaining balance of
            //essentially 0, then everybody has a balance of essentially 0.
            if (fabs(positivePerson.balance) < 0.01) {
                [self.people removeObject:positivePerson];
                [self.people removeObject:negativePerson];
            }
            //Positive person has higher credit than negative person has debt
            else if (positivePerson.balance + negativePerson.balance > 0) {
                double amountToPay = -negativePerson.balance;
                NSString *amountToPayString = [formatter stringFromNumber:
                                               [NSNumber numberWithDouble:amountToPay]];
                [self.payers addObject:negativePerson.name];
                [self.amounts addObject:amountToPayString];
                [self.receivers addObject:positivePerson.name];
                
                //Has nothing left to pay
                [self.people removeObject:negativePerson];
                
                //Adjust for how much negativePerson payed him
                positivePerson.balance -= amountToPay;
            }
            //Negative person has higher debt than positive person has credit
            else {
                double amountToPay = positivePerson.balance;
                NSString *amountToPayString = [formatter stringFromNumber:
                                               [NSNumber numberWithDouble:amountToPay]];
                [self.payers addObject:negativePerson.name];
                [self.amounts addObject:amountToPayString];
                [self.receivers addObject:positivePerson.name];
                
                //Has been fully payed
                [self.people removeObject:positivePerson];
                
                //Adjust for how much he payed positive person
                negativePerson.balance += amountToPay;
            }
        }
        
        //Rouding error from split percentages
        //may leave one person with extremelly small balance
        //at the end
        if ((int)[self.people count] == 1) {
            [self.people removeAllObjects];
        }
    }
}

- (void)emailResults
{
    if ([MFMailComposeViewController canSendMail]) {
        //Email Subject
        NSString *emailSubject = [NSString stringWithFormat:
                                  @"Split It: Current Debts For %@", self.group.name];
        
        //To Addresses
        NSMutableArray *toRecipients = [[NSMutableArray alloc] init];
        for (EEPerson *person in [self.group allPeople]) {
            NSString *emailAddress = person.emailAddress;
            
            //Email address was entered for person
            if (![emailAddress isEqualToString:@""]) {
                [toRecipients addObject:emailAddress];
            }
        }
        
        //Email Body
        NSString *messageBody = @"Your group debts left to settle:\n\n";
        for (int i=0; i < [self.payers count]; i++) {
            NSString *transactionString = [NSString stringWithFormat:@"%@ pays %@ to %@\n",
                                           self.payers[i], self.amounts[i], self.receivers[i]];
            messageBody = [messageBody stringByAppendingString:transactionString];
        }
        
        //Create the email view controller
        MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
        mc.mailComposeDelegate = self;
        [mc setSubject:emailSubject];
        [mc setToRecipients:toRecipients];
        [mc setMessageBody:messageBody isHTML:NO];
        
        //Present the mail view controller on screen
        [self presentViewController:mc animated:YES completion:nil];
    }
    else {
        if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
            UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Email Not Setup On Device"
                                                                 message:@"Results are sent through email. Please associate a valid email address with your device"
                                                                delegate:nil
                                                       cancelButtonTitle:@"OK"
                                                       otherButtonTitles: nil];
            [errorAlert show];
        }
        else {
            UIAlertController *alertController = [UIAlertController
                                                  alertControllerWithTitle:@"Email Not Setup On Device" message:@"Results are sent through email. Please associate a valid email address with your device" preferredStyle:UIAlertControllerStyleAlert];
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
