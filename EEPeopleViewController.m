//
//  EEPeopleViewController.m
//  SplitIt
//
//  Created by ERIC ELMOZNINO on 2015-07-09.
//  Copyright (c) 2015 Eric Elmoznino. All rights reserved.
//

#import <AddressBookUI/AddressBookUI.h>
#import <AddressBook/AddressBook.h>
#import "EEPeopleViewController.h"
#import "EEPersonViewController.h"
#import "EEImageViewController.h"
#import "EEPerson.h"
#import "EEPersonTableCell.h"
#import "EEImageStore.h"

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

@interface EEPeopleViewController ()
<UINavigationControllerDelegate,
UIImagePickerControllerDelegate,
ABPeoplePickerNavigationControllerDelegate,
UIActionSheetDelegate>

//Reference to which thumbnail was selected in order to change that
//person's thumbnail image
@property (nonatomic) NSInteger indexOfSelectedThumbnail;

@end

@implementation EEPeopleViewController

- (instancetype)init {
    self = [super initWithStyle:UITableViewStylePlain];
    
    if (self) {
        self.tabBarItem.title = @"People";
        self.tabBarItem.image = [UIImage imageNamed:@"People"];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UINib *nib = [UINib nibWithNibName:@"EEPersonTableCell" bundle:nil];
    [self.tableView registerNib:nib
         forCellReuseIdentifier:@"EEPersonTableCell"];
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 50, 0, 0);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc]
                                  initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                  target:self
                                  action:@selector(addNewPerson:)];
    self.tabBarController.navigationItem.rightBarButtonItem = addButton;
    
    //Recompute balances
    [self.group updateBalances];
    
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.group.allPeople count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EEPersonTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EEPersonTableCell"
                                                              forIndexPath:indexPath];
    
    NSArray *people = self.group.allPeople;
    EEPerson *person = people[indexPath.row];
    
    cell.nameLabel.text = person.name;
    
    if (person.shouldPayNext) {
        cell.shouldPayNextLabel.hidden = NO;
    }
    else {
        cell.shouldPayNextLabel.hidden = YES;
    }
    
    if (person.thumbnailView) {
        cell.thumbnailView.image = person.thumbnailView;
    }
    else {
        cell.thumbnailView.image = [UIImage imageNamed:@"PersonPlaceholder"];
    }
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterCurrencyStyle;
    NSNumber *balance = [NSNumber numberWithDouble:person.balance];
    cell.balanceLabel.text = [formatter stringFromNumber:balance];
    if (person.balance < 0) {
        cell.balanceLabel.textColor = [UIColor redColor];
        cell.separatorLabel.backgroundColor = [UIColor redColor];
    }
    else {
        UIColor *color = [UIColor colorWithRed:0
                                         green:0.58
                                          blue:0
                                         alpha:1];
        cell.balanceLabel.textColor = color;
        cell.separatorLabel.backgroundColor = color;
    }
    
    __weak EEPersonTableCell *weakCell = cell;
    cell.showImageBlock = ^{
        EEPersonTableCell *strongCell = weakCell;
        
        NSString *personKey = person.personKey;
        
        UIImage *img = [[EEImageStore sharedStore] imageForKey:personKey];
        //Current image is just a placeholder
        if (!img) {
            self.indexOfSelectedThumbnail = indexPath.row;
            
            UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
            imagePicker.allowsEditing = YES;
            imagePicker.delegate = self;
            
            //If device can't take photos
            if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                [self presentViewController:imagePicker animated:YES completion:nil];
            }
            
            //If the user is running a version less than iOS 8.0
            else if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
                imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
                [self presentViewController:imagePicker animated:YES completion:nil];
            }
            
            //Give user the option of taking a new picture or taking from library
            else {
                UIAlertController *alertController = [UIAlertController
                                                      alertControllerWithTitle:nil
                                                      message:nil
                                                      preferredStyle:UIAlertControllerStyleActionSheet];
                
                UIAlertAction *cancelAction = [UIAlertAction
                                               actionWithTitle:@"Cancel"
                                               style:UIAlertActionStyleCancel
                                               handler:nil];
                UIAlertAction *takePhotoAction = [UIAlertAction
                                                  actionWithTitle:@"Take Photo"
                                                  style:UIAlertActionStyleDefault
                                                  handler:^(UIAlertAction *action) {
                                                      imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
                                                      [self presentViewController:imagePicker animated:YES completion:nil];
                                                  }];
                UIAlertAction *photoLibraryAction = [UIAlertAction
                                                     actionWithTitle:@"From Library"
                                                     style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *action) {
                                                         imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                                                         [self presentViewController:imagePicker animated:YES completion:nil];
                                                     }];
                
                [alertController addAction:cancelAction];
                [alertController addAction:takePhotoAction];
                [alertController addAction:photoLibraryAction];
                
                //In case of iPad
                UIPopoverPresentationController *popover = alertController.popoverPresentationController;
                if (popover)
                {
                    popover.sourceView = strongCell.thumbnailView;
                    popover.sourceRect = strongCell.thumbnailView.bounds;
                    popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
                }
                
                //Present the alertController
                [self presentViewController:alertController animated:YES completion:nil];
            }
        }
        //Show the image in the EEImageViewController
        else {
            EEImageViewController *ivc = [[EEImageViewController alloc] init];
            ivc.person = person;
            
            [self.navigationController pushViewController:ivc animated:YES];
        }
    };
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *people = self.group.allPeople;
    EEPerson *person = people[indexPath.row];
    NSArray *purchases = self.group.allPurchases;
    
    //If person is involved in a purchase, cannot delete
    for (EEPurchase *purchase in purchases) {
        NSDictionary *contributions = purchase.contributions;
        if (contributions[person.personKey]) {
            return NO;
        }
    }
    
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSArray *people = self.group.allPeople;
        EEPerson *person = people[indexPath.row];
        [self.group removePerson:person];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    EEPerson *person = self.group.allPeople[indexPath.row];
    EEPersonViewController *personVC = [[EEPersonViewController alloc] initWithNew:NO];
    personVC.person = person;
    personVC.group = self.group;
    
    UINavigationController *nc = self.tabBarController.navigationController;
    [nc pushViewController:personVC animated:YES];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *label = [[UILabel alloc] init];
    label.text = @"People";
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

