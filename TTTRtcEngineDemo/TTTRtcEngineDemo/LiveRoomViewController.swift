//
//  LiveRoomViewController.swift
//  TTTRtcEngineDemo
//
//  Created by doubon on 2018/7/11.
//  Copyright © 2018年 3ttech. All rights reserved.
//

import Cocoa

class LiveRoomViewController: NSViewController {
    @IBOutlet weak var labelSessionID: NSTextField!
    @IBOutlet weak var textFieldRtmpUrl: NSTextField!
    @IBOutlet weak var userVideoContainerHuge: UserVideoContainer!
    @IBOutlet weak var userVideoContainer1: UserVideoContainer!
    @IBOutlet weak var userVideoContainer2: UserVideoContainer!
    @IBOutlet weak var userVideoContainer3: UserVideoContainer!
    @IBOutlet weak var userVideoContainer4: UserVideoContainer!
    @IBOutlet weak var userVideoContainer5: UserVideoContainer!
    @IBOutlet weak var userVideoContainer6: UserVideoContainer!
    @IBOutlet weak var userVideoContainer7: UserVideoContainer!
    @IBOutlet weak var userVideoContainer8: UserVideoContainer!
    @IBOutlet weak var userVideoContainer9: UserVideoContainer!
    @IBOutlet weak var userVideoContainer10: UserVideoContainer!
    @IBOutlet weak var userVideoContainer11: UserVideoContainer!
    @IBOutlet weak var userVideoContainer12: UserVideoContainer!
    @IBOutlet weak var userVideoContainer13: UserVideoContainer!
    @IBOutlet weak var userVideoContainer14: UserVideoContainer!
    @IBOutlet weak var userVideoContainer15: UserVideoContainer!
    @IBOutlet weak var tabViewMusic: NSTabView!
    @IBOutlet weak var buttonSelectAudioFileName: NSButton!
    @IBOutlet weak var labelAudioFileName: NSTextField!
    @IBOutlet weak var sliderAudioMixing: NSSlider!
    @IBOutlet weak var labelRemainSeconds: NSTextField!
    @IBOutlet weak var buttonStartAudioMixing: NSButton!
    @IBOutlet weak var buttonPauseResumeAudioMixing: NSButton!
    @IBOutlet weak var buttonStopAudioMixing: NSButton!
    @IBOutlet weak var buttonOnlyLocalHear: NSButton!
    @IBOutlet weak var labelSoloVolume: NSTextField!
    @IBOutlet weak var labelFileVolume: NSTextField!
    @IBOutlet weak var levelIndicatorSoloVolume: NSLevelIndicator!
    @IBOutlet weak var levelIndicatorFileVolume: NSLevelIndicator!
    @IBOutlet weak var buttonPlaySoundEffect1: NSButton!
    @IBOutlet weak var buttonStopSoundEffect1: NSButton!
    @IBOutlet weak var buttonPlaySoundEffect2: NSButton!
    @IBOutlet weak var buttonStopSoundEffect2: NSButton!
    @IBOutlet weak var buttonPauseAllSoundEffects: NSButton!
    @IBOutlet weak var buttonStopAllSoundEffects: NSButton!
    @IBOutlet weak var stackViewSoundEffect1: NSStackView!
    @IBOutlet weak var stackViewSoundEffect2: NSStackView!
    @IBOutlet weak var labelWaterMarkX: NSTextField!
    @IBOutlet weak var labelWaterMarkY: NSTextField!
    @IBOutlet weak var stepperWaterMarkX: NSStepper!
    @IBOutlet weak var stepperWaterMarkY: NSStepper!
    
    private var userVideoContainers: [UserVideoContainer]!
    private var userVideoControls: [UserVideoControl]!
    
    private var audioMixingStatus: Int = -1
    private var audioMixingTimer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        app.rtcEngine.delegate = self
        ProgressHUD.setContainerView(self.view)
        
        labelSessionID.stringValue = "\(app.userMe!.sessionID)"
        textFieldRtmpUrl.stringValue = "rtmp://pull.3ttech.cn/sdk/\(app.userMe!.sessionID)"
        
