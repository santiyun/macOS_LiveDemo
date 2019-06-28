//
//  MainWindowController.swift
//  TTTRtcEngineDemo
//
//  Created by doubon on 2017/8/18.
//  Copyright © 2017年 3ttech. All rights reserved.
//

import Cocoa

class MainWindowController: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()
    
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
        self.window?.isRestorable = false
        self.window?.center()
        
        app.mainWindowController = self
    }
}