- (void)addNewPerson:(id)sender
{
    //Give the choice to add manually or from existing contact
    
    //If the version number is less than iOS 8.0, use UIActionSheet
    if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                      initWithTitle:nil
                                      delegate:self
                                      cancelButtonTitle:@"Cancel"
                                      destructiveButtonTitle:nil
                                      otherButtonTitles:@"From contacts", @"Manually", nil];
        [actionSheet showFromTabBar:self.tabBarController.tabBar];
    }
    
    //Else, use UIAlertController
    else {
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:nil
                                              message:nil
                                              preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *cancelAction = [UIAlertAction
                                       actionWithTitle:@"Cancel"
                                       style:UIAlertActionStyleCancel
                                       handler:nil];
        UIAlertAction *fromContacts = [UIAlertAction
                                       actionWithTitle:@"From Contacts"
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction *action) {
                                           //Create address book and request access once
                                           ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, nil);
                                           __block BOOL accessGranted = NO;
                                           dispatch_semaphore_t sema = dispatch_semaphore_create(0);
                                           ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
                                               accessGranted = granted;
                                               dispatch_semaphore_signal(sema);
                                           });
                                           dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
                                           
                                           //Create the people picker
                                           if (accessGranted) {
                                               ABPeoplePickerNavigationController *contactPicker = [[ABPeoplePickerNavigationController alloc] init];
                                               contactPicker.addressBook = addressBook;
                                               contactPicker.peoplePickerDelegate = self;
                                               contactPicker.displayedProperties = @[@(kABPersonEmailProperty)];
                                               
                                               //iOS 8 and higher
                                               if ([contactPicker respondsToSelector:@selector(setPredicateForSelectionOfPerson:)])
                                               {
                                                   // The people picker will select a person that has none or exactly one email address and call peoplePickerNavigationController:didSelectPerson:,
                                                   // otherwise the people picker will present an ABPersonViewController for the user to pick one of the email addresses.
                                                   contactPicker.predicateForSelectionOfPerson = [NSPredicate predicateWithFormat:@"emailAddresses.@count <= 1"];
                                               }
                                               
                                               [self presentViewController:contactPicker animated:YES completion:nil];
                                           }
                                       }];
        UIAlertAction *manually = [UIAlertAction
                                   actionWithTitle:@"Manually"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action) {
                                       EEPerson *person = [[EEPerson alloc] init];
                                       [self.group addPerson:person];
                                       
                                       EEPersonViewController *personVC = [[EEPersonViewController alloc] initWithNew:YES];
                                       personVC.person = person;
                                       personVC.group = self.group;
                                       
                                       UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:personVC];
                                       nc.navigationBar.translucent = NO;
                                       
                                       [self presentViewController:nc animated:YES completion:nil];
                                   }];
        
        [alertController addAction:cancelAction];
        [alertController addAction:fromContacts];
        [alertController addAction:manually];
        
        //In case of iPad
        UIPopoverPresentationController *popover = alertController.popoverPresentationController;
        if (popover)
        {
            popover.barButtonItem = sender;
            popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
        }
        
        //Present the alertController
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = info[UIImagePickerControllerEditedImage];
    
    EEPerson *person = self.group.allPeople[self.indexOfSelectedThumbnail];
    
    [person setThumbnailForImage:image];
    [[EEImageStore sharedStore] setImage:image forKey:person.personKey];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

