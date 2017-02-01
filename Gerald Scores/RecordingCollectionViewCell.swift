//
//  ViewCell.swift
//  Gerald Scores
//
//  Created by Gerald Z on 12/12/16.
//  Copyright © 2016 Gerald Z. All rights reserved.
//
import UIKit

class RecordingCollectionViewCell: UICollectionViewCell {

    @IBOutlet var label: UILabel!
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let view = UIView(frame:self.frame)
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.backgroundColor = UIColor(red: 0.2, green: 0.6, blue: 1.0, alpha: 1.0)
        view.layer.borderColor = UIColor.white.cgColor
        view.layer.borderWidth = 4
        self.selectedBackgroundView = view
    }
    
}
