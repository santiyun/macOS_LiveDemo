//
//  UserVideoControl.swift
//  TTTRtcEngineDemo
//
//  Created by doubon on 2018/7/11.
//  Copyright © 2018年 3ttech. All rights reserved.
//

import Cocoa

struct UserVideoControlPosition {
    var x = 0.0
    var y = 0.0
    var width = 0.0
    var height = 0.0
    
    var row: Int {
        if width > 0 && height > 0 {
            if width == 1 || height == 1 {
                return 0
            }
            else {
                let r = round((1 - y) / height)
                return Int(r)
            }
        }
        else {
            return -1
        }
    }
    
    var column: Int {
        if width > 0 && height > 0 {
            if width == 1 || height == 1 {
                return 0
            }
            else {
                return Int((x + width) / width)
            }
        }
        else {
            return -1
        }
    }
    
    func debugPrint() -> Void {
        let positioInfo = "x = \(x), y = \(y), width = \(width), height = \(height), \nrow = \(row), column = \(column)"
        print(positioInfo)
    }
}

class UserVideoControl: NSControl {
    weak var user: TTTUser?
    weak var container: UserVideoContainer!
    var deviceID = ""
    @IBOutlet var contentView: NSView!
    @IBOutlet weak var imageView: NSImageView!
    @IBOutlet weak var stackViewUser: NSStackView!
    @IBOutlet weak var viewMediaStats: NSView!
    @IBOutlet weak var labelUserRole: NSTextField!
    @IBOutlet weak var labelUserID: NSTextField!
    @IBOutlet weak var stackViewAudioLevel: NSStackView!
    @IBOutlet weak var labelAudioLevel: NSTextField!
    @IBOutlet weak var labelAudioStatsLabel: NSTextField!
    @IBOutlet weak var labelAudioStats: NSTextField!
    @IBOutlet weak var labelVideoStatsLabel: NSTextField!
    @IBOutlet weak var labelVideoStats: NSTextField!
    @IBOutlet weak var boxButtons: NSBox!
    @IBOutlet weak var layoutConstraintImageViewTop: NSLayoutConstraint!
    @IBOutlet weak var layoutConstraintImageViewTrailing: NSLayoutConstraint!
    
    @IBOutlet weak var buttonMuteRemoteVideoStream: NSButton!
    @IBOutlet weak var buttonMuteRemoteAudioStream: NSButton!
    @IBOutlet weak var buttonMuteRemoteSpeaking: NSButton!
    
    
    var isRemoteStatsHidden: Bool = false
    
    var position: UserVideoControlPosition {
        var thePosition = UserVideoControlPosition()
        
        guard let videoViewRect = container.superview?.bounds else {
            return thePosition
        }
        
        //let selfRect = superview?.convert(frame, to: container.superview)
        let containerRect = container.frame
        
        let x = containerRect.origin.x    / videoViewRect.size.width
        let y = (videoViewRect.size.height - (containerRect.origin.y + containerRect.size.height)) / videoViewRect.size.height
        let w = containerRect.size.width  / videoViewRect.size.width
        let h = containerRect.size.height / videoViewRect.size.height
        
        thePosition.x      = Double(String(format: "%.3f", x))!
        thePosition.y      = Double(String(format: "%.3f", y))!
        thePosition.width  = Double(String(format: "%.3f", w))!
        thePosition.height = Double(String(format: "%.3f", h))!
        return thePosition
    }
    
    func showButtonsBox(_ visible: Bool) -> Void {
        if visible {
            layoutConstraintImageViewTrailing.constant = 36
            boxButtons.isHidden = false
        } else {
            layoutConstraintImageViewTrailing.constant = 0
            boxButtons.isHidden = true
        }
    }
    
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
//        contentView.frame = bounds1
        addSubview(contentView)

        imageView.imageScaling = .scaleNone
        
//        if #available(macOS 10.14, *) {
            layoutConstraintImageViewTop.constant = 0
//        } else {
//            layoutConstraintImageViewTop.constant = 46
//        }

