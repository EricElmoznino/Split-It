//
//  EEPerson.m
//  SplitIt
//
//  Created by ERIC ELMOZNINO on 2015-07-08.
//  Copyright (c) 2015 Eric Elmoznino. All rights reserved.
//

#import "EEPerson.h"

@implementation EEPerson

- (instancetype)init
{
    self = [super init];
    
    self.name = @"New Person";
    self.emailAddress = @"";
    self.balance = 0;
    self.shouldPayNext = NO;
    
    NSUUID *uuid = [[NSUUID alloc] init];
    NSString *key = [uuid UUIDString];
    self.personKey = key;
    
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@: %lf",self.name,self.balance];
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
    [aCoder encodeObject:self.emailAddress forKey:@"emailAddress"];
    [aCoder encodeDouble:self.balance forKey:@"balance"];
    [aCoder encodeBool:self.shouldPayNext forKey:@"shouldPayNext"];
    [aCoder encodeObject:self.personKey forKey:@"personKey"];
    [aCoder encodeObject:self.thumbnailView forKey:@"thumbnailView"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if (self) {
        self.name = [aDecoder decodeObjectForKey:@"name"];
        self.emailAddress = [aDecoder decodeObjectForKey:@"emailAddress"];
        self.balance = [aDecoder decodeDoubleForKey:@"balance"];
        self.shouldPayNext = [aDecoder decodeBoolForKey:@"shouldPayNext"];
        self.personKey = [aDecoder decodeObjectForKey:@"personKey"];
        self.thumbnailView = [aDecoder decodeObjectForKey:@"thumbnailView"];
    }
    
    return self;
}

@end
