//
//  AlbumTableViewCell.swift
//  Itunes Manager
//
//  Created by Steven Hertz on 10/14/15.
//  Copyright © 2015 Steven Hertz. All rights reserved.
//

import UIKit

class AlbumTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var albumImageView: UIImageView!
    
    @IBAction func cellButton(sender: AnyObject) {
        print("button was pressed")
    }
    override func awakeFromNib() {
        super.awakeFromNib()        
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
