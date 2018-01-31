//
//  ZRefreshBackStateFooter.swift
//
//  Created by ZhangZZZZ on 16/4/1.
//  Copyright © 2016年 ZhangZZZZ. All rights reserved.
//

import UIKit

open class ZVRefreshBackStateFooter: ZVRefreshBackFooter {
    
    public private(set) lazy var stateLabel: UILabel = .default
    public var labelInsetLeft: CGFloat = 24.0
    private var _stateTitles:[State: String] = [:]
    
    // MARK: Subviews
    
    override open func prepare() {
        super.prepare()
        
        if stateLabel.superview == nil {
            addSubview(stateLabel)
        }
        
        setTitle(localized(string: LocalizedKey.Footer.Back.idle), forState: .idle)
        setTitle(localized(string: LocalizedKey.Footer.Back.pulling), forState: .pulling)
        setTitle(localized(string: LocalizedKey.Footer.Back.refreshing), forState: .refreshing)
        setTitle(localized(string: LocalizedKey.Footer.Back.noMoreData), forState: .noMoreData)
    }
    
    override open func placeSubViews() {
        super.placeSubViews()
        if stateLabel.constraints.count > 0 { return }
        stateLabel.frame = bounds
    }
    
    // MARK: Update State
    
    open override func update(refreshState newValue: State) {
        guard checkState(newValue).isIdenticalState == false else { return }
        super.update(refreshState: newValue)
        
        stateLabel.text = _stateTitles[newValue]
    }
}

// MARK: - Override

extension ZVRefreshBackStateFooter {
    
    override open var tintColor: UIColor! {
        didSet {
            stateLabel.textColor = tintColor
        }
    }
}

// MARK: - Public

extension ZVRefreshBackStateFooter {
    
    public func setTitle(_ title: String, forState state: State) {
        _stateTitles.updateValue(title, forKey: state)
        stateLabel.text = _stateTitles[refreshState]
    }
}

