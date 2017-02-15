//
//  EEGroupStore.h
//  SplitIt
//
//  Created by ERIC ELMOZNINO on 2015-07-08.
//  Copyright (c) 2015 Eric Elmoznino. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EEGroup.h"

@interface EEGroupStore : NSObject

@property (nonatomic, readonly) NSArray *allGroups;

+ (instancetype)sharedStore;
- (void)addGroup:(EEGroup *)group;
- (void)removeGroup:(EEGroup *)group;
- (void)moveItemAtIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex;

- (BOOL)saveChanges;

@end
