//
//  EEPurchase.m
//  SplitIt
//
//  Created by ERIC ELMOZNINO on 2015-07-08.
//  Copyright (c) 2015 Eric Elmoznino. All rights reserved.
//

#import "EEPurchase.h"

@implementation EEPurchase

- (instancetype)init
{
    self = [super init];
    
    self.name = @"New Purchase";
    self.date = [NSDate date];
    self.cost = 0.0;
    self.evenSplitting = YES;
    
    self.contributions = [[NSMutableDictionary alloc] init];
    self.splitBetween = [[NSMutableDictionary alloc] init];
    
    
    NSUUID *uuid = [[NSUUID alloc] init];
    NSString *key = [uuid UUIDString];
    self.purchaseKey = key;
    
    return self;
}

- (void)setThumbnailForImage:(UIImage *)image {
    CGSize origImageSize = image.size;
    
    CGRect newRect = CGRectMake(0, 0, 40, 40);
    
    float ratio = MAX(newRect.size.width / origImageSize.width,
                      newRect.size.height / origImageSize.height);
    
    UIGraphicsBeginImageContextWithOptions(newRect.size, NO, 0.0);
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:newRect cornerRadius:5.0];
    
    [path addClip];
    
    CGRect projectRect;
    projectRect.size.width = ratio*origImageSize.width;
    projectRect.size.height = ratio*origImageSize.height;
    projectRect.origin.x = (newRect.size.width - projectRect.size.width)/2.0;
    projectRect.origin.y = (newRect.size.height - projectRect.size.height)/2.0;
    
    [image drawInRect:projectRect];
    
    UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
    self.thumbnailView = smallImage;
    
    UIGraphicsEndImageContext();
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.date forKey:@"date"];
    [aCoder encodeObject:self.details forKey:@"details"];
    [aCoder encodeDouble:self.cost forKey:@"cost"];
    [aCoder encodeBool:self.evenSplitting forKey:@"evenSplitting"];
    [aCoder encodeObject:self.purchaseKey forKey:@"purchaseKey"];
    [aCoder encodeObject:self.contributions forKey:@"contributions"];
    [aCoder encodeObject:self.splitBetween forKey:@"splitBetween"];
    [aCoder encodeObject:self.thumbnailView forKey:@"thumbnailView"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if (self) {
        self.name = [aDecoder decodeObjectForKey:@"name"];
        self.date = [aDecoder decodeObjectForKey:@"date"];
        self.details = [aDecoder decodeObjectForKey:@"details"];
        self.cost = [aDecoder decodeDoubleForKey:@"cost"];
        self.evenSplitting = [aDecoder decodeBoolForKey:@"evenSplitting"];
        self.purchaseKey = [aDecoder decodeObjectForKey:@"purchaseKey"];
        self.contributions = [aDecoder decodeObjectForKey:@"contributions"];
        self.splitBetween = [aDecoder decodeObjectForKey:@"splitBetween"];
        self.thumbnailView = [aDecoder decodeObjectForKey:@"thumbnailView"];
    }
    
    return self;
}

@end