        switch app.userMe!.clientRole {
        case .clientRole_Anchor:
            app.videoCompositingLayout = TTTRtcVideoCompositingLayout()
            switch app.videoProfile {
            case ._VideoProfile_480P:
                app.videoCompositingLayout!.canvasWidth = 848
                app.videoCompositingLayout!.canvasHeight = 480
            case ._VideoProfile_720P:
                app.videoCompositingLayout!.canvasWidth = 1280
                app.videoCompositingLayout!.canvasHeight = 720
            default:
                app.videoCompositingLayout!.canvasWidth = 640
                app.videoCompositingLayout!.canvasHeight = 360
            }
            app.videoCompositingLayout!.backgroundColor = "#e8e6e8"
        case .clientRole_Broadcaster:
            app.videoCompositingLayout = nil
        default:
            app.videoCompositingLayout = nil
        }
        
        userVideoContainers = [UserVideoContainer]()
        userVideoContainerHuge.isHuge = true
        userVideoContainers.append(userVideoContainerHuge)
        userVideoContainers.append(userVideoContainer13)
        userVideoContainers.append(userVideoContainer14)
        userVideoContainers.append(userVideoContainer15)
        userVideoContainers.append(userVideoContainer10)
        userVideoContainers.append(userVideoContainer11)
        userVideoContainers.append(userVideoContainer12)
        userVideoContainers.append(userVideoContainer7)
        userVideoContainers.append(userVideoContainer8)
        userVideoContainers.append(userVideoContainer9)
        userVideoContainers.append(userVideoContainer4)
        userVideoContainers.append(userVideoContainer5)
        userVideoContainers.append(userVideoContainer6)
        userVideoContainers.append(userVideoContainer1)
        userVideoContainers.append(userVideoContainer2)
        userVideoContainers.append(userVideoContainer3)

        userVideoControls = [UserVideoControl]()
        for userVideoContainer in userVideoContainers {
            userVideoControls.append(userVideoContainer.userVideoControl)
//            userVideoContainer.userVideoControl.delegate = self
        }
        
//        if app.userMe!.isAnchor {
//            anchorIDLabel.text = "\(app.userMe!.userID)"
//            sendStatsView.isHidden = !showStatsInfo
//            receivedStatsView.isHidden = true
//            receivedStatsViewTopConstraint.constant = 12
//            cameraButtonTopConstraint.constant = 60
//            speakButtonTopConstraint.constant = 111
//            speakButtonLeftConstraint.constant = 8
//
//            myVideoControl = userVideoContainerHuge.userVideoControl
//            myVideoControl!.initWith(user: app.userMe!, viewRenderMode: .render_Adaptive)
            
            userVideoContainerHuge.userVideoControl.initWith(user: app.userMe!, deviceID: app.rtcEngine.defaultVideoDeviceID, viewRenderMode: .render_Fit)
            app.rtcEngine.startPreview()
//        }
        
        //tabViewMusic.selectLastTabViewItem(nil)
        levelIndicatorSoloVolume.intValue = 10
        levelIndicatorFileVolume.intValue = 10
        
