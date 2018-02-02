//
//  ZRefreshStateHeader.swift
//
//  Created by ZhangZZZZ on 16/3/30.
//  Copyright © 2016年 ZhangZZZZ. All rights reserved.
//

import UIKit

open class ZVRefreshStateHeader: ZVRefreshHeader {
    
    public struct LastUpdatedTimeKey {
        static var `default`: String { return "com.zevwings.refreshing.lastUpdateTime" }
    }
    
    // MARK: - Property
    
    public var labelInsetLeft: CGFloat = 24.0
    public var stateTitles: [State : String]?
    public private(set) var stateLabel: UILabel?
    public private(set) var lastUpdatedTimeLabel: UILabel?

    // MARK: LastUpdateTime

    var lastUpdatedTime: Date? {
        return UserDefaults.standard.object(forKey: lastUpdatedTimeKey) as? Date
    }
    
    public var lastUpdatedTimeKey: String! {
        didSet {
            _didSetLastUpdatedTimeKey(lastUpdatedTimeKey)
        }
    }

    public var lastUpdatedTimeLabelText:((_ date: Date?)->(String))? {
        didSet {
            _didSetLastUpdatedTimeKey(lastUpdatedTimeKey)
        }
    }
    
    // MARK: - Subviews
    
    override open func prepare() {
        super.prepare()
        
        if stateLabel == nil {
            stateLabel = .default
            addSubview(stateLabel!)
        }
        
        if lastUpdatedTimeLabel == nil {
            lastUpdatedTimeLabel = .default
            addSubview(lastUpdatedTimeLabel!)
            lastUpdatedTimeKey = LastUpdatedTimeKey.default
        }
        
        setTitle(localized(string: LocalizedKey.Header.idle), for: .idle)
        setTitle(localized(string: LocalizedKey.Header.pulling), for: .pulling)
        setTitle(localized(string: LocalizedKey.Header.refreshing), for: .refreshing)
    }
    
    override open func placeSubViews() {
        super.placeSubViews()
        
        guard let stateLabel = stateLabel, stateLabel.isHidden == false else { return }
    
        if let lastUpdatedTimeLabel = lastUpdatedTimeLabel, !lastUpdatedTimeLabel.isHidden {

            let statusLabelH = frame.size.height * 0.5
            
            if stateLabel.constraints.count == 0 {
                stateLabel.frame.origin.x = 0
                stateLabel.frame.origin.y = 0
                stateLabel.frame.size.width = frame.width
                stateLabel.frame.size.height = statusLabelH
            }
            
            if lastUpdatedTimeLabel.constraints.count == 0 {
                lastUpdatedTimeLabel.frame.origin.x = 0
                lastUpdatedTimeLabel.frame.origin.y = statusLabelH
                lastUpdatedTimeLabel.frame.size.width = frame.width
                lastUpdatedTimeLabel.frame.size.height = frame.height - lastUpdatedTimeLabel.frame.origin.y
            }
        } else {
            if stateLabel.constraints.count == 0 { stateLabel.frame = bounds }
        }
    }
    
    // MARK: - Do On State
    
    open override func doOnAnyState(with oldState: ZVRefreshComponent.State) {
        super.doOnAnyState(with: oldState)
        
        setCurrentStateTitle()
        _didSetLastUpdatedTimeKey(lastUpdatedTimeKey)
    }
    
    open override func doOnIdle(with oldState: ZVRefreshComponent.State) {
        super.doOnIdle(with: oldState)
        
        guard oldState == .refreshing else { return }
        
        UserDefaults.standard.set(Date(), forKey: lastUpdatedTimeKey)
        UserDefaults.standard.synchronize()
    }
}

// MARK: - Override

extension ZVRefreshStateHeader {
    
    override open var tintColor: UIColor! {
        didSet {
            lastUpdatedTimeLabel?.textColor = tintColor
            stateLabel?.textColor = tintColor
        }
    }
}

// MARK: - Private

private extension ZVRefreshStateHeader {
    
    func _didSetLastUpdatedTimeKey(_ newValue: String) {
        
        guard lastUpdatedTimeLabelText == nil else {
            lastUpdatedTimeLabel?.text = lastUpdatedTimeLabelText?(lastUpdatedTime)
            return
        }
        
        if let lastUpdatedTime = lastUpdatedTime {
            
            let components: Set<Calendar.Component> = [.year, .month, .day, .hour, .minute, .second]
            
            let calendar = Calendar(identifier: .gregorian)
            let cmp1 = calendar.dateComponents(components, from: lastUpdatedTime)
            let cmp2 = calendar.dateComponents(components, from: lastUpdatedTime)
            let formatter = DateFormatter()
            var isToday = false
            if cmp1.day == cmp2.day {
                formatter.dateFormat = "HH:mm"
                isToday = true
            } else if cmp1.year == cmp2.year {
                formatter.dateFormat = "MM-dd HH:mm"
            } else {
                formatter.dateFormat = "yyyy-MM-dd HH:mm"
            }
            let timeString = formatter.string(from: lastUpdatedTime)
            
            lastUpdatedTimeLabel?.text = String(format: "%@ %@ %@",
                                                localized(string: LocalizedKey.State.lastUpdatedTime),
                                                isToday ? localized(string: LocalizedKey.State.dateToday) : "",
                                                timeString)
        } else {
            lastUpdatedTimeLabel?.text = String(format: "%@ %@",
                                                localized(string: LocalizedKey.State.lastUpdatedTime),
                                                localized(string: LocalizedKey.State.noLastTime))
        }
    }
}

// MARK: - ZVRefreshStateComponent

extension ZVRefreshStateHeader: ZVRefreshStateComponent {}
