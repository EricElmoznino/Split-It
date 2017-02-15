//
//  EEImageViewController.m
//  SplitIt
//
//  Created by GAD ELMOZNINO on 2015-07-15.
//  Copyright (c) 2015 Eric Elmoznino. All rights reserved.
//

#import "EEImageViewController.h"

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

@interface EEImageViewController ()
<UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@end

@implementation EEImageViewController

- (void)loadView {
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.view = imageView;
    
    UIBarButtonItem *cameraButton = [[UIBarButtonItem alloc]
                                     initWithBarButtonSystemItem:UIBarButtonSystemItemCamera
                                     target:self
                                     action:@selector(changeImage:)];
    self.navigationItem.rightBarButtonItem = cameraButton;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    UIImageView *imageView = (UIImageView *)self.view;
    if (self.purchase) {
        imageView.image = [[EEImageStore sharedStore] imageForKey:self.purchase.purchaseKey];
        self.navigationItem.title = self.purchase.name;
    }
    else {
        imageView.image = [[EEImageStore sharedStore] imageForKey:self.person.personKey];
        self.navigationItem.title = self.person.name;
    }
}

- (void)changeImage:(id)sender
{
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
            popover.barButtonItem = sender;
            popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
        }
        
        //Present the alertController
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = info[UIImagePickerControllerEditedImage];
    if (self.purchase) {
        [self.purchase setThumbnailForImage:image];
        [[EEImageStore sharedStore] setImage:image forKey:self.purchase.purchaseKey];
    }
    else {
        [self.person setThumbnailForImage:image];
        [[EEImageStore sharedStore] setImage:image forKey:self.person.personKey];
    }

    UIImageView *imageView = (UIImageView *)self.view;
    imageView.image = image;
    
    [self dismissViewControllerAnimated:NO completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