        refreshSoundEffectButtons()
    }
    
    override func viewDidLayout() {
        super.viewDidLayout()
    }
    
    @IBAction func selectAudioMixingFile(_ sender: NSButton) {
        if audioMixingStatus != -1 && audioMixingStatus != 0 {
            return
        }
        
        let openPanel = NSOpenPanel()
        openPanel.allowedFileTypes = ["mp3"]
        openPanel.beginSheetModal(for: self.view.window!) { (response: NSApplication.ModalResponse) in
            if response == .OK {
                //let urlString = openPanel.url!.absoluteString.removingPercentEncoding!
                self.labelAudioFileName.toolTip = /*urlString*/openPanel.url!.path
                self.labelAudioFileName.stringValue = openPanel.url!.lastPathComponent
                self.audioMixingStatus = 0
                self.refreshAudioMixingButtonStatus()
                
                self.levelIndicatorSoloVolume.intValue = 10
                self.levelIndicatorFileVolume.intValue = 10
            }
        }
    }

    @IBAction func startAudioMixing(_ sender: NSButton) {
        if audioMixingStatus == 0 {
            audioMixingStatus = 1
            refreshAudioMixingButtonStatus()
            buttonSelectAudioFileName.isEnabled = false
            sliderAudioMixing.isEnabled = true
            let isOnlyLocalHear = (buttonOnlyLocalHear.state == .on)
            app.rtcEngine.startAudioMixing(labelAudioFileName.toolTip, loopback: isOnlyLocalHear, cycle: 1);
        }
    }
    
    @IBAction func pauseResumeAudioMixing(_ sender: NSButton) {
        if audioMixingStatus == 1 || audioMixingStatus == 2 {
            if audioMixingStatus == 1 {
                audioMixingStatus = 2
                refreshAudioMixingButtonStatus()
                app.rtcEngine.pauseAudioMixing()
            } else {
                audioMixingStatus = 1
                refreshAudioMixingButtonStatus()
                app.rtcEngine.resumeAudioMixing()
            }
        }
    }
    
    func doStopAudioMixing() -> Void {
        audioMixingTimer?.invalidate()
        audioMixingTimer = nil
        audioMixingStatus = 0
        refreshAudioMixingButtonStatus()
        buttonSelectAudioFileName.isEnabled = true
        sliderAudioMixing.intValue = 0
        sliderAudioMixing.isEnabled = false
        labelRemainSeconds.isHidden = true
    }
    
    @IBAction func stopAudioMixing(_ sender: NSButton) {
        if audioMixingStatus == 1 || audioMixingStatus == 2 {
            app.rtcEngine.stopAudioMixing()
            doStopAudioMixing()
        }
    }
    
    func refreshAudioMixingButtonStatus() -> Void {
        switch audioMixingStatus {
        case 0:
            buttonOnlyLocalHear.isEnabled = true
            buttonStartAudioMixing.isEnabled = true
            buttonPauseResumeAudioMixing.isEnabled = false
            buttonPauseResumeAudioMixing.title = "暂停播放"
            buttonStopAudioMixing.isEnabled = false
            labelSoloVolume.stringValue = ""
            levelIndicatorSoloVolume.isEnabled = false
            labelFileVolume.stringValue = ""
            levelIndicatorFileVolume.isEnabled = false
        case 1:
            buttonOnlyLocalHear.isEnabled = false
            buttonStartAudioMixing.isEnabled = false
            buttonPauseResumeAudioMixing.isEnabled = true
            buttonPauseResumeAudioMixing.title = "暂停播放"
            buttonStopAudioMixing.isEnabled = true
            labelSoloVolume.stringValue = labelSoloVolume.placeholderString ?? ""
            levelIndicatorSoloVolume.isEnabled = true
            labelFileVolume.stringValue = labelFileVolume.placeholderString ?? ""
            levelIndicatorFileVolume.isEnabled = true
        case 2:
            buttonOnlyLocalHear.isEnabled = false
            buttonStartAudioMixing.isEnabled = false
            buttonPauseResumeAudioMixing.isEnabled = true
            buttonPauseResumeAudioMixing.title = "恢复播放"
            buttonStopAudioMixing.isEnabled = true
            labelSoloVolume.stringValue = ""
            levelIndicatorSoloVolume.isEnabled = false
            labelFileVolume.stringValue = ""
            levelIndicatorFileVolume.isEnabled = false
        default: // -1
            break
        }
    }
    
    @objc func audioMixingTimerFired(theTimer: Timer) -> Void {
        let audioMixingPos = app.rtcEngine.getAudioMixingCurrentPosition()
        sliderAudioMixing.intValue = audioMixingPos
        let remainSeconds = (Int32(sliderAudioMixing.maxValue) - sliderAudioMixing.intValue) / 1000
        labelRemainSeconds.stringValue = "\(remainSeconds)"
    }
    
    @IBAction func sliderAudioMixingAction(_ sender: Any) {
        app.rtcEngine.setAudioMixingPosition(sliderAudioMixing!.integerValue)
    }
    
    func getAvailableUserVideoControl() -> UserVideoControl? {
        for userVideoControl in userVideoControls {
            if !userVideoControl.container.isHuge && userVideoControl.user == nil {
                return userVideoControl
            }
        }
        return nil
    }
    
    func getUserVideoControlWithDeviceID(_ deviceID: String) -> UserVideoControl? {
        for userVideoControl in userVideoControls {
            if userVideoControl.deviceID == deviceID {
                return userVideoControl
            }
        }
        return nil
    }
    
    func getUserVideoControlWithUser(_ aUser: TTTUser) -> [UserVideoControl] {
        var theUserVideoControls: [UserVideoControl] = []
        for userVideoControl in userVideoControls {
            if userVideoControl.user != nil && userVideoControl.user == aUser {
                theUserVideoControls.append(userVideoControl)
            }
        }
        return theUserVideoControls
    }
    
    func getUserVideoControlWithPosition(_ position: UserVideoControlPosition) -> UserVideoControl? {
        for userVideoControl in userVideoControls {
            if userVideoControl.position.row == position.row && userVideoControl.position.column == position.column {
                return userVideoControl
            }
        }
        return nil
    }
    
    func refreshVideoCompositingLayout() -> Void {
        app.videoCompositingLayout!.regions.removeAllObjects()
        for userVideoControl in userVideoControls {
            if /*userVideoControl.user == nil*/ userVideoControl.deviceID == "" {
                continue
            }
            let theRegion = TTTRtcVideoCompositingRegion()
            theRegion.uid = userVideoControl.user!.userID
            theRegion.x = Double(userVideoControl.position.x)
            theRegion.y = Double(userVideoControl.position.y)
            theRegion.width = Double(userVideoControl.position.width)
            theRegion.height = Double(userVideoControl.position.height)
            theRegion.zOrder = userVideoControl.container.isHuge ? 0 : 1
            theRegion.alpha = 1.0
            theRegion.renderMode = .render_Adaptive
            app.videoCompositingLayout!.regions.add(theRegion)
        }
        app.rtcEngine.setVideoCompositingLayout(app.videoCompositingLayout)
    }
    
    @IBAction func copyUrlToClipboard(_ sender: Any) {
        //NSPasteboard.general.clearContents()
        NSPasteboard.general.declareTypes([.string], owner: nil)
        NSPasteboard.general.setString(textFieldRtmpUrl.stringValue, forType: .string)
        ProgressHUD.showInfoWithStatus("拉流地址已复制到剪贴板")
    }
    
    @IBAction func playPauseSoundEffect_1(_ sender: NSButton) {
        if sender.tag == 0 {
            let musicPath = Bundle.main.path(forResource: "forever", ofType: "mp3")
            app.rtcEngine.playEffect(1, filePath: musicPath, loopCount: 1, pitch: 1, pan: 1, gain: 1, publish: true)
            sender.tag = 1
        } else if sender.tag == 1 {
            app.rtcEngine.pauseEffect(1)
            sender.tag = 2
        } else {
            app.rtcEngine.resumeEffect(1)
            sender.tag = 1
        }
        refreshSoundEffectButtons()
    }

    @IBAction func stopSoundEffect_1(_ sender: NSButton) {
        app.rtcEngine.stopEffect(1)
        buttonPlaySoundEffect1.tag = 0
        refreshSoundEffectButtons()
    }

    @IBAction func playPauseSoundEffect_2(_ sender: NSButton) {
        if sender.tag == 0 {
            let musicPath = "http://sc1.111ttt.cn/2017/1/05/09/298092042172.mp3"
            app.rtcEngine.playEffect(2, filePath: musicPath, loopCount: 1, pitch: 1, pan: 1, gain: 1, publish: true)
            sender.tag = 1
        } else if sender.tag == 1 {
            app.rtcEngine.pauseEffect(2)
            sender.tag = 2
        } else {
            app.rtcEngine.resumeEffect(2)
            sender.tag = 1
        }
        refreshSoundEffectButtons()
    }

    @IBAction func stopSoundEffect_2(_ sender: NSButton) {
        app.rtcEngine.stopEffect(2)
        buttonPlaySoundEffect2.tag = 0
        refreshSoundEffectButtons()
    }

    @IBAction func playPauseAllSoundEffect(_ sender: NSButton) {
        if sender.tag <= 1 {
            app.rtcEngine.pauseAllEffects()
            sender.tag = 2
            sender.title = "全部播放"
            sender.image = NSImage(named: "btn_player_play")
            buttonPlaySoundEffect1.tag = 2
            buttonPlaySoundEffect2.tag = 2
        } else if sender.tag == 2 {
            app.rtcEngine.resumeAllEffects()
            sender.tag = 1
            sender.title = "全部暂停"
            sender.image = NSImage(named: "btn_player_pause")
            buttonPlaySoundEffect1.tag = 1
            buttonPlaySoundEffect2.tag = 1
        }
        refreshSoundEffectButtons()
    }
    
    @IBAction func stopAllSoundEffect(_ sender: NSButton) {
        app.rtcEngine.stopAllEffects()
        buttonPauseAllSoundEffects.tag = 0
        buttonPauseAllSoundEffects.title = "全部暂停"
        buttonPauseAllSoundEffects.image = NSImage(named: "btn_player_pause")
        
        buttonPlaySoundEffect1.tag = 0
        buttonPlaySoundEffect2.tag = 0
        refreshSoundEffectButtons()
    }
    
    func setButtonPlaying(_ sender: NSButton) {
        sender.title = "播放"
        sender.image = NSImage(named: "btn_player_play")
    }
    
    func setButtonPaused(_ sender: NSButton) {
        sender.title = "暂停"
        sender.image = NSImage(named: "btn_player_pause")
    }

    func refreshSoundEffectButtons() -> Void {
        if buttonPauseAllSoundEffects.tag > 0 {
            buttonPlaySoundEffect1.isEnabled = false
            buttonStopSoundEffect1.isEnabled = false
            buttonPlaySoundEffect2.isEnabled = false
            buttonStopSoundEffect2.isEnabled = false
            buttonPauseAllSoundEffects.isEnabled = true
            buttonStopAllSoundEffects.isEnabled = true
            
            if buttonPlaySoundEffect1.tag == 1 {
                setButtonPaused(buttonPlaySoundEffect1)
            } else {
                setButtonPlaying(buttonPlaySoundEffect1)
            }
            
            if buttonPlaySoundEffect2.tag == 1 {
                setButtonPaused(buttonPlaySoundEffect2)
            } else {
                setButtonPlaying(buttonPlaySoundEffect2)
            }
        } else {
            buttonPlaySoundEffect1.isEnabled = true
            buttonStopSoundEffect1.isEnabled = true
            buttonPlaySoundEffect2.isEnabled = true
            buttonStopSoundEffect2.isEnabled = true
            buttonPauseAllSoundEffects.isEnabled = false
            buttonStopAllSoundEffects.isEnabled = false
            
            if buttonPlaySoundEffect1.tag > 0 {
                if buttonPlaySoundEffect1.tag == 1 {
                    setButtonPaused(buttonPlaySoundEffect1)
                } else {
                    setButtonPlaying(buttonPlaySoundEffect1)
                }
                if buttonPlaySoundEffect2.tag > 0 {
                    if buttonPlaySoundEffect2.tag == 1 {
                        setButtonPaused(buttonPlaySoundEffect2)
                    } else {
                        setButtonPlaying(buttonPlaySoundEffect2)
                    }
                    
                    if buttonPlaySoundEffect1.tag == buttonPlaySoundEffect2.tag {
                        buttonPauseAllSoundEffects.isEnabled = true
                    }
                    buttonStopAllSoundEffects.isEnabled = true
                } else {
                    setButtonPlaying(buttonPlaySoundEffect2)
                    buttonStopSoundEffect2.isEnabled = false
                }
            } else if buttonPlaySoundEffect2.tag > 0 {
                setButtonPlaying(buttonPlaySoundEffect1)
                buttonStopSoundEffect1.isEnabled = false
                if buttonPlaySoundEffect2.tag == 1 {
                    setButtonPaused(buttonPlaySoundEffect2)
                } else {
                    setButtonPlaying(buttonPlaySoundEffect2)
                }
            } else {
                setButtonPlaying(buttonPlaySoundEffect1)
                buttonStopSoundEffect1.isEnabled = false
                setButtonPlaying(buttonPlaySoundEffect2)
                buttonStopSoundEffect2.isEnabled = false
            }
        }
    }

    func doExitRoom() -> Void {
        if audioMixingTimer != nil {
            audioMixingTimer!.invalidate()
            audioMixingTimer = nil
        }
        
        if buttonPauseAllSoundEffects.tag > 0 {
            app.rtcEngine.stopAllEffects()
        }
        if buttonPlaySoundEffect1.tag > 0 {
            app.rtcEngine.stopEffect(1)
        }
        if buttonPlaySoundEffect2.tag > 0 {
            app.rtcEngine.stopEffect(2)
        }
        
        app.rtcEngine.stopPreview()

        let mainStoryboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        let mainWindowController = mainStoryboard.instantiateInitialController() as! MainWindowController
        app.mainWindowController = mainWindowController
        mainWindowController.showWindow(nil)
        app.liveRoomWindowController?.close()
        app.liveRoomWindowController = nil
    }
    
    @IBAction func levelIndicatorSoloVolumeAction(_ sender: Any) {
        let scale: Int = levelIndicatorSoloVolume.integerValue * 10
        app.rtcEngine.adjustAudioMixingSoloVolume(scale)
    }
    
    @IBAction func levelIndicatorFileVolumeAction(_ sender: Any) {
        let scale: Int = levelIndicatorFileVolume.integerValue * 10
        app.rtcEngine.adjustAudioMixingPlayoutVolume(UInt(scale))
    }
    
    func setVideoWatermark() -> Void {
        if let imagePath = Bundle.main.path(forResource: "3ttech", ofType: "png") {
            let imageURL = URL(fileURLWithPath: imagePath)
            let imageWidth = 128
            let imageHeight = 128
            let imageX = stepperWaterMarkX.integerValue
            let imageY = stepperWaterMarkY.integerValue
            app.rtcEngine.addVideoWatermark(imageURL, rect: CGRect(x: imageX, y: imageY, width: imageWidth, height: imageHeight))
        }
    }
    
    @IBAction func setWaterMarkView(_ sender: NSButton) {
        if sender.state == .on {
            stepperWaterMarkX.isEnabled = true
            stepperWaterMarkY.isEnabled = true
            setVideoWatermark()
        } else {
            stepperWaterMarkX.isEnabled = false
            stepperWaterMarkY.isEnabled = false
            app.rtcEngine.clearVideoWatermarks()
        }
    }
    
    @IBAction func adjustWaterMarkPosition(_ sender: NSStepper) {
        labelWaterMarkX.stringValue = "\(stepperWaterMarkX.integerValue)"
        labelWaterMarkY.stringValue = "\(stepperWaterMarkY.integerValue)"
        setVideoWatermark()
    }
}

