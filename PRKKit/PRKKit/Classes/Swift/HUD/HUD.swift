//
//  HUD.swift
//  PRKUIKit
//
//  Created by dabing on 15/10/29.
//  Copyright © 2015年 passerbycrk. All rights reserved.
//

import Foundation
import JGProgressHUD

public var HUD_ANI_DURATION: Double = 1.5

private var hudArray: [HUD] = [HUD]()

public typealias HUDSettingBlock = (hud: HUD)->Void

public class HUD: NSObject {
    
    public enum HUDLayoutStyle: Int {
        case Default
        case Loading
        case Successed
        case Error
    }
    
    private var theLayoutStyle: HUDLayoutStyle = .Default
    private var theContainerView: UIView?
    private var hudView: JGProgressHUD?
    
    public var layoutStyle: HUDLayoutStyle {
        get {
            return theLayoutStyle
        }
        set {
            if theLayoutStyle != newValue {
                theLayoutStyle = newValue
                if nil != hudView {
                    switch theLayoutStyle {
                    case .Loading:
                        hudView!.indicatorView = JGProgressHUDIndeterminateIndicatorView.init(HUDStyle: hudView!.style)
                    case .Successed:
                        hudView!.indicatorView = JGProgressHUDSuccessIndicatorView()
                    case .Error:
                        hudView!.indicatorView = JGProgressHUDErrorIndicatorView()
                    default:
                        hudView!.indicatorView = nil
                    }
                }
            }
        }
    }
    public var duration: Double = HUD_ANI_DURATION
    public var isIndependent: Bool = false
    public var message: String? {
        get {
            return hudView!.textLabel.text
        }
        set {
            hudView!.textLabel.text = newValue
        }
    }
    public var details: String? {
        get {
            return hudView!.detailTextLabel.text
        }
        set {
            hudView!.detailTextLabel.text = newValue
        }
    }
    public var containerView: UIView? {
        get {
            return theContainerView
        }
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init()
    }
    
    // MARK: - Public Class Method
    
    public class func hudWithView(var view: UIView?) -> HUD {
        if nil == view {
            let app: UIApplication = UIApplication.sharedApplication()
            var window: UIWindow? = app.keyWindow
            if nil == window {
                window = (app.delegate?.window)!
            }
            view = window
        }
        let hud: HUD = HUD.init(coder: NSCoder())!
        hud.hudView = JGProgressHUD.init(style: .Light)
        hud.theContainerView = view
        hud.layoutStyle = .Default
        hud.hudView!.indicatorView = nil
        hud.hudView!.interactionType = .BlockNoTouches
        hud.hudView!.layer.shadowColor = UIColor.whiteColor().CGColor
        hud.hudView!.layer.shadowOffset = CGSizeZero
        hud.hudView!.layer.shadowOpacity = 0.4
        hud.hudView!.layer.shadowRadius = 8.0
        return hud
    }
    
    public class func hudWithWindow(window: UIWindow?) -> HUD {
        return self.hudWithView(window)
    }
    
    public class func hud() -> HUD {
        return self.hudWithView(nil)
    }
    
    public class func showHudSetting(settingCallback: HUDSettingBlock?) -> HUD {
        let hud: HUD = self.hud()
        hud.showHudSetting(settingCallback)
        return hud
    }
    
    public class func clearMessages() -> Void {
        for hud in hudArray {
            hud.hudView!.dismissAnimated(false)
        }
        hudArray.removeAll()
    }
    
    // MARK: - Public Instance Method
    
    public func showHudSetting(settingCallback: HUDSettingBlock?) -> HUD {
        if nil != settingCallback {
            settingCallback!(hud: self)
        }
        p_pushHudView()
        return self
    }
    
    public func showInView(view: UIView!, animated: Bool) {
        hudView!.showInView(view, animated: animated)
        if duration > 0 {
            p_delay(duration, closure: { () -> () in
                // TODO: 判断是否deinit
                self.hudView!.dismissAnimated(true)
            })
        }
    }
    
    // MARK: - Private
    
    private func p_pushHudView() -> Void {
        self.classForCoder.clearMessages()
        if isIndependent {
            self.p_popHudView()
        }
        else {
            hudArray.append(self)
            if hudArray.count == 1 {
                self.p_popHudView()
            }
        }
    }
    
    private func p_popHudView() -> Void {
        if !isIndependent && hudArray.count <= 0 {
            return
        }
        self.showInView(containerView, animated: true)
    }
    
    private func p_delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
}