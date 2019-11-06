//
//  LiveRoomWindowController.swift
//  TTTRtcEngineDemo
//
//  Created by doubon on 2018/7/10.
//  Copyright © 2018年 3ttech. All rights reserved.
//

import Cocoa

class LiveRoomWindowController: NSWindowController {
    
    @IBOutlet weak var toolbarItemLocalVideo: NSToolbarItem!
    @IBOutlet weak var toolbarItemAudioEarBack: NSToolbarItem!
    
    override func windowDidLoad() {
        super.windowDidLoad()

        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
        self.window?.isRestorable = false
        self.window?.center()

        NotificationCenter.default.addObserver(self, selector: #selector(onAudioRouteChanged(_:)),
                                               name: NSNotification.Name(rawValue: "AudioRouteChanged"), object: nil)
    }
    
    @IBAction func enableLocalVideo(_ sender: NSToolbarItem) {
        if sender.tag == 1 {
            app.rtcEngine.enableLocalVideo(false)
            sender.tag = 0
            sender.image = NSImage(named: "CameraClose")
            sender.toolTip = "点击启用本地视频"
        } else {
            app.rtcEngine.enableLocalVideo(true)
            sender.tag = 1
            sender.image = NSImage(named: "Camera")
            sender.toolTip = "点击禁用本地视频"
        }
    }
    
    @IBAction func muteLocalAudioStream(_ sender: NSToolbarItem) {
        if sender.tag == 0 {
            app.rtcEngine.muteLocalAudioStream(true)
            sender.tag = 1
            sender.image = NSImage(named: "mic_close")
            sender.toolTip = "点击发送音频流"
        } else {
            app.rtcEngine.muteLocalAudioStream(false)
            sender.tag = 0
            sender.image = NSImage(named: "mic")
            sender.toolTip = "点击停止发送音频流"
        }
    }

    @IBAction func muteAllRemoteAudioStreams(_ sender: NSToolbarItem) {
        if sender.tag == 0 {
            app.rtcEngine.muteAllRemoteAudioStreams(true)
            sender.tag = 1
            sender.image = NSImage(named: "voice_close")
            sender.toolTip = "点击听所有人"
        } else {
            app.rtcEngine.muteAllRemoteAudioStreams(false)
            sender.tag = 0
            sender.image = NSImage(named: "voice_big")
            sender.toolTip = "点击不听所有人"
        }
    }
    
    @IBAction func muteAllRemoteVideoStreams(_ sender: NSToolbarItem) {
        if sender.tag == 0 {
            app.rtcEngine.muteAllRemoteVideoStreams(true)
            sender.tag = 1
            sender.image = NSImage(named: "video_close")
            sender.toolTip = "点击看所有人"
        } else {
            app.rtcEngine.muteAllRemoteVideoStreams(false)
            sender.tag = 0
            sender.image = NSImage(named: "video")
            sender.toolTip = "点击不看所有人"
        }
    }
    
    @IBAction func enableAudioEarBack(_ sender: NSToolbarItem) {
        if app.rtcEngine.audioPlayoutDevice == nil {
            return
        }
        if app.rtcEngine.audioPlayoutDevice.deviceType != .audioDevice_Output_Headphones {
            ProgressHUD.showInfoWithStatus("必须插入耳机才能使用“耳返”功能！")
            return
        }
        
        if sender.tag == 0 {
            sender.tag = 1
            sender.image = NSImage(named: "earBack_s")
            sender.toolTip = "点击关闭耳返"
        } else {
            sender.tag = 0
            sender.image = NSImage(named: "earBack_u")
            sender.toolTip = "点击打开耳返"
        }
        app.rtcEngine.enableAudioEarBack(sender.tag != 0)
    }
    
    func doExitRoom() -> Void {
        app.rtcEngine.delegate = nil
        app.rtcEngine.leaveChannel(nil)
        
        if let liveRoomViewController = self.contentViewController as? LiveRoomViewController {
            liveRoomViewController.doExitRoom()
        }
    }
    
    @IBAction func exitRoom(_ sender: Any) {
        doExitRoom()
    }
    
    @objc func onAudioRouteChanged(_ notification: NSNotification) -> Void {
        if app.rtcEngine.isAudioEarBackEnabled() {
            toolbarItemAudioEarBack.tag = 1
            toolbarItemAudioEarBack.image = NSImage(named: "earBack_s")
            toolbarItemAudioEarBack.toolTip = "点击关闭耳返"
        } else {
            toolbarItemAudioEarBack.tag = 0
            toolbarItemAudioEarBack.image = NSImage(named: "earBack_u")
            toolbarItemAudioEarBack.toolTip = "点击打开耳返"
        }
    }
}

extension LiveRoomWindowController: NSWindowDelegate {
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        doExitRoom()
        return false
    }
}