extension LiveRoomViewController: TTTRtcEngineDelegate {
    func rtcEngine(_ engine: TTTRtcEngineKit!, didOccurError errorCode: TTTRtcErrorCode) {
        var errorInfo = String()
        switch errorCode {
        case .error_NoAudioData:
            errorInfo = "长时间没有上行音频数据"
        case .error_NoVideoData:
            errorInfo = "长时间没有上行视频数据"
        case .error_NoReceivedAudioData:
            errorInfo = "长时间没有下行音频数据"
        case .error_NoReceivedVideoData:
            errorInfo = "长时间没有下行视频数据"
        default:
            errorInfo = "未知错误：\(errorCode)"
        }
        // app.showAlertError(self, informativeText: )
        ProgressHUD.showErrorWithStatus(errorInfo)
    }
    
    func rtcEngine(_ engine: TTTRtcEngineKit!, didKickedOutOfUid uid: Int64, reason: TTTRtcKickedOutReason) {
        var errorInfo = String()
        switch reason {
        case .kickedOut_KickedByHost:
            errorInfo = "被主播踢出"
        case .kickedOut_PushRtmpFailed:
            errorInfo = "rtmp推流失败"
        case .kickedOut_ServerOverload:
            errorInfo = "服务器过载"
        case .kickedOut_MasterExit:
            errorInfo = "主播已退出"
        case .kickedOut_ReLogin:
            errorInfo = "重复登录"
        case .kickedOut_NoAudioData:
            errorInfo = "长时间没有上行音频数据"
        case .kickedOut_NoVideoData:
            errorInfo = "长时间没有上行视频数据"
        case .kickedOut_NewChairEnter:
            errorInfo = "其他人以主播身份进入"
        case .kickedOut_ChannelKeyExpired:
            errorInfo = "Channel Key失效"
        default:
            errorInfo = "未知错误"
        }
        // app.showAlertError(self, informativeText: )
        ProgressHUD.showErrorWithStatus(errorInfo)
    }
    
