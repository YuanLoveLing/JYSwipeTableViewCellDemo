//
//  JYSwipeTableViewCell.swift
//  JYSwipeTableViewCellDemo
//
//  Created by 靳志远 on 2017/5/8.
//  Copyright © 2017年 靳志远. All rights reserved.
//

import UIKit

/// 从右至左滑动最大取值
fileprivate let maxSwipValue: CGFloat = -200
/// 滑动动画时间
fileprivate let animateDuration = 0.35

class JYSwipeTableViewCell: UITableViewCell {
    /// 自定义内容视图
    @IBOutlet fileprivate weak var overlayerContentView: UIView!
    /// 自定义内容视图左边距离
    @IBOutlet fileprivate weak var overlayerContentViewLeftLC: NSLayoutConstraint!
    
    /// 记录传入的UITableView
    fileprivate var tableView: UITableView?
    
    /// 记录单元格是否处在已滑动状态
    fileprivate var isSwiped: Bool?
    
    /// 回调：点击右边按钮
    fileprivate var closureClickRightButton: ((_ button: UIButton) -> ())?
    /// 数组：存放右边操作按钮数组
    fileprivate var rightButtons: [UIButton] = [UIButton]()
    /// 数组：存放右边操作按钮背景颜色
    fileprivate var rightButtonBgColors: [UIColor] = [.lightGray, .orange, .red]
    /// 数组：存放右边操作按钮标题
    fileprivate var rightButtonTitles: [String]? {
        didSet {
            guard let rightButtonTitles = rightButtonTitles,
                rightButtonTitles.count > 0 else {
                    return
            }
            for index in 0..<rightButtonTitles.count {
                // 右边操作按钮最多三个
                if index == 3 {
                    break
                }
                let button = UIButton(type: .custom)
                button.tag = index
                button.setTitleColor(.white, for: .normal)
                button.titleLabel?.font = UIFont.systemFont(ofSize: 13)
                button.setTitle(rightButtonTitles[index], for: .normal)
                button.addTarget(self, action: #selector(rightButtonDidClick(button:)), for: .touchUpInside)
                button.backgroundColor = rightButtonBgColors[button.tag]
                
                contentView.insertSubview(button, belowSubview: overlayerContentView)
                rightButtons.append(button)
            }
        }
    }
    
    /**
     实例化对象类方法
     rightButtonBgColors: 右边操作按钮背景色数组，不传则显示默认颜色（右边操作按钮最多三个，多传无用）
     rightButtonTitles: 右边操作按钮标题数组（右边操作按钮最多三个，多传无用）
     closureClickRightButton: 点击右边操作按钮触发事件，参数是button，可以根据button的title或者tag判断点击了哪个操作按钮
     */
    class func swipeTableViewCell(tableView: UITableView, rightButtonBgColors:[UIColor]? = nil, rightButtonTitles: [String], closureClickRightButton: ((_ button: UIButton) -> ())?) -> (JYSwipeTableViewCell) {
        var cell = tableView.dequeueReusableCell(withIdentifier: "JYSwipeTableViewCellId") as? JYSwipeTableViewCell
        if cell == nil {
            cell = Bundle.main.loadNibNamed("JYSwipeTableViewCell", owner: nil, options: nil)?.first as? JYSwipeTableViewCell
        }
        cell?.tableView = tableView
        if let rightButtonBgColors = rightButtonBgColors, rightButtonBgColors.count > 0 {
            cell?.rightButtonBgColors = rightButtonBgColors
        }
        cell?.rightButtonTitles = rightButtonTitles
        cell?.closureClickRightButton = closureClickRightButton
        return cell!
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
        isSwiped = false
        
        // overlayerContentView添加滑动手势
        let pan = UIPanGestureRecognizer(target: self, action: #selector(overlayerContentViewDidSwip(pan:)))
        overlayerContentView.addGestureRecognizer(pan)
        
        // overlayerContentView添加点击手势
        let tap = UITapGestureRecognizer(target: self, action: #selector(overlayerContentViewDidTap(tap:)))
        overlayerContentView.addGestureRecognizer(tap)
    }
    
    // MARK: - lazy
    // 如果没有传入UITableView，可以通过查找父视图父方式找到tableView
    //    fileprivate lazy var tableView: UITableView? = {
    //        var nextView = self.superview
    //        while nextView != nil {
    //            // 遍历cell的superview，当superview是UITableView的时候，说明找到了
    //            if nextView?.isKind(of: UITableView.self) == true {
    //                break
    //            }
    //            nextView = nextView?.superview
    //        }
    //
    //        return nextView as? UITableView
    //    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // 操作按钮
        if rightButtons.count > 0 {
            for index in 0..<rightButtons.count {
                
                let button = rightButtons[index]
                guard button.isKind(of: UIButton.self) == true else {
                    return
                }
                // 根据tag值大小从左往右排
                let w: CGFloat = abs(maxSwipValue) / CGFloat(rightButtons.count)
                let h: CGFloat = bounds.height
                let x: CGFloat = bounds.width - abs(maxSwipValue) + CGFloat(index) * w
                let y: CGFloat = 0
                button.frame = CGRect(x: x, y: y, width: w, height: h)
            }
        }
    }
}

// MARK - 点击右边操作按钮触发事件
extension JYSwipeTableViewCell {
    @objc fileprivate func rightButtonDidClick(button: UIButton) {
        if closureClickRightButton != nil {
            closureClickRightButton!(button)
        }
    }
}


// MARK - 手势触发事件
extension JYSwipeTableViewCell {
    /// 点击overlayerContentView后出发的方法
    @objc fileprivate func overlayerContentViewDidTap(tap: UITapGestureRecognizer) {
        // 恢复已滑动单元格
        recoverSwipedCell()
    }
    
    // 滑动overlayerContentView后出发的方法
    @objc fileprivate func overlayerContentViewDidSwip(pan: UIPanGestureRecognizer) {
        var translationX = pan.translation(in: self).x
        // print("translationX: \(translationX)")
        
        if pan.state == .began {// 滑动开始
            // 恢复已滑动单元格
            recoverSwipedCell()
            
        }else if pan.state == .changed {// 滑动中
            if translationX < 0 {// 从右往左滑
                if isSwiped == false {// 当前不是滑动后的状态
                    translationX = translationX < maxSwipValue ? maxSwipValue : translationX
                    overlayerContentViewLeftLC.constant = translationX
                }
                
            }else {// 从左往右滑
                if isSwiped == true {// 处在滑动后的状态
                    UIView.animate(withDuration: animateDuration, animations: {[weak self] in
                        self?.overlayerContentView.frame = (self?.bounds)!
                        
                        }, completion: {[weak self] (_) in
                            self?.isSwiped = false
                    })
                }
            }
            
        }else if pan.state == .ended, isSwiped == false {// 滑动结束，且单元格当前不是滑动后的状态
            if translationX > maxSwipValue * 0.3 {// 滑过距离没有超过maxSwipValue的三分之一
                overlayerContentViewLeftLC.constant = 0
                
            }else {// 滑过距离超过maxSwipValue的三分之一
                overlayerContentViewLeftLC.constant = maxSwipValue
            }
            
            tableView?.isUserInteractionEnabled = false
            UIView.animate(withDuration: animateDuration, animations: {[weak self] in
                self?.contentView.layoutIfNeeded()
                
                }, completion: {[weak self] (_) in
                    if self?.overlayerContentViewLeftLC.constant == maxSwipValue {
                        self?.isSwiped = true
                    }
                    self?.tableView?.isUserInteractionEnabled = true
            })
        }
    }
    
    /// 恢复已滑动单元格
    fileprivate func recoverSwipedCell() {
        guard let tableView = tableView else {
            return
        }
        for cell in tableView.visibleCells {
            guard let cell = cell as? JYSwipeTableViewCell else {
                continue
            }
            if cell.isSwiped == true {// 已经处在滑动后的状态
                cell.overlayerContentViewLeftLC.constant = 0
                UIView.animate(withDuration: animateDuration, animations: {
                    cell.contentView.layoutIfNeeded()
                    
                }, completion: { (_) in
                    cell.isSwiped = false
                })
            }
        }
    }
}












