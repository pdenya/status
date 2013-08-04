//
//  IAPHelper.h
//  Status
//
//  Created by Paul Denya on 8/3/13.
//  Copyright (c) 2013 NEXTMARVEL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
UIKIT_EXTERN NSString *const IAPHelperProductPurchasedNotification;

typedef void (^RequestProductsCompletionHandler)(BOOL success, NSArray *products);

@interface IAPHelper : NSObject<SKProductsRequestDelegate, SKPaymentTransactionObserver> {
    // 3
    SKProductsRequest *_productsRequest;
    // 4
    RequestProductsCompletionHandler _completionHandler;
    NSSet *_productIdentifiers;
    NSMutableSet *_purchasedProductIdentifiers;
}

@property (nonatomic, retain) NSArray *products;

+ (IAPHelper *)instance;
- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers;
- (void)requestProductsWithCompletionHandler:(RequestProductsCompletionHandler)completionHandler;
- (void)buyProduct;
- (BOOL)productPurchased:(NSString *)productIdentifier;
- (void)restoreCompletedTransactions;

@end