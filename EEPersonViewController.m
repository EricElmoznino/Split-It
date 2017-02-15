//
//  EEPersonViewController.m
//  SplitIt
//
//  Created by ERIC ELMOZNINO on 2015-07-11.
//  Copyright (c) 2015 Eric Elmoznino. All rights reserved.
//

#import "EEPersonViewController.h"
#import "EEPurchaseViewController.h"
#import "EEImageViewController.h"
#import "EEPurchase.h"
#import "EEContributionsCell.h"
#import "EEImageStore.h"

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

@interface EEPersonViewController ()
<UINavigationControllerDelegate, UIImagePickerControllerDelegate>

//Matching indices
@property (nonatomic, strong) NSMutableArray *purchasesContributed;
@property (nonatomic, strong) NSMutableArray *amountsContributed;

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImageView;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic) BOOL isNew;

@end

@implementation EEPersonViewController

- (instancetype)initWithNew:(BOOL)isNew
{
    self = [super init];
    
    if (self) {
        if (isNew) {
            self.isNew = YES;
            UIBarButtonItem *saveButton = [[UIBarButtonItem alloc]
                                           initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                           target:self
                                           action:@selector(save:)];
            self.navigationItem.rightBarButtonItem = saveButton;
            UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]
                                             initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                             target:self
                                             action:@selector(cancel:)];
            self.navigationItem.leftBarButtonItem = cancelButton;
        }
        
        self.purchasesContributed = [[NSMutableArray alloc] init];
        self.amountsContributed = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UINib *nib = [UINib nibWithNibName:@"EEContributionsCell" bundle:nil];
    [self.tableView registerNib:nib
         forCellReuseIdentifier:@"EEContributionsCell"];
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 50, 0, 0);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
    
    self.nameTextField.text = self.person.name;
    self.emailTextField.text = self.person.emailAddress;
    
    if (self.isNew) {
        //Hide table because a new person will have no contributions yet
        self.tableView.hidden = YES;
    }
    
    //Show thumbnailImage
    UIImage *image;
    if (self.person.thumbnailView) {
        image = self.person.thumbnailView;
        image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }
    else {
        image = [[UIImage imageNamed:@"PersonPlaceholder"]
                 imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }
    self.thumbnailImageView.image = image;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.view endEditing:YES];
    
    self.person.name = self.nameTextField.text;
    self.person.emailAddress = self.emailTextField.text;
}

- (void)setGroup:(EEGroup *)group
{
    _group = group;
    
    //Fill the contributions arrays that will be displayed in the table
    NSArray *purchases = [self.group allPurchases];
    for (int i=0; i<[purchases count]; i++) {
        EEPurchase *purchase = purchases[i];
        NSDictionary *contributions = purchase.contributions;
        NSNumber *amountContributed = contributions[self.person.personKey];
        //Person did contribute to the purchase
        if (amountContributed != nil) {
            [self.purchasesContributed addObject:purchase];
            [self.amountsContributed addObject:amountContributed];
        }
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField == self.nameTextField) {
        if ([textField.text isEqualToString:@"New Person"]) {
            textField.text = @"";
        }
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
    if (textField == self.nameTextField) {
        if ([textField.text isEqualToString:@""]) {
            textField.text = @"New Person";
        }
    }
    
    return YES;
}

- (IBAction)backgroundTapped:(id)sender
{
    [self.view endEditing:YES];
}

- (void)save:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)cancel:(id)sender
{
    [self.group removePerson:self.person];
    
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)setPerson:(EEPerson *)person
{
    _person = person;
    self.navigationItem.title = _person.name;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.purchasesContributed count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EEContributionsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EEContributionsCell"
                                                                forIndexPath:indexPath];
    
    EEPurchase *purchase = self.purchasesContributed[indexPath.row];
    
    cell.nameLabel.text = purchase.name;
    
    static NSDateFormatter *dateFormatter = nil;
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateStyle = NSDateFormatterMediumStyle;
        dateFormatter.timeStyle = NSDateFormatterNoStyle;
    }
    cell.dateLabel.text = [dateFormatter stringFromDate:purchase.date];
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterCurrencyStyle;
    NSNumber *cost = [NSNumber numberWithDouble:purchase.cost];
    cell.costLabel.text = [formatter stringFromNumber:cost];
    cell.costLabel.textColor = [UIColor colorWithRed:0
                                               green:0.58
                                                blue:0
                                               alpha:1];
    
    NSNumber *paid = self.amountsContributed[indexPath.row];
    cell.paidLabel.text = [formatter stringFromNumber:paid];
    cell.paidLabel.textColor = [UIColor colorWithRed:0
                                               green:0.58
                                                blue:0
                                               alpha:1];
    
    if (purchase.thumbnailView) {
        cell.thumbnailView.image = purchase.thumbnailView;
    }
    else {
        cell.thumbnailView.image = [UIImage imageNamed:@"PurchasePlaceholder"];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    EEPurchase *purchase = self.purchasesContributed[indexPath.row];
    EEPurchaseViewController *purchaseVC = [[EEPurchaseViewController alloc] initWithNew:NO];
    purchaseVC.group = self.group;
    purchaseVC.purchase = purchase;
    
    UINavigationController *nc = self.navigationController;
    [nc pushViewController:purchaseVC animated:YES];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *label = [[UILabel alloc] init];
    label.text = @"Contributions";
    label.font = [UIFont systemFontOfSize:17];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor colorWithRed:0
                                      green:0.47843137
                                       blue:1
                                      alpha:1];
    label.frame = CGRectMake(0, 8, tableView.frame.size.width, 21);
    
    UIView *view = [[UIView alloc] initWithFrame:
                    CGRectMake(0, 0, tableView.frame.size.width, 37)];
    [view addSubview:label];
    view.backgroundColor = [UIColor colorWithRed:0.97
                                           green:0.97
                                            blue:0.97
                                           alpha:1];
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 37;
}

- (IBAction)showImage:(id)sender
{
    NSString *personKey = self.person.personKey;
    
    UIImage *img = [[EEImageStore sharedStore] imageForKey:personKey];
    //Current image is just a placeholder
    if (!img) {
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
                popover.sourceView = self.thumbnailImageView;
                popover.sourceRect = self.thumbnailImageView.bounds;
                popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
            }
            
            //Present the alertController
            [self presentViewController:alertController animated:YES completion:nil];
        }
    }
    else {
        EEImageViewController *ivc = [[EEImageViewController alloc] init];
        ivc.person = self.person;
        
        [self.navigationController pushViewController:ivc animated:YES];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = info[UIImagePickerControllerEditedImage];
    
    EEPerson *person = self.person;
    
    [person setThumbnailForImage:image];
    [[EEImageStore sharedStore] setImage:image forKey:person.personKey];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
