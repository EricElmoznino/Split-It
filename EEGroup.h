//
//  EEGroup.h
//  SplitIt
//
//  Created by ERIC ELMOZNINO on 2015-07-08.
//  Copyright (c) 2015 Eric Elmoznino. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EEPurchase.h"
#import "EEPerson.h"

@interface EEGroup : NSObject
<NSCoding>

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSDate *dateCreated;
@property (nonatomic, readonly) NSArray *allPeople;
@property (nonatomic, readonly) NSArray *allPurchases;

- (instancetype)init;

- (void)addPerson:(EEPerson *)person;
- (void)removePerson:(EEPerson *)person;

- (void)addPurchase:(EEPurchase *)purchase;
- (void)removePurchase:(EEPurchase *)purchase;

- (void)updateBalances;

@end