    func rtcEngine(_ engine: TTTRtcEngineKit!, didLeaveChannelWith stats: TTTRtcStats!) {
        doExitRoom()
    }
    
    func rtcEngineReconnectServerTimeout(_ engine: TTTRtcEngineKit!) {
        app.rtcEngine.leaveChannel(nil)
        doExitRoom()
    }
    
    func rtcEngine(_ engine: TTTRtcEngineKit!, didJoinedOfUid uid: Int64, clientRole: TTTRtcClientRole, isVideoEnabled: Bool, elapsed: Int) {
        if app.userMe!.isAnchor && app.userArray.count > 16 {
            app.rtcEngine.kickChannelUser(uid)
            return
        }
        
        let remoteUser = TTTUser(sessionID: app.userMe!.sessionID, userID: uid, userType: .remoteUser, clientRole: clientRole)
        app.userArray.append(remoteUser)
        
        if clientRole == .clientRole_Anchor {
            app.userAnchor = remoteUser
        }
        
//        switch clientRole {
//        case .clientRole_Anchor:
//            anchorIDLabel.text = "\(uid)"
//        case .clientRole_Broadcaster:
//            app.broadcasterCount += 1
//        case .clientRole_Audience:
//            app.audienceCount += 1
//        }
//        NotificationCenter.default.post(name: NSNotification.Name("RefreshSettingView"), object: nil)
    }
    
