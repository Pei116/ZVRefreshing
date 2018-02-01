//
//  ZRefreshAutoFooter.swift
//
//  Created by ZhangZZZZ on 16/3/31.
//  Copyright © 2016年 ZhangZZZZ. All rights reserved.
//

import UIKit

open class ZVRefreshAutoFooter: ZVRefreshFooter {

    // MARK: - Property
    
    public var isAutomaticallyRefresh: Bool = true
    private var _triggerAutomaticallyRefreshPercent: CGFloat = 1.0
    
    // MARK: - Do On
    
    open override func doOnIdle(with oldState: ZVRefreshComponent.State) {
        super.doOnIdle(with: oldState)
        
        if oldState == .refreshing { endRefreshingCompletionHandler?() }
    }

    open override func doOnRefreshing(with oldState: ZVRefreshComponent.State) {
        super.doOnRefreshing(with: oldState)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
            self.executeRefreshCallback()
        })
    }
    
    open override func doOnNoMoreData(with oldState: State) {
        super.doOnNoMoreData(with: oldState)
        
        if oldState == .refreshing { endRefreshingCompletionHandler?() }
    }
    
    // MARK: - Observers

    override open func scrollView(_ scrollView: UIScrollView, contentSizeDidChanged value: [NSKeyValueChangeKey : Any]?) {
        super.scrollView(scrollView, contentSizeDidChanged: value)
        
        frame.origin.y = scrollView.contentSize.height
    }
    
    override open func scrollView(_ scrollView: UIScrollView, contentOffsetDidChanged value: [NSKeyValueChangeKey : Any]?) {
        
        guard refreshState == .idle, isAutomaticallyRefresh, frame.origin.y != 0 else { return }
        
        super.scrollView(scrollView, contentSizeDidChanged: value)
        
        if scrollView.contentInset.top + scrollView.contentSize.height > scrollView.frame.size.height {
            if scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.frame.size.height + frame.size.height * _triggerAutomaticallyRefreshPercent + scrollView.contentInset.bottom - frame.size.height) {
                let old = (value?[.oldKey] as? NSValue)?.cgPointValue
                let new = (value?[.newKey] as? NSValue)?.cgPointValue
                if old != nil && new != nil && new!.y > old!.y {
                    beginRefreshing()
                }
            }
        }
    }
    
    override open func panGestureRecognizer(_ panGestureRecognizer: UIPanGestureRecognizer, stateValueChanged value: [NSKeyValueChangeKey : Any]?, for scrollView: UIScrollView) {
        
        super.panGestureRecognizer(panGestureRecognizer, stateValueChanged: value, for: scrollView)
        
        guard refreshState == .idle else { return }

        if scrollView.panGestureRecognizer.state == .ended {
            if scrollView.contentInset.top + scrollView.contentSize.height <= scrollView.frame.size.height {
                if scrollView.contentOffset.y >= -scrollView.contentInset.top {
                    beginRefreshing()
                }
            } else {
                if scrollView.contentOffset.y >= (scrollView.contentSize.height + scrollView.contentInset.bottom - scrollView.frame.size.height) {
                    beginRefreshing()
                }
            }
        }
    }
}

// MARK: - System Override

extension ZVRefreshAutoFooter {
    
    override open func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        
        if scrollView == nil { return }
        if newSuperview == nil {
            if isHidden == false {
                scrollView?.contentInset.bottom -= frame.size.height
            }
        } else {
            if isHidden == false {
                scrollView?.contentInset.bottom += frame.size.height
            }
            frame.origin.y = scrollView!.contentSize.height
        }
    }
    
    override open var isHidden: Bool {
        get {
            return super.isHidden
        }
        set {
            guard let scrollView = scrollView else { return }
            
            let isHidden = self.isHidden
            super.isHidden = newValue
            if isHidden {
                if !newValue {
                    scrollView.contentInset.bottom += frame.size.height
                    frame.origin.y = scrollView.contentSize.height
                }
            } else {
                if newValue {
                    refreshState = .idle
                    scrollView.contentInset.bottom -= frame.size.height
                }
            }
        }
    }
}

