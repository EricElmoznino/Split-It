//
//  EEGroupStore.m
//  SplitIt
//
//  Created by ERIC ELMOZNINO on 2015-07-08.
//  Copyright (c) 2015 Eric Elmoznino. All rights reserved.
//

#import "EEGroupStore.h"
#import "EEImageStore.h"

@interface EEGroupStore ()

@property (nonatomic) NSMutableArray *privateGroups;

@end


@implementation EEGroupStore

+ (instancetype)sharedStore
{
    static EEGroupStore *sharedStore = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedStore = [[self alloc] initPrivate];
    });
    
    return sharedStore;
}

- (instancetype)init
{
    @throw [NSException exceptionWithName:@"Singleton"
                                   reason:@"Use +[EEGroupStore sharedStore]"
                                 userInfo:nil];
    return nil;
}

- (instancetype)initPrivate
{
    self = [super init];
    
    if (self) {
        NSString *path = [self groupArchivePath];
        _privateGroups = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        
        if (!_privateGroups) {
            _privateGroups = [[NSMutableArray alloc] init];
        }
    }
    
    return self;
}

- (NSArray *)allGroups
{
    return self.privateGroups;
}

- (void)addGroup:(EEGroup *)group
{
    [self.privateGroups insertObject:group atIndex:0];
}

- (void)removeGroup:(EEGroup *)group
{
    //For deleting images when a group is removed
    for (EEPerson *person in [group allPeople]) {
        [[EEImageStore sharedStore] deleteImageForKey:person.personKey];
    }
    for (EEPurchase *purchase in [group allPurchases]) {
        [[EEImageStore sharedStore] deleteImageForKey:purchase.purchaseKey];
    }
    
    [self.privateGroups removeObjectIdenticalTo:group];
}

- (void)moveItemAtIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex
{
    EEGroup *group = self.privateGroups[fromIndex];
    [self.privateGroups removeObject:group];
    [self.privateGroups insertObject:group atIndex:toIndex];
}

- (NSString *)groupArchivePath
{
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                                       NSUserDomainMask, YES);
    NSString *documentDirectory = [documentDirectories firstObject];
    
    return [documentDirectory stringByAppendingPathComponent:@"groups.archive"];
}

- (BOOL)saveChanges
{
    NSString *path = [self groupArchivePath];
    
    BOOL success = [NSKeyedArchiver archiveRootObject:_privateGroups toFile:path];
    
    return success;
}

@end
