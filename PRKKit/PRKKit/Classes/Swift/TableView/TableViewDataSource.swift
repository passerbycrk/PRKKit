//
//  TableViewDataSource.swift
//  PRKFocusTime
//
//  Created by dabing on 15/10/21.
//  Copyright © 2015年 passerbycrk. All rights reserved.
//

import Foundation
import UIKit

@objc
public protocol TableViewCellProtocol : NSObjectProtocol {
    // @required
    var object: AnyObject? { get set }
}

@objc
public protocol TableViewDataSourceProtocol : UITableViewDataSource {
    // @required
    func tableView(tableView: UITableView, cellClassForObject object: AnyObject? ) -> AnyClass!
    // @optional
    optional func tableView(tableView: UITableView, indexPathForObject object: AnyObject? ) -> NSIndexPath?
    optional func tableView(tableView: UITableView, canBeginMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool
    optional func tableView(tableView: UITableView, objectForRowAtIndexPath indexPath: NSIndexPath) -> AnyObject?
}

public class TableViewSection: NSObject {
    public var items: [NSObject]? = [NSObject]()
    public var letter: String?
    public var headerTitle: String?
    public var footerTitle: String?
    public var userInfo: AnyObject?
}

public class TableViewDataSource: NSObject, TableViewDataSourceProtocol {
    // 两种写法
//    var sections: Array<TableViewSection>? = Array<TableViewSection>()
    public var sections: [TableViewSection]? = [TableViewSection]()
    
    public var firstItems: [NSObject]? {
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
    public func tableView(tableView: UITableView, cellClassForObject object: AnyObject? ) -> AnyClass! {
        return TableViewCell.classForCoder()
    }
    
    public func tableView(sectionObjectForSection section: Int ) -> TableViewSection? {
        var ret: TableViewSection?
        if nil != sections && sections?.count > section {
            //ret = sections?.objectAtIndex(section) as? TableViewSection;
            ret = sections![section]
        }
        return ret
    }
    
    public func tableView(tableView: UITableView, objectForRowAtIndexPath indexPath: NSIndexPath) -> AnyObject? {
        var ret: AnyObject?
        let aSection: TableViewSection? = self.tableView(sectionObjectForSection: indexPath.section);
        if nil != aSection && aSection!.items?.count > indexPath.row {
            ret = aSection!.items?[indexPath.row]
        }
        return ret
    }
    
    public func tableView(tableView: UITableView, indexPathForObject object: AnyObject? ) -> NSIndexPath? {
        var ret: NSIndexPath?
        if nil != object {
            for sectionIdx in 0..<sections!.count {
                if let aSection: TableViewSection? = self.tableView(sectionObjectForSection: sectionIdx) {
                    let rowIdx = aSection!.items?.indexOf(object! as! NSObject)
                    if nil != rowIdx {
                        ret = NSIndexPath.init(forRow: Int(rowIdx!), inSection: sectionIdx)
                        break
                    }
                }
            }
        }
        return ret
    }
    
    // MARK: - UITableViewDataSource

    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if nil != sections && sections?.count > section {
            let aSection: TableViewSection? = self.tableView(sectionObjectForSection: section);
            if nil != aSection && nil != aSection!.items {
                return aSection!.items!.count
            }
        }
        return 0
    }

    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let aObject: AnyObject? = self.tableView(tableView, objectForRowAtIndexPath: indexPath)
        let aClass: AnyClass! = self.tableView(tableView, cellClassForObject: aObject)
        let identifier: String! = NSStringFromClass(aClass) as String;
        var cell:TableViewCell? = tableView.dequeueReusableCellWithIdentifier(identifier) as? TableViewCell;
        if nil == cell {
            let cellClass = aClass as! TableViewCell.Type
            cell = cellClass.init(style: UITableViewCellStyle.Default, reuseIdentifier: identifier)
        }
        cell!.object = aObject

        return cell!
    }

    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if nil != sections && sections!.count > 0 {
            return sections!.count;
        }
        return 0
    }
    
    public func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let aSection: TableViewSection? = self.tableView(sectionObjectForSection: section);
        return aSection?.headerTitle
    }

    public func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        let aSection: TableViewSection? = self.tableView(sectionObjectForSection: section);
        return aSection?.footerTitle
    }
    
    public func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    public func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    public func tableView(tableView: UITableView, canBeginMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    public func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
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

    public func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
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
    
    public func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    public func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        //print("move (\(sourceIndexPath.section),\(sourceIndexPath.row)) ~> (\(destinationIndexPath.section),\(destinationIndexPath.row))")
        let sourceSection: TableViewSection? = self.tableView(sectionObjectForSection: sourceIndexPath.section);
        let destinationSection: TableViewSection? = self.tableView(sectionObjectForSection: destinationIndexPath.section);
        if nil != sourceSection && nil != destinationSection {
            
            let sourceObj: AnyObject! = (sourceSection?.items?[sourceIndexPath.row])!
            let destinationObj: AnyObject! = (destinationSection?.items?[destinationIndexPath.row])!
            
            if sourceSection != destinationSection {
                sourceSection?.items?.removeAtIndex(sourceIndexPath.row)
                destinationSection?.items?.insert(sourceObj as! NSObject, atIndex: destinationIndexPath.row)
            }
            else {
                sourceSection?.items?[sourceIndexPath.row] = destinationObj as! NSObject
                destinationSection?.items?[destinationIndexPath.row] = sourceObj as! NSObject
            }
        }
    }
}