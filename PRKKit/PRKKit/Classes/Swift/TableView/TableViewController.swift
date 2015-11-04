//
//  TableViewController.swift
//  PRKFocusTime
//
//  Created by dabing on 15/10/21.
//  Copyright © 2015年 passerbycrk. All rights reserved.
//

import UIKit

@objc
public protocol TableViewControllerDelegate: NSObjectProtocol {
    func didSelectObject(object: AnyObject?, atIndexPath indexPath: NSIndexPath)
}


public class TableViewController: UIViewController {
    
    private var theDataSource: TableViewDataSource?
    
    private var theTableView: TableView?
    
    public var tableView: TableView! {
        get {
            if nil == theTableView {
                theTableView = TableView.init(frame: CGRectZero, style: UITableViewStyle.Plain)
            }
            return theTableView
        }
        set {
            if nil != newValue {
                theTableView = newValue
            }
        }
    }
    public var dataSource: TableViewDataSource? {
        get {
            return theDataSource
        }
        set {
            theDataSource = newValue
            tableView.dataSource = theDataSource
        }
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(nibName: nil, bundle: nil)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        tableView.longPressReorderDelegate = self
        tableView.delegate = self
        tableView.dataSource = dataSource
        automaticallyAdjustsScrollViewInsets = false
        view.addSubview(tableView)
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let selectedIndexPath: NSIndexPath? = tableView.indexPathForSelectedRow
        if nil != selectedIndexPath {
            tableView.deselectRowAtIndexPath(selectedIndexPath!, animated: animated)
        }
    }

    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}

extension TableViewController: UITableViewDelegate,TableViewControllerDelegate {
   
    public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if nil != dataSource {
            let obj: AnyObject? = dataSource!.tableView(tableView, objectForRowAtIndexPath: indexPath)
            if nil != obj {
                let aClass: AnyClass? = dataSource!.tableView(tableView, cellClassForObject: obj)
                let cellClass = aClass as! TableViewCell.Type
                return cellClass.tableView(tableView, rowHeightForObject: obj!)
            }
        }
        return 0
    }
    
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if nil != dataSource && self.conformsToProtocol(TableViewControllerDelegate) {
            let obj: AnyObject? = dataSource!.tableView(tableView, objectForRowAtIndexPath: indexPath)
            if nil != obj {
                self.performSelector(Selector("didSelectObject:atIndexPath:"), withObject: obj, withObject: indexPath)
            }
        }
    }
    
    public func didSelectObject(object: AnyObject?, atIndexPath indexPath: NSIndexPath) {
        
    }
}

extension TableViewController : TableViewDelegate {
    /** Called within an animation block when the dragging view is about to show. The default implementation of this method is empty—no need to call `super`. */
    public func tableView(tableView: UITableView, showDraggingView view: UIView, atIndexPath indexPath: NSIndexPath) {
        // Empty implementation, just to simplify overriding (and to show up in code completion).
    }
    
    /** Called within an animation block when the dragging view is about to hide. The default implementation of this method is empty—no need to call `super`. */
    public func tableView(tableView: UITableView, hideDraggingView view: UIView, atIndexPath indexPath: NSIndexPath) {
        // Empty implementation, just to simplify overriding (and to show up in code completion).
    }
    
    //
    // Important: Update your data source after the user reorders a cell.
    //
    public func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        // Empty implementation, just to simplify overriding (and to show up in code completion).
    }
    
    //
    // Optional: Modify the cell (visually) before dragging occurs.
    //
    //    NOTE: Any changes made here should be reverted in `tableView:cellForRowAtIndexPath:`
    //          to avoid accidentally reusing the modifications.
    //
    public func tableView(tableView: UITableView, draggingCell cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return cell
    }
}
