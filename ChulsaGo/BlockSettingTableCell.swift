//
//  BlockSettingTableCell.swift
//  ChulsaGo
//
//  Created by nuri Lee on 2017. 12. 18..
//  Copyright © 2017년 nuri lee. All rights reserved.
//

import UIKit

class BlockSettingTableCell : UITableViewCell{
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var labelNickName: UILabel!
    
    @IBOutlet weak var btnBlockDelete: RoundButton!
    
    @IBAction func btnBlockDeletePress(_ sender: RoundButton) {
        
        let tag = sender.tag;
        
        //print(tag);
    }
}
