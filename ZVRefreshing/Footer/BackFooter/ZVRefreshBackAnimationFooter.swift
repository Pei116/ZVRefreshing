//
//  ZRefreshBackAnimationFooter.swift
//
//  Created by ZhangZZZZ on 16/4/1.
//  Copyright © 2016年 ZhangZZZZ. All rights reserved.
//

import UIKit

open class ZVRefreshBackAnimationFooter: ZVRefreshBackStateFooter {

    private(set) lazy var  animationView: UIImageView = {
        let animationView = UIImageView()
        animationView.backgroundColor = .clear
        return animationView
    }()
    
    private var _stateImages: [State: [UIImage]] = [:]
    private var _stateDurations: [State: TimeInterval] = [:]
    
    // MARK: Subviews
    
    open override func prepare() {
        super.prepare()
        if animationView.superview == nil {
            addSubview(animationView)
        }
    }
    
    open override func placeSubViews() {
        super.placeSubViews()
        if animationView.constraints.count > 0 { return }
        animationView.frame = bounds
        if stateLabel.isHidden {
            animationView.contentMode = .center
        } else {
            animationView.contentMode = .right
            animationView.frame.size.width = frame.size.width * 0.5 - 90
        }
    }
    
    // MARK: Getter & Setter
    
    open override var pullingPercent: CGFloat {
        didSet {
            _didSet(pullingPercent: pullingPercent)
        }
    }
    
    open override var refreshState: State {
        get {
            return super.refreshState
        }
        set {
            _set(refreshState: newValue)
        }
    }

}

// MARK: - Public

extension ZVRefreshBackAnimationFooter {
    
    public func setImages(_ images: [UIImage], state: State){
        setImages(images, duration: Double(images.count) * 0.1, state: state)
    }
    
    public func setImages(_ images: [UIImage], duration: TimeInterval, state: State){
        if images.count == 0 { return }
        
        _stateImages.updateValue(images, forKey: state)
        _stateDurations.updateValue(duration, forKey: state)
        if let image = images.first {
            if image.size.height > frame.size.height {
                frame.size.height = image.size.height
            }
        }
    }
}

// MARK: - Private

private extension ZVRefreshBackAnimationFooter {
    
    func _set(refreshState newValue: State) {
        
        guard checkState(newValue).result == false else { return }

        super.refreshState = newValue
        
        if newValue == .pulling || newValue == .refreshing {
            
            guard let images = _stateImages[newValue], images.count > 0 else { return }
            animationView.stopAnimating()
            
            if images.count == 1 {
                animationView.image = images.last
            } else {
                animationView.animationImages = images
                animationView.animationDuration = _stateDurations[newValue] ?? 0
                animationView.startAnimating()
            }
        } else if newValue == .idle {
            animationView.stopAnimating()
        }
    }
    
    func _didSet(pullingPercent newValue: CGFloat) {
        
        let imgs = _stateImages[.idle] ?? []
        if refreshState != .idle || imgs.count == 0 { return }
        animationView.stopAnimating()
        var index = Int(CGFloat(imgs.count) * newValue)
        if index >= imgs.count {
            index = imgs.count - 1
        }
        animationView.image = imgs[index]
    }
}