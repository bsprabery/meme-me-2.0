//
//  MemeDetailViewController.swift
//  MemeMe v 1.0
//
//  Created by Brittany Sprabery on 8/8/16.
//  Copyright © 2016 Brittany Sprabery. All rights reserved.
//

import Foundation
import UIKit

class MemeDetailViewController: UIViewController {
    
    @IBOutlet weak var detailImageView: UIImageView!
    @IBOutlet weak var detailTopText: UILabel!
    @IBOutlet weak var detailBottomText: UILabel!
    
    var meme: Meme!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        detailTopText.text = meme.top
        detailBottomText.text = meme.bottom
        detailImageView.image = meme.memedImage
        
        self.tabBarController?.tabBar.hidden = true
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.hidden = false
    }
    
}