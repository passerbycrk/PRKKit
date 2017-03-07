//
//  TableViewDataSource.swift
//  PRKFocusTime
//
//  Created by dabing on 15/10/21.
//  Copyright © 2015年 passerbycrk. All rights reserved.
//

import Foundation
import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


@objc
public protocol TableViewCellProtocol : NSObjectProtocol {
    // @required
    var object: AnyObject? { get set }
}

@objc
public protocol TableViewDataSourceProtocol : UITableViewDataSource {
    // @required
    func tableView(_ tableView: UITableView, cellClassForObject object: AnyObject? ) -> AnyClass!
    // @optional
    @objc optional func tableView(_ tableView: UITableView, indexPathForObject object: AnyObject? ) -> IndexPath?
    @objc optional func tableView(_ tableView: UITableView, canBeginMoveRowAtIndexPath indexPath: IndexPath) -> Bool
    @objc optional func tableView(_ tableView: UITableView, objectForRowAtIndexPath indexPath: IndexPath) -> AnyObject?
}

open class TableViewSection: NSObject {
    open var items: [NSObject]? = [NSObject]()
    open var letter: String?
    open var headerTitle: String?
    open var footerTitle: String?
    open var userInfo: AnyObject?
}

open class TableViewDataSource: NSObject, TableViewDataSourceProtocol {
    // 两种写法
//    var sections: Array<TableViewSection>? = Array<TableViewSection>()
    open var sections: [TableViewSection]? = [TableViewSection]()
    
    open var firstItems: [NSObject]? {
        get {
            if let aSection: TableViewSection? = tableView(sectionObjectForSection: 0) {
                return aSection?.items
            }
            return nil
        }
        set {
            if nil == sections || sections!.count <= 0 {
                sections = [TableViewSection]()
                let aSection: TableViewSection = TableViewSection()
                sections?.append(aSection)
            }
            let aSection: TableViewSection? = tableView(sectionObjectForSection: 0)
            aSection?.items = newValue
        }
    }
    
    public override init () {
        super.init()
    }
    
    // MARK: - Public
    
    // Required
    open func tableView(_ tableView: UITableView, cellClassForObject object: AnyObject? ) -> AnyClass! {
        return TableViewCell.classForCoder()
    }
    
    open func tableView(sectionObjectForSection section: Int ) -> TableViewSection? {
        var ret: TableViewSection?
        if nil != sections && sections?.count > section {
            //ret = sections?.objectAtIndex(section) as? TableViewSection;
            ret = sections![section]
        }
        return ret
    }
    
    open func tableView(_ tableView: UITableView, objectForRowAtIndexPath indexPath: IndexPath) -> AnyObject? {
        var ret: AnyObject?
        let aSection: TableViewSection? = self.tableView(sectionObjectForSection: indexPath.section);
        if nil != aSection && aSection!.items?.count > indexPath.row {
            ret = aSection!.items?[indexPath.row]
        }
        return ret
    }
    
    open func tableView(_ tableView: UITableView, indexPathForObject object: AnyObject? ) -> IndexPath? {
        var ret: IndexPath?
        if nil != object {
            for sectionIdx in 0..<sections!.count {
                if let aSection: TableViewSection? = self.tableView(sectionObjectForSection: sectionIdx) {
                    let rowIdx = aSection!.items?.index(of: object! as! NSObject)
                    if nil != rowIdx {
                        ret = IndexPath.init(row: Int(rowIdx!), section: sectionIdx)
                        break
                    }
                }
            }
        }
        return ret
    }
    
    // MARK: - UITableViewDataSource

    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if nil != sections && sections?.count > section {
            let aSection: TableViewSection? = self.tableView(sectionObjectForSection: section);
            if nil != aSection && nil != aSection!.items {
                return aSection!.items!.count
            }
        }
        return 0
    }

    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let aObject: AnyObject? = self.tableView(tableView, objectForRowAtIndexPath: indexPath)
        let aClass: AnyClass! = self.tableView(tableView, cellClassForObject: aObject)
        let identifier: String! = NSStringFromClass(aClass) as String;
        var cell:TableViewCell? = tableView.dequeueReusableCell(withIdentifier: identifier) as? TableViewCell;
        if nil == cell {
            let cellClass = aClass as! TableViewCell.Type
            cell = cellClass.init(style: UITableViewCellStyle.default, reuseIdentifier: identifier)
        }
        cell!.object = aObject

        return cell!
    }

    open func numberOfSections(in tableView: UITableView) -> Int {
        if nil != sections && sections!.count > 0 {
            return sections!.count;
        }
        return 0
    }
    
    open func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let aSection: TableViewSection? = self.tableView(sectionObjectForSection: section);
        return aSection?.headerTitle
    }

    open func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        let aSection: TableViewSection? = self.tableView(sectionObjectForSection: section);
        return aSection?.footerTitle
    }
    
    open func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    open func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    open func tableView(_ tableView: UITableView, canBeginMoveRowAtIndexPath indexPath: IndexPath) -> Bool {
        return false
    }
    
    open func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        var ret = [String]()
        if  nil != sections {
            for sectionIdx in 0..<sections!.count {
                let aSection: TableViewSection? = self.tableView(sectionObjectForSection: sectionIdx);
                if nil != aSection
                    && nil != aSection?.letter
                    && "" != aSection?.letter
                {
                    ret.append((aSection?.letter)!)
                }
            }
        }
        return ret;
    }

    open func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        if  nil != sections {
            for sectionIdx in 0..<sections!.count {
                let aSection: TableViewSection? = self.tableView(sectionObjectForSection: sectionIdx);
                if nil != aSection
                    && title == aSection?.letter
                {
                    return sectionIdx
                }
            }
        }
        return 0;
    }
    
    open func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
    }
    
    open func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        //print("move (\(sourceIndexPath.section),\(sourceIndexPath.row)) ~> (\(destinationIndexPath.section),\(destinationIndexPath.row))")
        let sourceSection: TableViewSection? = self.tableView(sectionObjectForSection: sourceIndexPath.section);
        let destinationSection: TableViewSection? = self.tableView(sectionObjectForSection: destinationIndexPath.section);
        if nil != sourceSection && nil != destinationSection {
            
            let sourceObj: AnyObject! = (sourceSection?.items?[sourceIndexPath.row])!
            let destinationObj: AnyObject! = (destinationSection?.items?[destinationIndexPath.row])!
            
            if sourceSection != destinationSection {
                sourceSection?.items?.remove(at: sourceIndexPath.row)
                destinationSection?.items?.insert(sourceObj as! NSObject, at: destinationIndexPath.row)
            }
            else {
                sourceSection?.items?[sourceIndexPath.row] = destinationObj as! NSObject
                destinationSection?.items?[destinationIndexPath.row] = sourceObj as! NSObject
            }
        }
    }
}
