//
//  EEGroup.m
//  SplitIt
//
//  Created by ERIC ELMOZNINO on 2015-07-08.
//  Copyright (c) 2015 Eric Elmoznino. All rights reserved.
//

#import "EEGroup.h"
#import "EEImageStore.h"

@interface EEGroup ()

@property (nonatomic) NSMutableArray *privatePeople;
@property (nonatomic) NSMutableArray *privatePurchases;

@end


@implementation EEGroup

- (instancetype)init
{
    self = [super init];
    
    self.name = @"";
    self.dateCreated = [NSDate date];
    self.privatePeople = [[NSMutableArray alloc] init];
    self.privatePurchases = [[NSMutableArray alloc] init];
    
    return self;
}

- (NSArray *)allPeople
{
    return self.privatePeople;
}

- (NSArray *)allPurchases
{
    return self.privatePurchases;
}

- (void)addPerson:(EEPerson *)person
{
    [self.privatePeople insertObject:person atIndex:0];
}

- (void)removePerson:(EEPerson *)person
{
    //Delete image
    [[EEImageStore sharedStore] deleteImageForKey:person.personKey];
    
    [self.privatePeople removeObjectIdenticalTo:person];
}

- (void)addPurchase:(EEPurchase *)purchase
{
    [self.privatePurchases insertObject:purchase atIndex:0];
}

- (void)removePurchase:(EEPurchase *)purchase
{
    //Delete image
    [[EEImageStore sharedStore] deleteImageForKey:purchase.purchaseKey];
    
    [self.privatePurchases removeObjectIdenticalTo:purchase];
}

- (void)updateBalances
{
    EEPerson *personWithSmallestBalance;
    double smallestBalance = 0;
    
    for (EEPerson *person in self.allPeople) {
        person.balance = 0;
        person.shouldPayNext = NO;
        
        for (EEPurchase *purchase in self.allPurchases) {
            NSDictionary *contributions = purchase.contributions;
            NSDictionary *included = purchase.splitBetween;
            
            //Credit
            if ([contributions.allKeys containsObject:person.personKey]) {
                person.balance += [contributions[person.personKey] doubleValue];
            }
            
            //Owed
            if ([included.allKeys containsObject:person.personKey]) {
                person.balance -= purchase.cost * [included[person.personKey] doubleValue]/100;
            }
        }
        
        if (person.balance <= smallestBalance) {
            personWithSmallestBalance = person;
            smallestBalance = person.balance;
        }
    }
    
    //Set the person who should pay next
    if (personWithSmallestBalance) {
        personWithSmallestBalance.shouldPayNext = YES;
    }
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.dateCreated forKey:@"dateCreated"];
    [aCoder encodeObject:self.privatePeople forKey:@"privatePeople"];
    [aCoder encodeObject:self.privatePurchases forKey:@"privatePurchases"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if (self) {
        self.name = [aDecoder decodeObjectForKey:@"name"];
        self.dateCreated = [aDecoder decodeObjectForKey:@"dateCreated"];
        self.privatePeople = [aDecoder decodeObjectForKey:@"privatePeople"];
        self.privatePurchases = [aDecoder decodeObjectForKey:@"privatePurchases"];
    }
    
    return self;
}

@end
