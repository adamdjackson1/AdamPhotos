//
//  PaymentTransactionObserver.swift
//  Adam's Photos
//
//  Created by Adam Jackson on 20/07/19.
//  Copyright © 2019 Adam Jackson. All rights reserved.
//

import UIKit
import StoreKit



let IAPTransactionInProgress = "IAPTransactionInProgress"
let IAPTransactionFailed = "IAPTransactionFailed"
let IAPTransactionComplete = "IAPTransactionComplete"
let manager = FileManager.default

let notificationcenter = UNUserNotificationCenter.current()
let center = NotificationCenter.default

class PaymentTransactionObserver: NSObject, SKPaymentTransactionObserver, UNUserNotificationCenterDelegate {
    
    var name = Notification.Name(rawValue: "IAP Status")
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
                
                    switch (transaction.transactionState) {
                    case SKPaymentTransactionState.purchasing:
                        name = Notification.Name(rawValue: "IAPTransactionInProgress")
                        center.post(name: name, object: nil, userInfo: nil)
                        showTransactionAsInProgress(deferred: true)
                    case SKPaymentTransactionState.deferred:
                        name = Notification.Name(rawValue: "IAPTransactionInProgress")
                        center.post(name: name, object: nil, userInfo: nil)
                        showTransactionAsInProgress(deferred: true)
                    case SKPaymentTransactionState.failed:
                        failedTransaction(transaction: transaction)
                    case SKPaymentTransactionState.purchased:
                        completeTransaction(transaction: transaction)
                    case SKPaymentTransactionState.restored:
                        restoreTransaction(transaction: transaction)
                    default:
                        break
                    }
            }
        }
    
    func showTransactionAsInProgress(deferred: Bool) {
        NotificationCenter.default.post(name: name, object: deferred)
    }
    
    func failedTransaction(transaction: SKPaymentTransaction) {
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: IAPTransactionFailed), object: transaction.error)
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    func completeTransaction(transaction: SKPaymentTransaction) {
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: IAPTransactionComplete), object: transaction)
        
        let downloads = transaction.downloads
        if downloads != [] {
            SKPaymentQueue.default().start(downloads)
        }
        
    }
    
    func restoreTransaction(transaction: SKPaymentTransaction) {
        // Not sure what goes in here.
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedDownloads downloads: [SKDownload]) {
        for d in downloads {
                  
            if let download = d as? SKDownload {
                switch (download.state) {
                case .waiting:
                 waitingDownload(download: download)
                case .active:
                 activeDownload(download: download)
                case .finished:
                 finishedDownload(download: download)
                case .failed:
                 failedDownload(download: download)
                case .cancelled:
                   cancelledDownload(download: download)
                case .paused:
                 pausedDownload(download: download)
                }
            }
        }
    }
    
    func paymentQueue(queue: SKPaymentQueue!, updatedDownloads downloads: [AnyObject]!) {
             
       for d in downloads {
                 
           if let download = d as? SKDownload {
               switch (download.state) {
               case .waiting:
                waitingDownload(download: download)
               case .active:
                activeDownload(download: download)
               case .finished:
                finishedDownload(download: download)
               case .failed:
                failedDownload(download: download)
               case .cancelled:
                  cancelledDownload(download: download)
               case .paused:
                pausedDownload(download: download)
               }
           }
        }
    }
    
    func waitingDownload(download: SKDownload) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "IAPDownloadWaiting"), object: download)
    }
    
    func activeDownload(download: SKDownload) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "IAPDownloadActive"), object: download)
    }
    
    func finishedDownload(download: SKDownload) {
       print("Got into finishedDownload function")
          
        guard let hostedContentPath = download.contentURL?.appendingPathComponent("Contents") else {
             return
         }
        
         do {
             let files = try FileManager.default.contentsOfDirectory(atPath: hostedContentPath.relativePath)
             for file in files {
                 let source = hostedContentPath.appendingPathComponent(file)
                 let sourcePath = source.path
                print("Source: " + sourcePath)
                let destinationURL = manager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
                destinationPath = destinationURL!.path
                pictureSource = source.path
   //             let unZipped = SSZipArchive.unzipFile(atPath: sourcePath, toDestination: destinationPath!)
    /*
                 let destinationURL = manager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
                 destinationPath = destinationURL?.path
                progressLabelText2 = "Destination: " + destinationPath!
               
                        do {
                        try manager.copyItem(atPath: sourcePath, toPath: destinationPath!)
                        } catch {
                            print("Error")
                        }
 */
             }

             //Delete cached file
             do {
                 try FileManager.default.removeItem(at: download.contentURL!)
             } catch {
                 //catch error
             }
         } catch {
             //catch error
         }
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "IAPDownloadFinished"), object: nil)
             
        SKPaymentQueue.default().finishTransaction(download.transaction)
    }
    
    func failedDownload(download: SKDownload) {
             
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "IAPDownloadFailed"), object: download)
             
        SKPaymentQueue.default().finishTransaction(download.transaction)
    }
    
    func cancelledDownload(download: SKDownload) {
        // Nothing for now.  Only relevant if allow cancellation.
    }
    
    func pausedDownload(download: SKDownload) {
        // Nothing for now.  Only relevant if allow pausing.
    }
    
    deinit {
        
        NotificationCenter.default.removeObserver(self)
    }
    
}
