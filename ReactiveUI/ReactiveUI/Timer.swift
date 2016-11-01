//
//  Timer.swift
//  ReactiveUI
//
//  Created by Zhixuan Lai on 2/2/15.
//  Copyright (c) 2015 Zhixuan Lai. All rights reserved.
//

import UIKit

public extension Timer {
    // Big thanks to https://github.com/ashfurrow/Haste
    class func scheduledTimer(timeInterval: TimeInterval, repeats: Bool, action: @escaping () -> ()) -> Timer {
        return scheduledTimer(timeInterval: timeInterval, target: self, selector: "_timerDidFire:", userInfo: TimerProxyTarget(action: action), repeats: repeats)
    }
}

internal extension Timer {
    class func _timerDidFire(timer: Timer) {
        if let proxyTarget = timer.userInfo as? TimerProxyTarget {
            proxyTarget.performAction(timer)
        }
    }

    class TimerProxyTarget : ProxyTarget {
        var action: () -> ()

        init(action: @escaping () -> ()) {
            self.action = action
        }

        func performAction(_ control: Timer) {
            action()
        }
    }
    
    var proxyTarget: TimerProxyTarget {
        get {
            if let targets = objc_getAssociatedObject(self, &ProxyTargetsKey) as? TimerProxyTarget {
                return targets
            } else {
                return setProxyTargets(TimerProxyTarget(action: {_ in}))
            }
        }
        set {
            setProxyTargets(newValue)
        }
    }
    
    private func setProxyTargets(_ newValue: TimerProxyTarget) -> TimerProxyTarget {
        objc_setAssociatedObject(self, &ProxyTargetsKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        return newValue
    }
}
