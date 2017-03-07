//
//  TableViewCell.swift
//  PRKFocusTime
//
//  Created by dabing on 15/10/21.
//  Copyright © 2015年 passerbycrk. All rights reserved.
//

import Foundation
import UIKit

open class TableViewCell: UITableViewCell, TableViewCellProtocol {
    
    fileprivate var theModel: AnyObject? // NOTE: Custom Model
    
    open var object: AnyObject? {
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
    
    open class func tableView(_ tableView: UITableView, rowHeightForObject: AnyObject) -> CGFloat {
        return 44
    }

    public required override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
    }
}
