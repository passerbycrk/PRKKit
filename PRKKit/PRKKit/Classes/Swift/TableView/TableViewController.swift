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
    func didSelectObject(_ object: AnyObject?, atIndexPath indexPath: IndexPath)
}


open class TableViewController: UIViewController {
    
    fileprivate var theDataSource: TableViewDataSource?
    
    fileprivate var theTableView: TableView?
    
    open var tableView: TableView! {
        get {
            if nil == theTableView {
                theTableView = TableView.init(frame: CGRect.zero, style: UITableViewStyle.plain)
            }
            return theTableView
        }
        set {
            if nil != newValue {
                theTableView = newValue
            }
        }
    }
    open var dataSource: TableViewDataSource? {
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
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        tableView.longPressReorderDelegate = self
        tableView.delegate = self
        tableView.dataSource = dataSource
        automaticallyAdjustsScrollViewInsets = false
        view.addSubview(tableView)
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let selectedIndexPath: IndexPath? = tableView.indexPathForSelectedRow
        if nil != selectedIndexPath {
            tableView.deselectRow(at: selectedIndexPath!, animated: animated)
        }
    }

    open override func didReceiveMemoryWarning() {
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
   
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
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
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if nil != dataSource && self.conforms(to: TableViewControllerDelegate) {
            let obj: AnyObject? = dataSource!.tableView(tableView, objectForRowAtIndexPath: indexPath)
            if nil != obj {
                self.perform(#selector(TableViewControllerDelegate.didSelectObject(_:atIndexPath:)), with: obj, with: indexPath)
            }
        }
    }
    
    public func didSelectObject(_ object: AnyObject?, atIndexPath indexPath: IndexPath) {
        
    }
}

extension TableViewController : TableViewDelegate {
    /** Called within an animation block when the dragging view is about to show. The default implementation of this method is empty—no need to call `super`. */
    public func tableView(_ tableView: UITableView, showDraggingView view: UIView, atIndexPath indexPath: IndexPath) {
        // Empty implementation, just to simplify overriding (and to show up in code completion).
    }
    
    /** Called within an animation block when the dragging view is about to hide. The default implementation of this method is empty—no need to call `super`. */
    public func tableView(_ tableView: UITableView, hideDraggingView view: UIView, atIndexPath indexPath: IndexPath) {
        // Empty implementation, just to simplify overriding (and to show up in code completion).
    }
    
    //
    // Important: Update your data source after the user reorders a cell.
    //
    public func tableView(_ tableView: UITableView, moveRowAtIndexPath sourceIndexPath: IndexPath, toIndexPath destinationIndexPath: IndexPath) {
        // Empty implementation, just to simplify overriding (and to show up in code completion).
    }
    
    //
    // Optional: Modify the cell (visually) before dragging occurs.
    //
    //    NOTE: Any changes made here should be reverted in `tableView:cellForRowAtIndexPath:`
    //          to avoid accidentally reusing the modifications.
    //
    public func tableView(_ tableView: UITableView, draggingCell cell: UITableViewCell, atIndexPath indexPath: IndexPath) -> UITableViewCell {
        return cell
    }
}
