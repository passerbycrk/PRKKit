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

public typealias HUDSettingBlock = (_ hud: HUD)->Void

open class HUD: NSObject {
    
    public enum HUDLayoutStyle: Int {
        case `default`
        case loading
        case successed
        case error
    }
    
    fileprivate var theLayoutStyle: HUDLayoutStyle = .default
    fileprivate var theContainerView: UIView?
    fileprivate var hudView: JGProgressHUD?
    
    open var layoutStyle: HUDLayoutStyle {
        get {
            return theLayoutStyle
        }
        set {
            if theLayoutStyle != newValue {
                theLayoutStyle = newValue
                if nil != hudView {
                    switch theLayoutStyle {
                    case .loading:
                        hudView!.indicatorView = JGProgressHUDIndeterminateIndicatorView.init(HUDStyle: hudView!.style)
                    case .successed:
                        hudView!.indicatorView = JGProgressHUDSuccessIndicatorView()
                    case .error:
                        hudView!.indicatorView = JGProgressHUDErrorIndicatorView()
                    default:
                        hudView!.indicatorView = nil
                    }
                }
            }
        }
    }
    open var duration: Double = HUD_ANI_DURATION
    open var isIndependent: Bool = false
    open var message: String? {
        get {
            return hudView!.textLabel.text
        }
        set {
            hudView!.textLabel.text = newValue
        }
    }
    open var details: String? {
        get {
            return hudView!.detailTextLabel.text
        }
        set {
            hudView!.detailTextLabel.text = newValue
        }
    }
    open var containerView: UIView? {
        get {
            return theContainerView
        }
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init()
    }
    
    // MARK: - Public Class Method
    
    public class func hudWithView(_ view: UIView?) -> HUD {
        var view = view
        if nil == view {
            let app: UIApplication = UIApplication.shared
            var window: UIWindow? = app.keyWindow
            if nil == window {
                window = (app.delegate?.window)!
            }
            view = window
        }
        let hud: HUD = HUD.init(coder: NSCoder())!
        hud.hudView = JGProgressHUD.init(style: .Light)
        hud.theContainerView = view
        hud.layoutStyle = .default
        hud.hudView!.indicatorView = nil
        hud.hudView!.interactionType = .BlockNoTouches
        hud.hudView!.layer.shadowColor = UIColor.whiteColor().CGColor
        hud.hudView!.layer.shadowOffset = CGSize.zero
        hud.hudView!.layer.shadowOpacity = 0.4
        hud.hudView!.layer.shadowRadius = 8.0
        return hud
    }
    
    open class func hudWithWindow(_ window: UIWindow?) -> HUD {
        return self.hudWithView(window)
    }
    
    open class func hud() -> HUD {
        return self.hudWithView(nil)
    }
    
    open class func showHudSetting(_ settingCallback: HUDSettingBlock?) -> HUD {
        let hud: HUD = self.hud()
        hud.showHudSetting(settingCallback)
        return hud
    }
    
    open class func clearMessages() -> Void {
        for hud in hudArray {
            hud.hudView!.dismissAnimated(false)
        }
        hudArray.removeAll()
    }
    
    // MARK: - Public Instance Method
    
    open func showHudSetting(_ settingCallback: HUDSettingBlock?) -> HUD {
        if nil != settingCallback {
            settingCallback!(self)
        }
        p_pushHudView()
        return self
    }
    
    open func showInView(_ view: UIView!, animated: Bool) {
        hudView!.showInView(view, animated: animated)
        if duration > 0 {
            p_delay(duration, closure: { () -> () in
                // TODO: 判断是否deinit
                self.hudView!.dismissAnimated(true)
            })
        }
    }
    
    // MARK: - Private
    
    fileprivate func p_pushHudView() -> Void {
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
    
    fileprivate func p_popHudView() -> Void {
        if !isIndependent && hudArray.count <= 0 {
            return
        }
        self.showInView(containerView, animated: true)
    }
    
    fileprivate func p_delay(_ delay:Double, closure:@escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }
    
}
