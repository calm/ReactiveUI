//
//  UIControl.swift
//  ReactiveControl
//
//  Created by Zhixuan Lai on 1/8/15.
//  Copyright (c) 2015 Zhixuan Lai. All rights reserved.
//

import UIKit

public extension UIControl {
    convenience init(for controlEvents: UIControlEvents, action: @escaping () -> ()) {
        self.init()
        addControlEvents(controlEvents, action: action)
    }

    func addControlEvents(_ controlEvents: UIControlEvents, action: @escaping () -> ()) {
        removeAction(for: controlEvents)

        let proxyTarget = ControlProxyTarget(action: action)
        let key = self.key(for: controlEvents)
        proxyTargets[key] = proxyTarget
        addTarget(proxyTarget, action: ControlProxyTarget.actionSelector(), for: controlEvents)
    }

    func removeAction(for controlEvents: UIControlEvents) {
        let key = self.key(for: controlEvents)
        guard let proxyTarget = proxyTargets[key] else { return }
        removeTarget(proxyTarget, action: ControlProxyTarget.actionSelector(), for: controlEvents)
        proxyTargets.removeValue(forKey: key)
    }

    func actionForControlEvent(controlEvents: UIControlEvents) -> (() -> ())? {
        let key = self.key(for: controlEvents)
        return proxyTargets[key]?.action
    }
    
    var actions: [() -> ()] {
        return [ControlProxyTarget](proxyTargets.values).map({$0.action})
    }
}

internal extension UIControl {
    typealias ControlProxyTargets = [String: ControlProxyTarget]
    
    class ControlProxyTarget : ProxyTarget {
        var action: () -> ()
        
        init(action: @escaping () -> ()) {
            self.action = action
        }
        
        func performAction(_ control: UIControl) {
            action()
        }
    }
    
    func key(for controlEvents: UIControlEvents) -> String {
        return "calm.ReactiveUI.UIControlEvents.key.\(controlEvents.rawValue)"
    }

    var proxyTargets: ControlProxyTargets {
        get {
            if let targets = objc_getAssociatedObject(self, &ProxyTargetsKey) as? ControlProxyTargets {
                return targets
            } else {
                return setProxyTargets(ControlProxyTargets())
            }
        }
        set {
            setProxyTargets(newValue)
        }
    }
    
    private func setProxyTargets(_ newValue: ControlProxyTargets) -> ControlProxyTargets {
        objc_setAssociatedObject(self, &ProxyTargetsKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        return newValue
    }
    
}
