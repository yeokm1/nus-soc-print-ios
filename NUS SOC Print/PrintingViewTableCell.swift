//
//  PrintingViewTableCell.swift
//  NUS SOC Print
//
//  Created by Yeo Kheng Meng on 17/8/14.
//  Copyright (c) 2014 Yeo Kheng Meng. All rights reserved.
//

import Foundation
import UIKit

class PrintingViewTableCell : UITableViewCell {

    @IBOutlet weak var header: UILabel!
    @IBOutlet weak var smallFooter: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var tick: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        header.text = ""
        smallFooter.text = ""
        progressBar.hidden = true
        progressBar.setProgress(0, animated: false)
        tick.hidden = true
        if(activityIndicator.isAnimating()){
            activityIndicator.stopAnimating()
        }
        
        activityIndicator.hidden = true
        
    }
    
}
