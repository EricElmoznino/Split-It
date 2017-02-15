//
//  EEPurchaseViewController.m
//  SplitIt
//
//  Created by ERIC ELMOZNINO on 2015-07-11.
//  Copyright (c) 2015 Eric Elmoznino. All rights reserved.
//

#import "EEPurchaseViewController.h"
#import "EEImageViewController.h"
#import "EEPaidTableCell.h"
#import "UIViewController+BackButtonHandler.h"
#import "EEImageStore.h"

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

@interface EEPurchaseViewController ()
<UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UILabel *costLabel;
@property (weak, nonatomic) IBOutlet UITextView *detailTextField;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImageView;
@property (weak, nonatomic) IBOutlet UILabel *errorWarning;

@property (weak, nonatomic) IBOutlet UISegmentedControl *splitTypeSelector;

@property (weak, nonatomic) IBOutlet UITableView *contributedTableView;

@property (nonatomic) BOOL canGoBack;
@property (nonatomic) BOOL evenSplitting;

@end

@implementation EEPurchaseViewController

- (instancetype)initWithNew:(BOOL)isNew
{
    self = [super init];
    
    if (self) {
        if (isNew) {
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
        
        self.canGoBack = YES;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UINib *nib = [UINib nibWithNibName:@"EEPaidTableCell" bundle:nil];
    [self.contributedTableView registerNib:nib
                    forCellReuseIdentifier:@"EEPaidTableCell"];
    self.contributedTableView.allowsSelection = NO;
    self.contributedTableView.separatorInset = UIEdgeInsetsMake(0, 67, 0, 0);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.contributedTableView reloadData];
    
    //Text fields and labels
    self.nameTextField.text = self.purchase.name;
    self.detailTextField.text = self.purchase.details;
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterCurrencyStyle;
    formatter.maximumFractionDigits = 2;
    NSNumber *cost = [NSNumber numberWithDouble:self.purchase.cost];
    self.costLabel.text = [NSString stringWithFormat:@"%@",
                               [formatter stringFromNumber:cost]];
    
    static NSDateFormatter *dateFormatter = nil;
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateStyle = NSDateFormatterMediumStyle;
        dateFormatter.timeStyle = NSDateFormatterNoStyle;
    }
    self.dateLabel.text = [dateFormatter stringFromDate:self.purchase.date];
    
    if (self.evenSplitting) {
        self.splitTypeSelector.selectedSegmentIndex = 1;
    }
    else {
        self.splitTypeSelector.selectedSegmentIndex = 0;
    }
    
    //Show thumbnailImage
    UIImage *image;
    if (self.purchase.thumbnailView) {
        image = self.purchase.thumbnailView;
        image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }
    else {
        image = [[UIImage imageNamed:@"PurchasePlaceholder"]
                 imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }
    self.thumbnailImageView.image = image;
    
    //Hide the error label if canGoBack
    if (self.canGoBack) {
        self.errorWarning.hidden = YES;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.view endEditing:YES];
    
    self.purchase.name = self.nameTextField.text;
    self.purchase.details = self.detailTextField.text;
    
    //Save the money details if it is a valid purchase only.
    //Accounts for when picture is changed and view disappears because of it.
    //The money details will remain on the page because their data source
    //is from the includedCopy and contributionsCopy, so the user won't be
    //confused after taking the picture (they still see the same info), but
    //invalid information should not be saved to the real purchase.
    if ([self isValidPurchase]) {
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        formatter.numberStyle = NSNumberFormatterCurrencyStyle;
        self.purchase.cost = [[formatter numberFromString:self.costLabel.text] doubleValue];
        
        self.purchase.contributions = [self.contributionsCopy mutableCopy];
        self.purchase.splitBetween = [self.includedCopy mutableCopy];
        
        self.purchase.evenSplitting = self.evenSplitting;
    }
}

- (void)setPurchase:(EEPurchase *)purchase
{
    _purchase = purchase;
    self.navigationItem.title = _purchase.name;
    
    //Make copies of purchase information
    self.contributionsCopy = [self.purchase.contributions mutableCopy];
    self.includedCopy = [self.purchase.splitBetween mutableCopy];
    self.evenSplitting = self.purchase.evenSplitting;
}

- (IBAction)splitTypeDidChange:(id)sender
{
    if (self.splitTypeSelector.selectedSegmentIndex) {
        self.evenSplitting = YES;
        self.canGoBack = YES;
        self.errorWarning.hidden = YES;
    }
    else {
        self.evenSplitting = NO;
    }
    
    [self.contributedTableView reloadData];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField == self.nameTextField) {
        if ([textField.text isEqualToString:@"New Purchase"]) {
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
            textField.text = @"New Purchase";
        }
    }
    
    return YES;
}

- (IBAction)backgroundTapped:(id)sender {
    [self.view endEditing:YES];
}

