//
//  ViewController.swift
//  JYSwipeTableViewCellDemo
//
//  Created by 靳志远 on 2017/5/8.
//  Copyright © 2017年 靳志远. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var myTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
}

// UITableViewDataSource
extension ViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //        let rightButtonBgColors = [UIColor.purple, UIColor.blue, UIColor.cyan]
        //        let rightButtonTitles = ["置顶", "标为未读", "删除"]
        //        let cell = JYSwipeTableViewCell.swipeTableViewCell(tableView: tableView, rightButtonBgColors:rightButtonBgColors ,rightButtonTitles: rightButtonTitles) { (button: UIButton) in
        //            let buttonTitle = button.title(for: .normal)
        //            print(buttonTitle ?? "空的")
        //        }
        
        // let rightButtonTitles = ["置顶", "标为未读"]
        let rightButtonTitles = ["置顶", "标为未读", "删除"]
        let cell = JYSwipeTableViewCell.swipeTableViewCell(tableView: tableView,rightButtonTitles: rightButtonTitles) { (button: UIButton) in
            let buttonTitle = button.title(for: .normal)
            print(buttonTitle ?? "空的")
        }
        
        return cell
    }
}


// UITableViewDelegate
extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}












