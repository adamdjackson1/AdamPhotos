//
//  IAPHelper.swift
//  Adam's Photos
//
//  Created by Adam Jackson on 23/06/19.
//  Copyright © 2019 Adam Jackson. All rights reserved.
//

import UIKit
import StoreKit

class IAPHelper: NSObject, SKProductsRequestDelegate {
        let productIdentifiers: NSSet
        override init() {
            productIdentifiers = NSSet(objects: "com.adamjackson.adamsphotos.coriander", "com.adamjackson.adamsphotos.bacon", "com.adamjackson.adamsphotos.baconnc", "com.adamjackson.adamsphotos.chicken", "com.adamjackson.adamsphotos.chocolate")
    }
    
    var completionHandler: ((Bool, [SKProduct]) -> Void)!
    
    func requestProductsWithCompletionHandler(completionHandler:@escaping (Bool, [SKProduct]) -> Void){
        self.completionHandler = completionHandler
        
        let productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers as! Set<String>)
        productsRequest.delegate = (self as SKProductsRequestDelegate)
        productsRequest.start()
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        
        print("product count \(response.products.count)")
        print("invalid product IDs \(response.invalidProductIdentifiers)")
        
        if response.products.count > 0 {
            var products: [SKProduct] = []
            
            for prod in response.products {
                if prod.isKind(of: SKProduct.self) {
                    products.append(prod as SKProduct)
                }
            }
            
            completionHandler(true, products)
        }
    }
    
    private func request(request: SKRequest!, didFailWithError error: NSError!) {
        
        completionHandler(false, [])
        
    }
    
}
