//
//  DetailViewController.swift
//  Adam's Photos
//
//  Created by Adam Jackson on 23/06/19.
//  Copyright © 2019 Adam Jackson. All rights reserved.
//

import UIKit
import StoreKit

class DetailViewController: UIViewController {

    @IBOutlet weak var detailDescriptionLabel: UILabel!
    @IBOutlet weak var buyButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var progressLabel2: UILabel!
    

    func configureView() {
            if let product: SKProduct = self.detailItem {
                if let label = self.detailDescriptionLabel {
                    label.text = product.localizedDescription
                }
                if let button = self.buyButton {
                    configureBuyButton(product: product)
                }
            }
        }
  
    func configureBuyButton(product: SKProduct) {
        let numberFormatter = NumberFormatter()
        
        numberFormatter.formatterBehavior = .behavior10_4
        numberFormatter.numberStyle = .currency
        numberFormatter.locale = product.priceLocale
        
        let formattedPrice = numberFormatter.string(from: product.price)
        let buttonTitle = String(format: " Buy for %@ ", formattedPrice!)
        
        buyButton.setTitle(buttonTitle, for: .normal)
        
        buyButton.layer.borderWidth = 1.0
        buyButton.layer.cornerRadius = 4.0
        buyButton.layer.borderColor = buyButton.tintColor?.cgColor

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.isHidden = true
        progressView.isHidden = true
        statusLabel.isHidden = true
        progressLabel.text = progressLabelText
        progressLabel2.text = progressLabelText2

        configureView()
        signUpForNotifications()
    }

    var detailItem: SKProduct? {
        didSet {
            // Update the view.
            configureView()
        }
    }

    func signUpForNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(receivedPurchaseInProgressNotification(notification:)), name: NSNotification.Name(rawValue: IAPTransactionInProgress), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(receivedPurchaseFailedNotification(notification:)), name: NSNotification.Name(rawValue: IAPTransactionFailed), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(receivedPurchaseCompletedNotification(notification:)), name: NSNotification.Name(rawValue: IAPTransactionComplete), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(receivedDownloadWaitingNotification(notification:)), name: NSNotification.Name(rawValue: "IAPDownloadWaiting"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(receivedDownloadActiveNotification(notification:)), name: NSNotification.Name(rawValue: "IAPDownloadActive"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(receivedDownloadFinishedNotification(notification:)), name: NSNotification.Name(rawValue: "IAPDownloadFinished"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(receivedDownloadFailedNotification(notification:)), name: NSNotification.Name(rawValue: "IAPDownloadFailed"), object: nil)
    }
    
    @IBAction func buyPressed(sender: UIButton) {
        updateUIForPurchaseInProgress(inProgress: true)
        if let product = self.detailItem {
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(payment)
        }
    }

    
    @IBAction func checkCache(sender: UIButton) {
        let folder = manager.urls(for: .cachesDirectory, in: .userDomainMask)
               let folderURL = folder.first!
        let path = folderURL.path
        do {
                    let files = try manager.contentsOfDirectory(atPath: path)
                    for file in files {
                        print (file)}
                               } catch {
                                   print("Error")
                               }
    }
    
    
    func updateUIForPurchaseInProgress(inProgress: Bool){
        buyButton.isHidden = inProgress
        if inProgress {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }

    @objc func receivedPurchaseInProgressNotification(notification: NSNotification) {
        
        updateUIForPurchaseInProgress(inProgress: true)
    }
    
    
    @objc func receivedPurchaseFailedNotification(notification: NSNotification) {
        
        updateUIForPurchaseInProgress(inProgress: false)
        
        let error = notification.object as! NSError
        
        let alert = UIAlertController(title: "Error", message: error.localizedDescription , preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func receivedPurchaseCompletedNotification(notification: NSNotification){
        
        updateUIForPurchaseInProgress(inProgress: false)
        print("hmmm")
        //show indicator that download is in progress
    }

    @objc func receivedDownloadWaitingNotification(notification: NSNotification) {
        statusLabel.text = "waiting"
        progressView.progress = 0.0
        statusLabel.isHidden = false
        progressView.isHidden = false
    }
    
    @objc func receivedDownloadActiveNotification(notification: NSNotification) {
        statusLabel.text = "downloading"
        progressView.progress = 0.0
        statusLabel.isHidden = false
        progressView.isHidden = false
    }
    
    @objc func receivedDownloadFinishedNotification(notification: NSNotification) {
           statusLabel.text = "Download complete"
           progressView.progress = 1
           statusLabel.isHidden = false
           progressView.isHidden = false
        buyButton.titleLabel!.text = "Purchased"
        buyButton.isEnabled = false
       }
    
    @objc func receivedDownloadFailedNotification(notification: NSNotification) {
        let download = notification.object as? SKDownload
        let error = download?.error
             
        displayErrorAlert(error: error!)
          }
    
    func displayErrorAlert(error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription , preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
}

