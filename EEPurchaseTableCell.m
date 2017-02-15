//
//  EEPurchaseTableCell.m
//  SplitIt
//
//  Created by GAD ELMOZNINO on 2015-07-14.
//  Copyright (c) 2015 Eric Elmoznino. All rights reserved.
//

#import "EEPurchaseTableCell.h"

@implementation EEPurchaseTableCell

- (IBAction)showImage:(id)sender {
    if (self.showImageBlock) {
        self.showImageBlock();
    }
}

@end