    func rtcEngine(_ engine: TTTRtcEngineKit!, didOfflineOfUid uid: Int64, reason: TTTRtcUserOfflineReason) {
        guard let theUser = app.user(userID: Int64(uid)) else {
            return
        }
        
        let theControls = self.getUserVideoControlWithUser(theUser)
        for theControl in theControls {
            theControl.showButtonsBox(false)
            theControl.closeVideoDevice()
        }
        
        if app.channelProfile == .channelProfile_LiveBroadcasting {
            if app.userMe!.isAnchor {
                refreshVideoCompositingLayout()
            }
        }
        
        if let userIndex = app.userArray.firstIndex(of: theUser) {
            app.userArray.remove(at: userIndex)
        }
    }
    
    func rtcEngine(_ engine: TTTRtcEngineKit!, didVideoEnabled enabled: Bool, deviceId devId: String!, byUid uid: Int64) {
        guard let theUser = app.user(userID: uid) else {
            return
        }
        
        if let theControl = getUserVideoControlWithDeviceID(devId) {
            theControl.enableVideo(enabled)
            if app.userMe!.isAnchor {
                theControl.showButtonsBox(true)
            }
        } else {
            if let remoteControl = getAvailableUserVideoControl() {
                remoteControl.initWith(user: theUser, deviceID: devId, viewRenderMode: .render_Fit)
                if enabled {
                    if app.userMe!.isAnchor {
                        remoteControl.showButtonsBox(true)
                    }
                }
            }
        }
        
        if app.channelProfile == .channelProfile_LiveBroadcasting {
            if app.userMe!.isAnchor {
                refreshVideoCompositingLayout()
            }
        }
    }
    