        reset()
    }
    
    override func resizeSubviews(withOldSize oldSize: NSSize) {
        super.resizeSubviews(withOldSize: oldSize)
        
        contentView.frame = bounds
//        userVideoControl.frame = contentView.bounds
        
    }
    
    func reset() -> Void {
        user = nil
        deviceID = ""
//        mixedByHost = false
        imageView.isHidden = true
        imageView.image = NSImage(named: "black")
        imageView.imageScaling = .scaleAxesIndependently
        
//        showBorders(false)
//        speakButton.isHidden = true
//        menuButton.isHidden = true
//        audioSendLabel.text = " 0 "
//        videoSendLabel.text = " 0 "
//        sendStatsView.isHidden = true
//        audioReceivedLabel.text = " 0 "
//        videoReceivedLabel.text = " 0 "
//        receivedStatsView.isHidden = false
//        menuButton.setImage(UIImage(named: "xiala"), for: .normal)
//        menuButton.setImage(UIImage(named: "xiala_dianji"), for: .highlighted)
//        contentView.sendSubview(toBack: menuView)
//        menuView.isHidden = true
//        isHidden = true
//        container?.contentView.sendSubview(toBack: self)
//        container?.alpha = 0.75
        contentView.alphaValue = 1.0
        stackViewUser.isHidden = true
        viewMediaStats.isHidden = true
        stackViewAudioLevel.isHidden = true
    }

    func initWith(user: TTTUser, deviceID: String, viewRenderMode:TTTRtcRenderMode) -> Void {
        self.user = user
        self.deviceID = deviceID
        
        stackViewUser.isHidden = false
        viewMediaStats.isHidden = false
        stackViewAudioLevel.isHidden = false
        imageView.isHidden = false
        
        let videoCanvas = TTTRtcVideoCanvas()
        videoCanvas.uid = user.userID
        videoCanvas.deviceId = deviceID
        videoCanvas.view = imageView
        videoCanvas.renderMode = viewRenderMode

        if user.isAnchor {
            labelUserRole.stringValue = "主播:"
        } else {
            labelUserRole.stringValue = "副播:"
        }
        labelUserID.stringValue = "\(user.userID)"
        labelUserID.toolTip = deviceID
        
        if user.isMe {
            contentView.alphaValue = 1.0
            imageView.alphaValue = 1.0
            app.rtcEngine.setupLocalVideo(videoCanvas)
            
            labelAudioStatsLabel.stringValue = "A-↑"
            labelVideoStatsLabel.stringValue = "V-↑"
        }
        else {
            contentView.alphaValue = 1.0
            app.rtcEngine.setupRemoteVideo(videoCanvas)
            
            labelAudioStatsLabel.stringValue = "A-↓"
            labelVideoStatsLabel.stringValue = "V-↓"
        }
        
//        imageView.removeFromSuperview()
//        self.contentView.addSubview(imageView, positioned: .below, relativeTo: nil)
//        layoutConstraintImageViewTop.constant = 8
        //viewRemoteStats.isHidden = isRemoteStatsHidden
        
//        refreshControlStatus()
//
//        isHidden = false
//        container.contentView.bringSubview(toFront: self)
//        container.isUserInteractionEnabled = true
//        container.alpha = 1
        
        buttonMuteRemoteVideoStream.tag = 0
        buttonMuteRemoteVideoStream.image = NSImage(named: "video")
        buttonMuteRemoteVideoStream.toolTip = "点击不看用户视频"

        buttonMuteRemoteAudioStream.tag = 0
        buttonMuteRemoteAudioStream.image = NSImage(named: "voice_big")
        buttonMuteRemoteAudioStream.toolTip = "点击不听用户音频"

        buttonMuteRemoteSpeaking.tag = 0
        buttonMuteRemoteSpeaking.image = NSImage(named: "speaking")
        buttonMuteRemoteSpeaking.toolTip = "点击禁止用户说话"
    }
    
    func closeVideoDevice() -> Void {
        if user != nil {
            if user!.isMe {
                app.rtcEngine.setupLocalVideo(nil)
            }
            else {
                app.rtcEngine.muteRemoteVideoStream(user!.userID, mute: true, deviceId: deviceID)
                app.rtcEngine.setupRemoteVideo(nil)
            }
            
            reset()
        }
    }
    
    func enableVideo(_ enabled: Bool) -> Void {
        if user == nil || user!.isMe {
            return
        }
        
        if enabled {
            //imageView.image = nil
        } else {
            imageView.image = NSImage(named: "black")
            imageView.imageScaling = .scaleAxesIndependently
        }
    }

    func setLocalVideoStats(_ localVideoStats: TTTRtcLocalVideoStats) -> Void {
        labelVideoStatsLabel.stringValue = "V-↑"
        labelVideoStats.stringValue = "\(localVideoStats.sentBitrate)"
    }
    
    func setLocalAudioStats(_ localAudioStats: TTTRtcLocalAudioStats) -> Void {
        labelAudioStatsLabel.stringValue = "A-↑"
        labelAudioStats.stringValue = "\(localAudioStats.sentBitrate)"
    }
    
    func setRemoteVideoStats(_ remoteVideoStats: TTTRtcRemoteVideoStats) -> Void {
        labelVideoStatsLabel.stringValue = "V-↓"
        labelVideoStats.stringValue = "\(remoteVideoStats.receivedBitrate)"
    }
    
    func setRemoteAudioStats(_ remoteAudioStats: TTTRtcRemoteAudioStats) -> Void {
        labelAudioStatsLabel.stringValue = "A-↓"
        labelAudioStats.stringValue = "\(remoteAudioStats.receivedBitrate)"
    }
    
    func setAudioLevel(_ audioLevel: UInt) -> Void {
        labelAudioLevel.stringValue = "\(audioLevel)"
    }
    
    @IBAction func muteRemoteVideoStream(_ sender: NSButton) {
        if sender.tag == 0 {
            app.rtcEngine.muteRemoteVideoStream(user!.userID, mute: true, deviceId: deviceID)
            sender.tag = 1
            sender.image = NSImage(named: "video_close")
            sender.toolTip = "点击看用户视频"
        } else {
            app.rtcEngine.muteRemoteVideoStream(user!.userID, mute: false, deviceId: deviceID)
            sender.tag = 0
            sender.image = NSImage(named: "video")
            sender.toolTip = "点击不看用户视频"
        }
    }
    
    @IBAction func muteRemoteAudioStream(_ sender: NSButton) {
        if sender.tag == 0 {
            app.rtcEngine.muteRemoteAudioStream(user!.userID, mute: true)
            sender.tag = 1
            sender.image = NSImage(named: "voice_close")
            sender.toolTip = "点击听用户音频"
        } else {
            app.rtcEngine.muteRemoteAudioStream(user!.userID, mute: false)
            sender.tag = 0
            sender.image = NSImage(named: "voice_big")
            sender.toolTip = "点击不听用户音频"
        }
    }
    
    @IBAction func muteRemoteSpeaking(_ sender: NSButton) {
        if sender.tag == 0 {
            app.rtcEngine.muteRemoteSpeaking(user!.userID, mute: true)
            sender.tag = 1
            sender.image = NSImage(named: "speaking_mute")
            sender.toolTip = "点击允许用户说话"
        } else {
            app.rtcEngine.muteRemoteSpeaking(user!.userID, mute: false)
            sender.tag = 0
            sender.image = NSImage(named: "speaking")
            sender.toolTip = "点击禁止用户说话"
        }
    }
    
    @IBAction func kickChannelUser(_ sender: NSButton) {
        if user != nil {
            app.rtcEngine.kickChannelUser(user!.userID)
        }
    }
}
