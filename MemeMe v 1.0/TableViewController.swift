//
//  TableViewController.swift
//  MemeMe v 1.0
//
//  Created by Brittany Sprabery on 8/2/16.
//  Copyright © 2016 Brittany Sprabery. All rights reserved.
//

import Foundation
import UIKit

class TableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!

    var memes: [Meme] {
        return (UIApplication.sharedApplication().delegate as! AppDelegate).memes
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.memes.count > 0) {
            return self.memes.count
        } else {
            print("There are no memes in the array.")
            return 0
        }
    }

    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MemeCell")! as UITableViewCell
        let meme = memes[indexPath.row]
        
        let textStringOne = meme.top
        let textStringTwo = meme.bottom
        let fullText = textStringOne + " - " + textStringTwo
        
        cell.imageView?.image = meme.memedImage
        cell.textLabel?.text = fullText

        
        return cell
    }
    


}