    func rtcEngine(_ engine: TTTRtcEngineKit!, localAudioStats stats: TTTRtcLocalAudioStats!) {
        DispatchQueue.main.async {
            if let localControl = self.getUserVideoControlWithDeviceID(app.rtcEngine.defaultVideoDeviceID) {
                localControl.setLocalAudioStats(stats)
            }
        }
    }
    
    func rtcEngine(_ engine: TTTRtcEngineKit!, localVideoStats stats: TTTRtcLocalVideoStats!) {
        DispatchQueue.main.async {
            if let localControl = self.getUserVideoControlWithDeviceID(app.rtcEngine.defaultVideoDeviceID) {
                localControl.setLocalVideoStats(stats)
            }
        }
    }
    
    func rtcEngine(_ engine: TTTRtcEngineKit!, remoteAudioStats stats: TTTRtcRemoteAudioStats!) {
        DispatchQueue.main.async {
            if let remoteUser = app.user(userID: Int64(stats.uid)) {
                let remoteControls = self.getUserVideoControlWithUser(remoteUser)
                for remoteControl in remoteControls {
                    remoteControl.setRemoteAudioStats(stats)
                }
            }
        }
    }
    
    func rtcEngine(_ engine: TTTRtcEngineKit!, remoteVideoStats stats: TTTRtcRemoteVideoStats!) {
        DispatchQueue.main.async {
            if let remoteControl = self.getUserVideoControlWithDeviceID(stats.deviceId) {
                remoteControl.setRemoteVideoStats(stats)
            }
        }
    }
    
    func rtcEngine(_ engine: TTTRtcEngineKit!, reportAudioLevel userID: Int64, audioLevel: UInt, audioLevelFullRange: UInt) {
        DispatchQueue.main.async {
            if let theUser = app.user(userID: userID) {
                let theControls = self.getUserVideoControlWithUser(theUser)
                for theControl in theControls {
                    theControl.setAudioLevel(audioLevel)
                }
            }
        }
    }
    
