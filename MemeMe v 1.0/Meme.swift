//
//  Meme.swift
//  MemeMe v 1.0
//
//  Created by Brittany Sprabery on 7/27/16.
//  Copyright © 2016 Brittany Sprabery. All rights reserved.
//

import Foundation
import UIKit

struct Meme {
    let top: String!
    let bottom: String!
    let originalImage: UIImage!
    let memedImage: UIImage!
    
  
    init(top: String, bottom: String, image: UIImage, memedImage: UIImage){
        self.top = top
        self.bottom = bottom
        self.originalImage = image
        self.memedImage = memedImage
    }

}

