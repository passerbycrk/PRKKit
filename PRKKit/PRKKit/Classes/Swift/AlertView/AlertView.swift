//
//  AlertView.swift
//  PRKUIKit
//
//  Created by dabing on 15/10/29.
//  Copyright © 2015年 passerbycrk. All rights reserved.
//

import Foundation
//import PRKFoundation

public typealias AlertViewBlock = (_ index: Int?, _ title: String?) -> Void

private var alertViewArray: [AlertView] = [AlertView]()

open class AlertView: NSObject {
    
    fileprivate var btnTitles: [String] = [String]()
    fileprivate var callbacks: [AlertViewBlock] = [AlertViewBlock]()
    fileprivate var theTitle: String?
    fileprivate var theMessage: String?
    fileprivate var theCancelButtonIdx: Int?
    open var title: String? {
        get {
            return theTitle
        }
        set {
            theTitle = newValue
        }
    }
    open var message: String? {
        get {
            return theMessage
        }
        set {
            theMessage = newValue
        }
    }
    open var cancelButtonIdx: Int? {
        get {
            return theCancelButtonIdx
        }
    }

    deinit {
        p_cleanup()
    }
    
    override init() {
        super.init()
        alertViewArray.append(self)
    }
    
    public init(title: String?, message: String) {
        super.init()
        self.title = title
        self.message = message
        alertViewArray.append(self)
    }
    
    public func addButton(_ title: String?,callback: AlertViewBlock?) -> Int? {
        var callback = callback
        if nil == title {
            return nil
        }
        
        if (nil == callback) {
            /* // 完整参数
            callback = {
                (index: Int!, title: String!) -> Void in
            }
            // */
            
            // 简写
            callback = {
                (index,title) in
            }
            
            /* // 带有weak引用
            callback = {
                [weak self]
                (index,title) in
                if let strongSelf = self {
                    
                }
            }
            // */
        }
        callbacks.append(callback!)
        btnTitles.append(title!)
        return Int(btnTitles.count-1);
    }
    
    open func addButton(_ title: String?) -> Int? {
        return addButton(title, callback: nil)
    }
    
    open func addCancelButton(_ title: String?, callback: AlertViewBlock?) -> Int? {
        theCancelButtonIdx = addButton(title, callback: callback)
        return theCancelButtonIdx
    }
    
    open func addCancelButton(_ title: String?) -> Int? {
        return addCancelButton(title, callback: nil)
    }
    
    open func show() -> Bool {
        if #available(iOS 8.0, *) {
//        if UIDevice.currentDevice().systemVersionNotLowerThan("8") {
            p_UIAlertControllerShow()
        }
        else {
            p_UIAlertViewShow()
        }
        return false
    }
    
    fileprivate func p_cleanup() -> Void {
        let idx: Int? = alertViewArray.index(of: self)
        if nil != idx {
            alertViewArray.remove(at: idx!)
        }
    }
    
    @available (iOS, deprecated: 8.0)
    fileprivate func p_UIAlertViewShow() -> Void {
        let alertView: UIAlertView = UIAlertView.init(title: title!, message: message!, delegate: self, cancelButtonTitle: nil)
        for idx in 0..<self.btnTitles.count {
            let title: String = btnTitles[idx]
            if nil != cancelButtonIdx && cancelButtonIdx == idx {
                alertView.cancelButtonIndex = self.cancelButtonIdx!
            }
            alertView.addButton(withTitle: title)
        }
        alertView.show()
    }
    
    @available (iOS 8.0, *)
    fileprivate func p_UIAlertControllerShow() -> Void {
        let controller: UIAlertController = UIAlertController.init(title: title, message: message, preferredStyle: .alert)

        for idx in 0..<self.btnTitles.count {
            let title: String = btnTitles[idx]
            var style: UIAlertActionStyle = .default
            if cancelButtonIdx == idx {
                style = .cancel
            }
            let action: UIAlertAction = UIAlertAction.init(title: title, style: style, handler: { (theAction) -> Void in
                let aCallback: AlertViewBlock! = self.callbacks[idx]
                DispatchQueue.main.async { () -> Void in
                    aCallback(index: idx, title: theAction.title)
                    self.p_cleanup()
                }
            })
            controller.addAction(action)
        }
        // TODO: 需要判断下是否存在
//        let topMostVC: UIViewController! = UIApplication.sharedApplication().keyWindow?.rootViewController?.topmostViewController()
//        topMostVC.presentViewController(controller, animated: true, completion: nil)
    }
}

extension AlertView: UIAlertViewDelegate {
    
    public func alertViewCancel(_ alertView: UIAlertView) {
        self.alertView(alertView, didDismissWithButtonIndex: self.cancelButtonIdx!)
    }
    
    public func alertView(_ alertView: UIAlertView, didDismissWithButtonIndex buttonIndex: Int) {
        let aCallback: AlertViewBlock! = callbacks[buttonIndex]
        let title: String! = btnTitles[buttonIndex]
        DispatchQueue.main.async { () -> Void in
            aCallback(index: buttonIndex, title: title)
            self.p_cleanup()
        }
    }
}