//iOS < 8
- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

//iOS 8
- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker didSelectPerson:(ABRecordRef)person
{
    [self dismissViewControllerAnimated:NO completion:nil];
    [self didSelectPerson:person identifier:kABMultiValueInvalidIdentifier];
}

//iOS 8
- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker didSelectPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    [self dismissViewControllerAnimated:NO completion:nil];
    [self didSelectPerson:person identifier:identifier];
}

//iOS < 8
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person
{
    BOOL shouldContinue = NO;
    
    ABMultiValueRef emails = ABRecordCopyValue(person, kABPersonEmailProperty);
    if (ABMultiValueGetCount(emails) <= 1) {
        [self dismissViewControllerAnimated:NO completion:nil];
        [self didSelectPerson:person identifier:kABMultiValueInvalidIdentifier];
    }
    else {
        shouldContinue = YES;
    }
    
    if (emails) {
        CFRelease(emails);
    }
    
    return shouldContinue;
}

//iOS < 8
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    [self dismissViewControllerAnimated:NO completion:nil];
    [self didSelectPerson:person identifier:identifier];
    
    return NO;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        EEPerson *person = [[EEPerson alloc] init];
        [self.group addPerson:person];
        
        EEPersonViewController *personVC = [[EEPersonViewController alloc] initWithNew:YES];
        personVC.person = person;
        personVC.group = self.group;
        
        UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:personVC];
        nc.navigationBar.translucent = NO;
        
        [self presentViewController:nc animated:YES completion:nil];
    }
    else if (buttonIndex == 0) {
        ABPeoplePickerNavigationController *contactPicker = [[ABPeoplePickerNavigationController alloc] init];
        contactPicker.peoplePickerDelegate = self;
        contactPicker.displayedProperties = @[@(kABPersonEmailProperty)];
        
        //iOS 8 and higher
        if ([contactPicker respondsToSelector:@selector(setPredicateForSelectionOfPerson:)])
        {
            // The people picker will select a person that has none or exactly one email address and call peoplePickerNavigationController:didSelectPerson:,
            // otherwise the people picker will present an ABPersonViewController for the user to pick one of the email addresses.
            contactPicker.predicateForSelectionOfPerson = [NSPredicate predicateWithFormat:@"emailAddresses.@count <= 1"];
        }
        
        [self presentViewController:contactPicker animated:YES completion:nil];
    }
}

- (void)didSelectPerson:(ABRecordRef)person identifier:(ABMultiValueIdentifier)identifier
{
    NSString* name = (__bridge_transfer NSString*)ABRecordCopyValue(person,
                                                                    kABPersonFirstNameProperty);
    
    NSString *emailAddress = nil;
    ABMultiValueRef emails = ABRecordCopyValue(person, kABPersonEmailProperty);
    
    NSData *imageData = (__bridge NSData *)(ABPersonCopyImageDataWithFormat(person, kABPersonImageFormatOriginalSize));
    
    if (emails)
    {
        if (ABMultiValueGetCount(emails) > 0)
        {
            CFIndex index = 0;
            if (identifier != kABMultiValueInvalidIdentifier)
            {
                index = ABMultiValueGetIndexForIdentifier(emails, identifier);
            }
            emailAddress = CFBridgingRelease(ABMultiValueCopyValueAtIndex(emails, index));
        }
        CFRelease(emails);
    }
    
    EEPerson *newPerson = [[EEPerson alloc] init];
    [self.group addPerson:newPerson];
    
    EEPersonViewController *personVC = [[EEPersonViewController alloc] initWithNew:YES];
    personVC.person = newPerson;
    personVC.group = self.group;
    
    if (name) {
        newPerson.name = name;
    }
    if (emailAddress) {
        newPerson.emailAddress = emailAddress;
    }
    if (imageData) {
        UIImage *image = [UIImage imageWithData:imageData];
        [[EEImageStore sharedStore] setImage:image forKey:newPerson.personKey];
        [newPerson setThumbnailForImage:image];
    }
    
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:personVC];
    nc.navigationBar.translucent = NO;
    
    [self presentViewController:nc animated:YES completion:nil];
}

@end
