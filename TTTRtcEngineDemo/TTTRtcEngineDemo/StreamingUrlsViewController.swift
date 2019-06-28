//
//  StreamingUrlsViewController.swift
//  TTTRtcEngineDemo
//
//  Created by doubon on 2017/8/18.
//  Copyright © 2017年 3ttech. All rights reserved.
//

import Cocoa

class StreamingUrlsViewController: NSViewController {
    
    @IBOutlet weak var urlTextField: NSTextField!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    @IBAction func onClickPlayButton(_ sender: Any) {
        let streamingUrlText = urlTextField.stringValue.trimmingCharacters(in: CharacterSet.whitespaces)
        if streamingUrlText.count <= 0 {
            app.showAlert(window: nil, alertStyle: .warning, messageText: "提示", informativeText: "请输入流媒体地址！")
            return
        }
        
        let streamingUrl = NSURL(string: streamingUrlText)
        let scheme = streamingUrl?.scheme?.lowercased()
        if scheme != "http" && scheme != "https" && scheme != "rtmp"  {
            app.showAlert(window: nil, alertStyle: .critical, messageText: "提示", informativeText: "流媒体地址格式不正确！")
            return
        }
        
        self.playStreaming(url: streamingUrl!)
    }
    
    func playStreaming(url: NSURL) -> Void {
        if let spvc = self.storyboard?.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("StreamingPlayer")) as? StreamingPlayerViewController {
            spvc.url = url
            self.presentAsModalWindow(spvc)
        }
    }
}
