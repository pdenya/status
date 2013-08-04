//
//  IAPHelper.m
//  Status
//
//  Created by Paul Denya on 8/3/13.
//  Copyright (c) 2013 NEXTMARVEL. All rights reserved.
//

#import "IAPHelper.h"
#import "ViewController.h"

NSString *const IAPHelperProductPurchasedNotification = @"IAPHelperProductPurchasedNotification";

@implementation IAPHelper

+ (IAPHelper *)instance {
    static dispatch_once_t once;
    static IAPHelper *sharedInstance;
	
    dispatch_once(&once, ^{
        NSSet *productIdentifiers = [NSSet setWithObjects:@"com.nextmarvel.status.upgrade",nil];
        sharedInstance = [[self alloc] initWithProductIdentifiers:productIdentifiers];
    });
	
    return sharedInstance;
}

- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers {
	if ((self = [super init])) {
		
        // Store product identifiers
        _productIdentifiers = productIdentifiers;
		
        // Check for previously purchased products
        _purchasedProductIdentifiers = [[NSMutableSet alloc] init];
        for (NSString *productIdentifier in _productIdentifiers) {
            BOOL productPurchased = [[NSUserDefaults standardUserDefaults] boolForKey:productIdentifier];
            if (productPurchased) {
                [_purchasedProductIdentifiers addObject:productIdentifier];
                NSLog(@"Previously purchased: %@", productIdentifier);
            } else {
                NSLog(@"Not purchased: %@", productIdentifier);
            }
        }
			
		[[SKPaymentQueue defaultQueue] addTransactionObserver:self];
		
		[self requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
			if (success) {
				self.products = products;
				NSLog(@"products  %@", [products description]);
			}
		}];
    }
	
    return self;
}

- (void)requestProductsWithCompletionHandler:(RequestProductsCompletionHandler)completionHandler {
	// 1
    _completionHandler = [completionHandler copy];
	
    // 2
    _productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:_productIdentifiers];
    _productsRequest.delegate = self;
    [_productsRequest start];
}

#pragma mark - SKProductsRequestDelegate

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    NSLog(@"Loaded list of products...");
    _productsRequest = nil;
	
    NSArray *skProducts = response.products;
    for (SKProduct *skProduct in skProducts) {
        NSLog(@"Found product: %@ %@ %0.2f", skProduct.productIdentifier, skProduct.localizedTitle, skProduct.price.floatValue);
    }
	
    _completionHandler(YES, skProducts);
    _completionHandler = nil;
	
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"Failed to load list of products.");
    _productsRequest = nil;
	
    _completionHandler(NO, nil);
    _completionHandler = nil;
	
}

- (BOOL)productPurchased:(NSString *)productIdentifier {
    return [_purchasedProductIdentifiers containsObject:productIdentifier];
}

- (void)buyProduct {
	SKProduct *product = [self.products objectAtIndex:0];
    NSLog(@"Buying %@...", product.productIdentifier);
	
    SKPayment *payment = [SKPayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
	
	//TODO: throw alert if there's no products
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
            default:
                break;
        }
    };
}

- (void)completeTransaction:(SKPaymentTransaction *)transaction {
    NSLog(@"completeTransaction...");
	
    [self provideContentForProductIdentifier:transaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction {
    NSLog(@"restoreTransaction...");
	
    [self provideContentForProductIdentifier:transaction.originalTransaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction {
	
    NSLog(@"failedTransaction...");
    if (transaction.error.code != SKErrorPaymentCancelled) {
        NSLog(@"Transaction error: %@", transaction.error.localizedDescription);
    }
	
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void)provideContentForProductIdentifier:(NSString *)productIdentifier {
    [_purchasedProductIdentifiers addObject:productIdentifier];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:productIdentifier];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
	[PDUtils upgradeComplete];
}

//TODO: call this from somewhere
- (void)restoreCompletedTransactions {
	[[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

@end