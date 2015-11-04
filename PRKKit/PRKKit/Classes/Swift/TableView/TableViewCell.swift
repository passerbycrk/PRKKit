//
//  TableViewCell.swift
//  PRKFocusTime
//
//  Created by dabing on 15/10/21.
//  Copyright © 2015年 passerbycrk. All rights reserved.
//

import Foundation
import UIKit

public class TableViewCell: UITableViewCell, TableViewCellProtocol {
    
    private var theModel: AnyObject? // NOTE: Custom Model
    
    public var object: AnyObject? {
        get {
            return theModel
        }
        set {
            if newValue !== theModel {
                theModel = newValue
                // NOTE: Change Action
            }
        }
    }
    
    public class func tableView(tableView: UITableView, rowHeightForObject: AnyObject) -> CGFloat {
        return 44
    }

    public required override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
    }
}