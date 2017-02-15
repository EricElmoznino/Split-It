//
//  EEPersonTableCell.m
//  SplitIt
//
//  Created by GAD ELMOZNINO on 2015-07-14.
//  Copyright (c) 2015 Eric Elmoznino. All rights reserved.
//

#import "EEPersonTableCell.h"

@implementation EEPersonTableCell

- (IBAction)showImage:(id)sender {
    if (self.showImageBlock) {
        self.showImageBlock();
    }
}

@end
