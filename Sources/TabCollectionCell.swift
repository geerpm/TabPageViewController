//
//  TabCollectionCell.swift
//  TabPageViewController
//
//  Created by EndouMari on 2016/02/24.
//  Copyright © 2016年 EndouMari. All rights reserved.
//

import UIKit

class TabCollectionCell: UICollectionViewCell {

    var tabItemButtonPressedBlock: (() -> Void)?
    var option: TabPageOption = TabPageOption() {
        didSet {
            currentBarViewHeightConstraint.constant = option.currentBarHeight
        }
    }
    var item: String = "" {
        didSet {
            itemLabel.text = item
            itemLabel.invalidateIntrinsicContentSize()
            invalidateIntrinsicContentSize()
        }
    }
    var isCurrent: Bool = false {
        didSet {
            currentBarView.isHidden = !isCurrent
            if isCurrent {
                highlightTitle()
            } else {
                unHighlightTitle()
            }
            currentBarView.backgroundColor = option.currentColor
            layoutIfNeeded()
        }
    }

    @IBOutlet fileprivate weak var itemLabel: UILabel!
    @IBOutlet fileprivate weak var currentBarView: UIView!
    @IBOutlet fileprivate weak var currentBarViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate weak var badge: UIView!
    @IBOutlet fileprivate weak var button: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()

        currentBarView.isHidden = true
        
        badge.isHidden = true
        badge.layer.cornerRadius = 6
        
        _ = NotificationCenter.default.addObserver(forName: TabPageViewController.NotifNameCellBadge, object: nil, queue: .main, using: { [weak self] (notif) in
            
            guard let wself = self else { return }
            if let label = notif.userInfo?["label"] as? String, label == wself.item {
                if let num = notif.userInfo?["num"] as? Int, num > 0 {
                    wself.badge.isHidden = false
                } else {
                    wself.badge.isHidden = true
                }
            }
        })
        
        _ = NotificationCenter.default.addObserver(forName: TabPageViewController.NotifNameCellToEnabled, object: nil, queue: .main, using: { [weak self] (notif) in
            guard let wself = self else { return }
            if let targetLabel = notif.userInfo?["label"] as? String, targetLabel == wself.item {
                wself.button.isEnabled = true
                wself.button.isUserInteractionEnabled = true
                wself.itemLabel.alpha = 1
            }
        })
        _ = NotificationCenter.default.addObserver(forName: TabPageViewController.NotifNameCellToDisabled, object: nil, queue: .main, using: { [weak self] (notif) in
            guard let wself = self else { return }
            if let targetLabel = notif.userInfo?["label"] as? String, targetLabel == wself.item {
                wself.button.isEnabled = false
                wself.button.isUserInteractionEnabled = false
                wself.itemLabel.alpha = 0.6
            }
        })
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        if item.count == 0 {
            return CGSize.zero
        }

        return intrinsicContentSize
    }

    class func cellIdentifier() -> String {
        return "TabCollectionCell"
    }
}


// MARK: - View

extension TabCollectionCell {
    override var intrinsicContentSize : CGSize {
        let width: CGFloat
        if let tabWidth = option.tabWidth , tabWidth > 0.0 {
            width = tabWidth
        } else {
            width = itemLabel.intrinsicContentSize.width + option.tabMargin * 2
        }

        let size = CGSize(width: width, height: option.tabHeight)
        return size
    }

    func hideCurrentBarView() {
        currentBarView.isHidden = true
    }

    func showCurrentBarView() {
        currentBarView.isHidden = false
    }

    func highlightTitle() {
        itemLabel.textColor = option.currentColor
        itemLabel.font = UIFont.boldSystemFont(ofSize: option.fontSize)
    }

    func unHighlightTitle() {
        itemLabel.textColor = option.defaultColor
        itemLabel.font = UIFont.systemFont(ofSize: option.fontSize)
    }
}


// MARK: - IBAction

extension TabCollectionCell {
    @IBAction fileprivate func tabItemTouchUpInside(_ button: UIButton) {
        tabItemButtonPressedBlock?()
    }
}