    func rtcEngine(_ engine: TTTRtcEngineKit!, onSetVideoCompositingLayout layout: TTTRtcVideoCompositingLayout!) {
        /*
        if app.userMe!.isAnchor {
            return
        }
        
        for region in layout.regions as! [TTTRtcVideoCompositingRegion] {
            guard let theUser = app.user(userID: region.uid) else {
                continue
            }
            
            if theUser.isAnchor && userVideoContainerHuge.userVideoControl.user == nil {
                userVideoContainerHuge.userVideoControl.initWith(user: theUser, deviceID: region.deviceId, viewRenderMode: .render_Fit)
                continue
            }
            
            if getUserVideoControlWithDeviceID(region.deviceId) != nil {
                continue
            }
            
            let position = UserVideoControlPosition(x: region.x, y: region.y, width: region.width, height: region.height)
            if let theControl = getUserVideoControlWithPosition(position) {
                theControl.initWith(user: theUser, deviceID: region.deviceId, viewRenderMode: .render_Fit)
                
                if theUser.isMe {
//                    myVideoControl = theControl
//                    if viewDidAppeared {
//                        adjustMyButtonsPosition()
//                    }
                }
            }
            
//            if let theControl = getAvailableUserVideoControlButHuge() {
//                theControl.initWith(user: theUser, viewRenderMode: .render_Adaptive)
//            }
        }
        */
    }
    
    func rtcEngine(_ engine: TTTRtcEngineKit!, localAudioData data: UnsafeMutablePointer<Int8>!, dataSize size: UInt, sampleRate: UInt,
                   channels: UInt) {
        // dataSize=640,  channels=1
        // dataSize=1920, channels=2
        //NSLog("%@", "localAudioData: dataSize=\(size), sampleRate=\(sampleRate) channels=\(channels)")
    }
    
    func rtcEngine(_ engine: TTTRtcEngineKit!, remoteAudioData data: UnsafeMutablePointer<Int8>!, dataSize size: UInt, sampleRate: UInt,
                   channels: UInt) {
        //NSLog("%@", "remoteAudioData: dataSize=\(size), sampleRate=\(sampleRate) channels=\(channels)")
    }
    
    func rtcEngineAudioMixingDidStart(_ engine: TTTRtcEngineKit!) {
        let audioMixingDuration = app.rtcEngine.getAudioMixingDuration()
        sliderAudioMixing.intValue = 0
        sliderAudioMixing.maxValue = Double(audioMixingDuration)
        labelRemainSeconds.isHidden = false
        let remainSeconds = audioMixingDuration / 1000
        labelRemainSeconds.stringValue = "\(remainSeconds)"
        audioMixingTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(audioMixingTimerFired(theTimer:)), userInfo: nil, repeats: true)
        RunLoop.current.add(audioMixingTimer!, forMode: .common)
    }
    
    func rtcEngineAudioMixingDidFinish(_ engine: TTTRtcEngineKit!) {
        doStopAudioMixing()
    }
    
    func rtcEngine(_ engine: TTTRtcEngineKit!, lastmileQuality quality: TTTNetworkQuality) {
        var networkQuality: String
        switch quality {
        case .excellent:
            networkQuality = "excellent"
        case .good:
            networkQuality = "good"
        case .common:
            networkQuality = "common"
        case .poor:
            networkQuality = "poor"
        case .bad:
            networkQuality = "bad"
        default:
            networkQuality = "down"
        }
        NSLog("lastmileQuality: \(networkQuality)")
    }
    
//    func rtcEngine(_ engine: TTTRtcEngineKit!, onVideoNetWrapperSendData localVideoSentBitrate: UInt) {
//        let thisTime = Date()
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "HH:mm:ss.SSS"
//        textViewOutput.string.append("\(dateFormatter.string(from: thisTime))  SendData: \(sendDataCount)\n")
//        textViewOutput.scrollLineDown(nil)
//    }
    
    func rtcEngine(_ engine: TTTRtcEngineKit!, didAudioRouteChanged routing: TTTRtcAudioOutputRouting) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "AudioRouteChanged"), object: nil)
    }
}

extension LiveRoomViewController: NSTabViewDelegate {
    func tabView(_ tabView: NSTabView, shouldSelect tabViewItem: NSTabViewItem?) -> Bool {
        if let tabIdentifier = tabViewItem?.identifier as? String {
            if tabIdentifier == "AudioMixing" {
                if buttonPauseAllSoundEffects.tag > 0 || buttonPlaySoundEffect1.tag > 0 || buttonPlaySoundEffect2.tag > 0 {
                    ProgressHUD.showInfoWithStatus("请停止播放音效！")
                    return false
                }
                
            } else if tabIdentifier == "SoundEffect" {
                if audioMixingStatus > 0 {
                    ProgressHUD.showInfoWithStatus("请停止播放伴奏！")
                    return false
                }
            }
        }
        return true
    }
}