- (void)save:(id)sender
{
    //View is popped
    if ([self isValidPurchase]) {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
    //View remains. Colors are changed to red
    else {
        [self changeCellColorsToRed];
    }
}

- (void)cancel:(id)sender
{
    [self.group removePurchase:self.purchase];
    
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.group.allPeople count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 76;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EEPerson *person = self.group.allPeople[indexPath.row];

    __weak EEPaidTableCell *cell = (EEPaidTableCell *)[tableView dequeueReusableCellWithIdentifier:@"EEPaidTableCell"
                                                                                             forIndexPath:indexPath];
    
    cell.person = person;
    
    cell.contributions = self.contributionsCopy;
    cell.included = self.includedCopy;
    
    cell.evenSplitting = self.evenSplitting;
    
    cell.canGoBack = self.canGoBack;
    
    if (person.shouldPayNext) {
        cell.shouldPayNextLabel.hidden = NO;
    }
    else {
        cell.shouldPayNextLabel.hidden = YES;
    }
    
    //Happens when the user changes a cell text field or removes a person
    cell.updateCostActionBlock = ^{
        double totalCost = 0;
        for (NSNumber *contributionNumber in [self.contributionsCopy allValues]) {
            double contribution = [contributionNumber doubleValue];
            totalCost += contribution;
        }
        
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        formatter.numberStyle = NSNumberFormatterCurrencyStyle;
        formatter.maximumFractionDigits = 2;
        NSString *totalCostString = [formatter stringFromNumber:
                                     [NSNumber numberWithDouble:totalCost]];
        self.costLabel.text = [NSString stringWithFormat:@"%@", totalCostString];
    };
    
    //Happens when the user changes a cell text field or removes a person
    cell.updatePurchasePermittedBlock = ^{
        BOOL isValidPurchase = [self isValidPurchase];
        
        //Check if it is a new purchase, and then set the viewController's
        //canGoBack property accordingly. Reload the table so that
        //all of the cells will change to the proper color.
        if (self.navigationItem.rightBarButtonItem) {
            //If the new text entry results in a valid purchase, update all the cell colors
            //to white and allow the done button to function.
            if (isValidPurchase) {
                self.canGoBack = YES;
                self.errorWarning.hidden = YES;
                [tableView reloadData];
            }
            //If not, do not change the cell colors (wether they are red or white).
            //When the done button is pressed, it will change the colors to red
        }
        //The purchase is not new. The back button is visible.
        //Because the back button's action method cannot be changed,
        //it will check the validity of the purchase once again to
        //determine if it will allow navigation.
        else {
            //If the new text entry results in a valid purchase, update all the cell colors
            //to white
            if (isValidPurchase) {
                self.canGoBack = YES;
                self.errorWarning.hidden = YES;
                [tableView reloadData];
            }
            //If not, do not change the cell colors (wether they are red or white).
            //When the back button is pressed, it will change the colors to red
        }
    };
    
    cell.reloadTableBlock = ^{
        [self.contributedTableView reloadData];
    };
    
    return cell;
}

- (BOOL)isValidPurchase
{
    BOOL isValidPurchase;
    double sum = 0;
    
    //Check if it is a valid purchase
    NSArray *splitPercentages = [self.includedCopy allValues];
    for (NSNumber *split in splitPercentages) {
        sum += [split doubleValue];
    }
    
    if (self.evenSplitting) {
        isValidPurchase = YES;
    }
    else if (sum-100 != 0) {
        isValidPurchase = NO;
        
        //Update error label text
        NSNumberFormatter *decimalFormatter = [[NSNumberFormatter alloc] init];
        decimalFormatter.numberStyle = NSNumberFormatterDecimalStyle;
        decimalFormatter.maximumFractionDigits = 2;
        
        if (sum-100 > 0) {
            NSNumber *percentAbove = [NSNumber numberWithDouble:fabs(sum-100)];
            self.errorWarning.text = [NSString stringWithFormat:@"Total split surpasses 100%% by %@%%",
                                      [decimalFormatter stringFromNumber:percentAbove]];
        }
        else {
            NSNumber *percentBellow = [NSNumber numberWithDouble:fabs(sum-100)];
            self.errorWarning.text = [NSString stringWithFormat:@"Total split bellow 100%% by %@%%",
                                      [decimalFormatter stringFromNumber:percentBellow]];
        }
    }
    else {
        isValidPurchase = YES;
    }
    
    return isValidPurchase;
}

- (BOOL)navigationShouldPopOnBackButton
{
    //View is popped
    if ([self isValidPurchase]) {
        return YES;
    }
    
    //View remains. Colors are changed to red
    else {
        [self changeCellColorsToRed];
        return NO;
    }
}

- (void)changeCellColorsToRed
{
    self.canGoBack = NO;
    self.errorWarning.hidden = NO;
    [self.contributedTableView reloadData];
}

- (IBAction)showImage:(id)sender
{
    NSString *purchaseKey = self.purchase.purchaseKey;
    
    UIImage *img = [[EEImageStore sharedStore] imageForKey:purchaseKey];
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
    //Show the image in the EEImageViewController
    else {
        EEImageViewController *ivc = [[EEImageViewController alloc] init];
        ivc.purchase = self.purchase;
        
        [self.navigationController pushViewController:ivc animated:YES];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = info[UIImagePickerControllerEditedImage];
    
    EEPurchase *purchase = self.purchase;
    
    [purchase setThumbnailForImage:image];
    [[EEImageStore sharedStore] setImage:image forKey:purchase.purchaseKey];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
