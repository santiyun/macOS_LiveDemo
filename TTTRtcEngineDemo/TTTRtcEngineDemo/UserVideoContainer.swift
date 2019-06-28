//
//  UserVideoContainer.swift
//  TTTRtcEngineDemo
//
//  Created by doubon on 2018/7/11.
//  Copyright © 2018年 3ttech. All rights reserved.
//

import Cocoa

class UserVideoContainer: NSControl {
    @IBOutlet var contentView: NSView!
    @IBOutlet weak var userVideoControl: UserVideoControl!
    
    var isHuge = false
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        // Drawing code here.
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        loadView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        loadView()
    }
    
    func loadView() -> Void {
        Bundle.main.loadNibNamed("\(type(of: self))", owner: self, topLevelObjects: nil)
        addSubview(contentView)
        contentView.frame = bounds
        userVideoControl.frame = contentView.bounds
        
        userVideoControl.container = self

        //        reset()
    }
    
    override func resizeSubviews(withOldSize oldSize: NSSize) {
        super.resizeSubviews(withOldSize: oldSize)
        
        contentView.frame = bounds
        userVideoControl.frame = contentView.bounds
    }
    
}
