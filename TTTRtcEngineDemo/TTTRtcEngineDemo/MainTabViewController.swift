//
//  MainTabViewController.swift
//  TTTRtcEngineDemo
//
//  Created by doubon on 2017/8/18.
//  Copyright © 2017年 3ttech. All rights reserved.
//

import Cocoa

class MainTabViewController: NSTabViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        self.selectedTabViewItemIndex = 0
    }
    
    override func tabView(_ tabView: NSTabView, shouldSelect tabViewItem: NSTabViewItem?) -> Bool {
        if let tabItemIdentifier = tabViewItem?.identifier as? String {
            if tabItemIdentifier == "PushStream" {
                return false
            }
        }
        return true
    }
}
