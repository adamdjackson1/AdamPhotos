//
//  PictureViewController.swift
//  Adam's Photos
//
//  Created by Adam Jackson on 17/11/19.
//  Copyright © 2019 Adam Jackson. All rights reserved.
//

import UIKit

class PictureViewController: UIViewController {

    @IBOutlet weak var pictureView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        pictureView.layer.cornerRadius = 5
               pictureView.layer.borderWidth = 1
               pictureView.layer.borderColor = UIColor.black.cgColor
              pictureView.clipsToBounds = true
           
//        pictureView.image = UIImage(named: "coriander.png")
        pictureView.image = UIImage(contentsOfFile: pictureSource)
    }
    

  

}
