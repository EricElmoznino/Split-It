//
//  EEPurchasesViewController.m
//  SplitIt
//
//  Created by ERIC ELMOZNINO on 2015-07-09.
//  Copyright (c) 2015 Eric Elmoznino. All rights reserved.
//

#import "EEPurchasesViewController.h"
#import "EEPurchaseViewController.h"
#import "EEImageViewController.h"
#import "EEPurchase.h"
#import "EEPurchaseTableCell.h"
#import "EEImageStore.h"

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

@interface EEPurchasesViewController ()
<UINavigationControllerDelegate, UIImagePickerControllerDelegate>

//Reference to which thumbnail was selected in order to change that
//purchase's thumbnail image
@property (nonatomic) NSInteger indexOfSelectedThumbnail;

@end

@implementation EEPurchasesViewController

- (instancetype)init {
    self = [super initWithStyle:UITableViewStylePlain];
    
    if (self) {
        self.tabBarItem.title = @"Purchases";
        self.tabBarItem.image = [UIImage imageNamed:@"ShoppingCart"];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UINib *nib = [UINib nibWithNibName:@"EEPurchaseTableCell" bundle:nil];
    [self.tableView registerNib:nib
         forCellReuseIdentifier:@"EEPurchaseTableCell"];
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 50, 0, 0);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc]
                                  initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                  target:self
                                  action:@selector(addNewPurchase:)];
    self.tabBarController.navigationItem.rightBarButtonItem = addButton;
    
    //Recompute balances
    [self.group updateBalances];
    
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.group.allPurchases count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EEPurchaseTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EEPurchaseTableCell"
                                                                forIndexPath:indexPath];
    
    NSArray *purchases = self.group.allPurchases;
    EEPurchase *purchase = purchases[indexPath.row];
    
    cell.nameLabel.text = purchase.name;
    
    if (purchase.thumbnailView) {
        cell.thumbnailView.image = purchase.thumbnailView;
    }
    else {
        cell.thumbnailView.image = [UIImage imageNamed:@"PurchasePlaceholder"];
    }
    
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
    
    __weak EEPurchaseTableCell *weakCell = cell;
    cell.showImageBlock = ^{
        EEPurchaseTableCell *strongCell = weakCell;
        
        NSString *purchaseKey = purchase.purchaseKey;
        
        UIImage *img = [[EEImageStore sharedStore] imageForKey:purchaseKey];
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
            ivc.purchase = purchase;
            
            [self.navigationController pushViewController:ivc animated:YES];
        }
    };

    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSArray *purchases = self.group.allPurchases;
        EEPurchase *purchase = purchases[indexPath.row];
        [self.group removePurchase:purchase];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    EEPurchase *purchase = self.group.allPurchases[indexPath.row];
    EEPurchaseViewController *purchaseVC = [[EEPurchaseViewController alloc] initWithNew:NO];
    purchaseVC.group = self.group;
    purchaseVC.purchase = purchase;
    
    UINavigationController *nc = self.tabBarController.navigationController;
    [nc pushViewController:purchaseVC animated:YES];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *label = [[UILabel alloc] init];
    label.text = @"Purchases";
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

- (void)addNewPurchase:(id)sender
{
    EEPurchase *purchase = [[EEPurchase alloc] init];
    [self.group addPurchase:purchase];
    
    EEPurchaseViewController *purchaseVC = [[EEPurchaseViewController alloc] initWithNew:YES];
    purchaseVC.group = self.group;
    purchaseVC.purchase = purchase;
    
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:purchaseVC];
    nc.navigationBar.translucent = NO;
    
    [self presentViewController:nc animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = info[UIImagePickerControllerEditedImage];
    
    EEPurchase *purchase = self.group.allPurchases[self.indexOfSelectedThumbnail];
    
    [purchase setThumbnailForImage:image];
    [[EEImageStore sharedStore] setImage:image forKey:purchase.purchaseKey];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
