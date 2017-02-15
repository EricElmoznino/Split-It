//
//  EEPurchase.h
//  SplitIt
//
//  Created by ERIC ELMOZNINO on 2015-07-08.
//  Copyright (c) 2015 Eric Elmoznino. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface EEPurchase : NSObject
<NSCoding>

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSString *details;
@property (nonatomic) double cost;
@property (nonatomic, strong) NSString *purchaseKey;

//Keys are contributees, values are amount contributed
@property (nonatomic, strong) NSMutableDictionary *contributions;
//Keys are people split between, values are percent split
@property (nonatomic, strong) NSMutableDictionary *splitBetween;

@property (nonatomic) BOOL evenSplitting;

@property (nonatomic, strong) UIImage *thumbnailView;

- (instancetype)init;
- (void)setThumbnailForImage:(UIImage *)image;

@end
