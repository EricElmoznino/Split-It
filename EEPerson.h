//
//  EEPerson.h
//  SplitIt
//
//  Created by ERIC ELMOZNINO on 2015-07-08.
//  Copyright (c) 2015 Eric Elmoznino. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface EEPerson : NSObject
<NSCoding>

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *emailAddress;
@property (nonatomic) double balance;
@property (nonatomic) BOOL shouldPayNext;
@property (nonatomic, strong) NSString *personKey;
@property (nonatomic, strong) UIImage *thumbnailView;

- (instancetype)init;
- (void)setThumbnailForImage:(UIImage *)image;

@end
