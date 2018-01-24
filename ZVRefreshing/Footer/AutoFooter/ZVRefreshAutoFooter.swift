//
//  ZRefreshAutoFooter.swift
//
//  Created by ZhangZZZZ on 16/3/31.
//  Copyright © 2016年 ZhangZZZZ. All rights reserved.
//

import UIKit

open class ZVRefreshAutoFooter: ZVRefreshFooter {

    public var isAutomaticallyRefresh: Bool = true
    private var _triggerAutomaticallyRefreshPercent: CGFloat = 1.0
    
    // MARK: Observers

    open override func scrollView(_ scrollView: UIScrollView, contentSizeDidChanged value: [NSKeyValueChangeKey : Any]?) {
        super.scrollView(scrollView, contentSizeDidChanged: value)
        
        frame.origin.y = scrollView.contentSize.height
    }
    
    open override func scrollView(_ scrollView: UIScrollView, contentOffsetDidChanged value: [NSKeyValueChangeKey : Any]?) {
        
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
    
    open override func panGestureRecognizer(_ panGestureRecognizer: UIPanGestureRecognizer, stateValueChanged value: [NSKeyValueChangeKey : Any]?, for scrollView: UIScrollView) {
        
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
    
    // MARK: Getter & Setter
    
    open override var refreshState: State {
        get {
            return super.refreshState
        }
        set {
            _set(refreshState: newValue)
        }
    }
    
}

// MARK: - Override

extension ZVRefreshAutoFooter {
    
    open override func willMove(toSuperview newSuperview: UIView?) {
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
    
    open override var isHidden: Bool {
        get {
            return super.isHidden
        }
        set {
            _set(isHidden: newValue)
        }
    }
}


private extension ZVRefreshAutoFooter {
    
    func _set(isHidden newValue: Bool) {
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
    
    func _set(refreshState newValue: State) {
        
        let checked = checkState(newValue)
        guard checked.result == false else { return }
        super.refreshState = newValue
        
        if newValue == .refreshing {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
                self.executeRefreshCallback()
            })
        } else if refreshState == .noMoreData || refreshState == .idle {
            if checked.oldState == .refreshing {
                endRefreshingCompletionHandler?()
            }
        }
    }
}