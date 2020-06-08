//
//  MasterViewController.swift
//  Adam's Photos
//
//  Created by Adam Jackson on 23/06/19.
//  Copyright © 2019 Adam Jackson. All rights reserved.
//

import UIKit
import StoreKit

class MasterViewController: UITableViewController {
    
    

    var detailViewController: DetailViewController? = nil
    var objects = [Any]()
let helper = IAPHelper()
    

    override func viewDidLoad() {
        super.viewDidLoad()

        self.helper.requestProductsWithCompletionHandler(completionHandler: { (success, products) -> Void in
                if success {
                    
                    for newProduct in products {
                    self.objects.append(newProduct)
                    }
                    self.tableView.reloadData()
                } else {
                    let alert = UIAlertController(title: "Error", message: "Cannot retrieve products list right now.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
          })
        
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

 

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let object = objects[indexPath.row] as! SKProduct
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.title = object.localizedDescription
                controller.detailItem = object
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        let product = objects[indexPath.row] as! SKProduct
        cell.textLabel!.text = product.localizedTitle
        
         return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            objects.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }

    @IBAction func restoreButtonPressed(_ sender: UIBarButtonItem) {
        
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
}

