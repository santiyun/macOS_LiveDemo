//
//  LoginViewController.swift
//  TTTRtcEngineDemo
//
//  Created by doubon on 2018/7/8.
//  Copyright © 2018年 3ttech. All rights reserved.
//

import Cocoa

class LoginViewController: NSViewController {
    @IBOutlet weak var textFieldIP: NSTextField!
    @IBOutlet weak var textFieldPort: NSTextField!
    @IBOutlet weak var textFieldSessionID: NSTextField!
    @IBOutlet weak var textFieldUserID: NSTextField!
    @IBOutlet weak var textFieldRtmpUrl: NSTextField!
    @IBOutlet weak var buttonRoleAnchor: NSButton!
    @IBOutlet weak var buttonRoleBroadcaster: NSButton!
    @IBOutlet weak var buttonRoleAudience: NSButton!
    @IBOutlet weak var comboBoxCamera: NSComboBox!
    @IBOutlet weak var comboBoxMicrophone: NSComboBox!
    @IBOutlet weak var comboBoxSpeaker: NSComboBox!
    @IBOutlet weak var comboBoxVideoProfile: NSComboBox!
    @IBOutlet weak var textFieldFrameRate: NSTextField!
    @IBOutlet weak var textFieldBitRate: NSTextField!
    @IBOutlet weak var buttonEnterRoom: NSButton!
    @IBOutlet weak var buttonExitApp: NSButton!
    
    private var roleButtons: [NSButton]!
    private var clientRole: TTTRtcClientRole!
    private var videoCaptureDevices: [AVCaptureDevice]!
    private var audioCaptureDevices: [TTTRtcAudioDevice]!
    private var audioPlayoutDevices: [TTTRtcAudioDevice]!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        roleButtons = [buttonRoleAnchor, buttonRoleBroadcaster, buttonRoleAudience]
        
        // 读取进入房间的参数
        textFieldIP.stringValue = UserDefaults.standard.string(forKey: "EnterIP") ?? ""
        textFieldPort.stringValue = UserDefaults.standard.string(forKey: "EnterPort") ?? ""

        var sessionID = UserDefaults.standard.string(forKey: "EnterSessionID")
        if sessionID != nil && !sessionID!.isEmpty {
            textFieldSessionID.stringValue = sessionID!
        } else {
            sessionID = "\(arc4random() % 100000 + 1)"
            textFieldSessionID.stringValue = sessionID!
        }
        textFieldRtmpUrl.stringValue = "rtmp://push.3ttech.cn/sdk/\(sessionID!)"
        textFieldSessionID.delegate = self

        let userID = UserDefaults.standard.string(forKey: "EnterUserID")
        if userID != nil && !userID!.isEmpty {
            textFieldUserID.stringValue = userID!
        } else {
            textFieldUserID.stringValue = "\(arc4random() % 1000 + 1)"
        }
        
        let clientRoleValue = UserDefaults.standard.integer(forKey: "EnterClientRole")
        if clientRoleValue <= 0 || clientRoleValue > 3 {
            clientRole = .clientRole_Anchor
        } else {
            clientRole = TTTRtcClientRole(rawValue: UInt(clientRoleValue))
        }
        for button in roleButtons {
            if button.tag == clientRole.rawValue {
                button.state = NSControl.StateValue.on
                break
            }
        }
        
        let appID = "test900572e02867fab8131651339518"
        if app.rtcEngine == nil {
            app.rtcEngine = TTTRtcEngineKit.sharedEngine(withAppId: appID, delegate: self)
        } else {
            app.rtcEngine.delegate = self
        }
        app.rtcEngine.statsInterval = 1
        
        // 摄像头
        videoCaptureDevices = app.rtcEngine.videoCaptureDevices()
        comboBoxCamera.removeAllItems()
        for videoCaptureDevice in videoCaptureDevices {
            comboBoxCamera.addItem(withObjectValue: videoCaptureDevice.localizedName)
        }
        if comboBoxCamera.numberOfItems > 0 {
            comboBoxCamera.selectItem(at: 0)
        }
        
        // 麦克风
        audioCaptureDevices = app.rtcEngine.audioCaptureDevices()
        comboBoxMicrophone.removeAllItems()
        for audioCaptureDevice in audioCaptureDevices {
            if audioCaptureDevice.deviceType == .audioDevice_Input_ExternalMicrophone {
                comboBoxMicrophone.addItem(withObjectValue: audioCaptureDevice.deviceName!/* + "[外置麦克风]"*/)
            } else {
                comboBoxMicrophone.addItem(withObjectValue: audioCaptureDevice.deviceName!/* + "[内置麦克风]"*/)
            }
        }
        if comboBoxMicrophone.numberOfItems > 0 {
            comboBoxMicrophone.selectItem(at: 0)
        }

        // 扬声器
        fillAudioPlayoutDevices()
        
        // 采集分辨率
        //refreshVideoProfiles(videoCaptureDevice: videoCaptureDevices[comboBoxCamera.indexOfSelectedItem])

        // ProgressHUD
        ProgressHUD.setDefaultStyle(.light)
        ProgressHUD.setDefaultMaskType(.none)
        ProgressHUD.setDefaultPosition(.center)
        ProgressHUD.setDismissable(false)
        ProgressHUD.setContainerView(self.view)
    }
    
    func fillAudioPlayoutDevices() -> Void {
        audioPlayoutDevices = app.rtcEngine.audioPlayoutDevices()
        comboBoxSpeaker.removeAllItems()
        for audioPlayoutDevice in audioPlayoutDevices {
            if audioPlayoutDevice.deviceType == .audioDevice_Output_ExternalSpeaker {
                comboBoxSpeaker.addItem(withObjectValue: audioPlayoutDevice.deviceName!/* + "[外置扬声器]"*/)
            } else if audioPlayoutDevice.deviceType == .audioDevice_Output_Headphones {
                comboBoxSpeaker.addItem(withObjectValue: audioPlayoutDevice.deviceName! + "[耳机]")
            }
            else {
                comboBoxSpeaker.addItem(withObjectValue: audioPlayoutDevice.deviceName!/* + "[内置扬声器]"*/)
            }
        }
        if comboBoxSpeaker.numberOfItems > 0 {
            comboBoxSpeaker.selectItem(at: 0)
        }
    }
    
    func refreshVideoProfiles(videoCaptureDevice: AVCaptureDevice) -> Void {
        comboBoxVideoProfile.removeAllItems()
        if videoCaptureDevice.supportsSessionPreset(AVCaptureSession.Preset.hd1280x720) {
            comboBoxVideoProfile.insertItem(withObjectValue: "720P（1280x720）", at: 0)
        }
        if videoCaptureDevice.supportsSessionPreset(AVCaptureSession.Preset.qHD960x540) {
            comboBoxVideoProfile.insertItem(withObjectValue: "480P（848x480）", at: 0)
        }
        if videoCaptureDevice.supportsSessionPreset(AVCaptureSession.Preset.vga640x480) {
            comboBoxVideoProfile.insertItem(withObjectValue: "360P（640x360）", at: 0)
        }
        //let videoProfileValue = UserDefaults.standard.integer(forKey: "EnterVideoProfile")
        if comboBoxVideoProfile.numberOfItems > 0 {
            comboBoxVideoProfile.selectItem(at: 0)
        }
    }
    
    @IBAction func enterRoom(_ sender: Any) {
        // 数据输入校验
        // 校验IP地址
        let theIP = textFieldIP.stringValue
        if !theIP.isEmpty {
            let ipPattern = "^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$"
            let regularExpression = try! NSRegularExpression(pattern: ipPattern, options: [])
            let checkingResults = regularExpression.matches(in: theIP, options: [], range: NSMakeRange(0, theIP.count))
            if checkingResults.count <= 0 {
                app.showAlertError(self, informativeText: "“IP地址”输入不正确！")
                return
            }
        }
        
        // 校验端口
        var thePort = 0
        if !theIP.isEmpty {
            thePort = Int(textFieldPort.stringValue) ?? -1
            if thePort < 0 {
                app.showAlertError(self, informativeText: "“端口”输入不正确！")
                return
            }
        }
        
        let theSessionID: Int64 = Int64(textFieldSessionID.stringValue) ?? 0
        if theSessionID == 0 {
            app.showAlertError(self, informativeText: "“房间ID”输入不正确！")
            return
        }
        
        let theUserID: Int64 = Int64(textFieldUserID.stringValue) ?? 0
        if theUserID == 0 {
            app.showAlertError(self, informativeText: "“用户ID”输入不正确！")
            return
        }
        
        app.rtcEngine.setServerIp(theIP, port: Int32(thePort))
        app.channelProfile = .channelProfile_LiveBroadcasting
        app.rtcEngine.setChannelProfile(app.channelProfile)
        app.rtcEngine.setClientRole(clientRole)
        app.rtcEngine.enableVideo()
        app.rtcEngine.audioCaptureDevice = audioCaptureDevices[comboBoxMicrophone.indexOfSelectedItem]
        app.rtcEngine.audioPlayoutDevice = audioPlayoutDevices[comboBoxSpeaker.indexOfSelectedItem]
        app.rtcEngine.videoCaptureDevice = videoCaptureDevices[comboBoxCamera.indexOfSelectedItem]
        var videoSize: CGSize
        switch comboBoxVideoProfile.indexOfSelectedItem {
        case 1:
            app.videoProfile = ._VideoProfile_480P
            videoSize = CGSize(width: 848, height: 480)
        case 2:
            app.videoProfile = ._VideoProfile_720P
            videoSize = CGSize(width: 1280, height: 720)
        default:
            app.videoProfile = ._VideoProfile_360P
            videoSize = CGSize(width: 640, height: 360)
        }
        //app.rtcEngine.setVideoProfile(app.videoProfile, swapWidthAndHeight: false)
        let frameRate: UInt = UInt(textFieldFrameRate.intValue)
        let bitRate: UInt = UInt(textFieldBitRate.intValue)
        app.rtcEngine.setVideoProfile(videoSize, frameRate: frameRate, bitRate: bitRate)

        if clientRole == .clientRole_Anchor {
            let configBuilder = TTTPublisherConfigurationBuilder()
            configBuilder.setPublisherUrl(textFieldRtmpUrl.stringValue)
            app.rtcEngine.configPublisher(configBuilder.build())
        }
        app.rtcEngine.enableAudioVolumeIndication(200, smooth: 3)
        app.rtcEngine.enableAudioDataReport(true, remote: true)
        
        // 设置日志文件
        let directories = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = directories.first!
        var logFileName = String(format: "%@.log", arguments: [Bundle.main.infoDictionary![String(kCFBundleExecutableKey)] as! String])
        logFileName = NSString(string: documentsDirectory).appendingPathComponent(logFileName)
        app.rtcEngine.setLogFile(logFileName)
        app.rtcEngine.setLogFilter(.logFilter_Debug)
        
        // 保存输入数据
        UserDefaults.standard.set(textFieldIP.stringValue,        forKey: "EnterIP")
        UserDefaults.standard.set(textFieldPort.stringValue,      forKey: "EnterPort")
        UserDefaults.standard.set(textFieldSessionID.stringValue, forKey: "EnterSessionID")
        UserDefaults.standard.set(textFieldUserID.stringValue,    forKey: "EnterUserID")
        UserDefaults.standard.set(clientRole.rawValue,            forKey: "EnterClientRole")
        //UserDefaults.standard.set(app.videoProfile.rawValue,      forKey: "EnterVideoProfile")
        
        buttonEnterRoom.isEnabled = false
        buttonExitApp.isEnabled = false
        ProgressHUD.show(withStatus: "正在进入房间，请稍候……")
        
        let channelName = textFieldSessionID.stringValue
        let joinResult = app.rtcEngine.joinChannel(byKey: nil, channelName: channelName, uid: theUserID, joinSuccess: nil)
        if joinResult != 0 {
//            SVProgressHUD.dismiss()
        }
    }
    
    @IBAction func exitApplication(_ sender: Any) {
        NSApp.terminate(self)
        // exit(0)
    }
    
    @IBAction func selectUserRole(_ sender: NSButton) {
        clientRole = TTTRtcClientRole(rawValue: UInt(sender.tag))
    }
}

extension LoginViewController: NSTextFieldDelegate {
    func controlTextDidChange(_ obj: Notification) {
        let textField = obj.object as! NSTextField
        if textField.isEqual(textFieldSessionID) {
            textFieldRtmpUrl.stringValue = "rtmp://push.3ttech.cn/sdk/\(textFieldSessionID.stringValue)"
        }
    }
}

extension LoginViewController: NSComboBoxDelegate {
    func comboBoxSelectionDidChange(_ notification: Notification) {
        let comboBox = notification.object as! NSComboBox
        if comboBox.isEqual(comboBoxCamera) {
            refreshVideoProfiles(videoCaptureDevice: videoCaptureDevices[comboBoxCamera.indexOfSelectedItem])
        } else if comboBox.isEqual(comboBoxVideoProfile) {
            switch comboBoxVideoProfile.indexOfSelectedItem {
            case 1: // _VideoProfile_480P
                textFieldFrameRate.stringValue = "15"
                textFieldBitRate.stringValue = "600"
            case 2: // _VideoProfile_720P
                textFieldFrameRate.stringValue = "15"
                textFieldBitRate.stringValue = "1130"
            default: // _VideoProfile_360P
                textFieldFrameRate.stringValue = "15"
                textFieldBitRate.stringValue = "400"
            }
        }
    }
}

extension LoginViewController: TTTRtcEngineDelegate {
    func rtcEngine(_ engine: TTTRtcEngineKit!, didOccurError errorCode: TTTRtcErrorCode) {
        var errorInfo = ""
        switch errorCode {
        case .error_InvalidChannelName:
            errorInfo = "无效的房间名称"
        case .error_InvalidChannelKey:
            errorInfo = "无效的channelKey"
        case .error_Enter_TimeOut:
            errorInfo = "超时,10秒未收到服务器返回结果"
        case .error_Enter_Failed:
            errorInfo = "无法连接服务器"
        case .error_Enter_VerifyFailed:
            errorInfo = "验证码错误"
        case .error_Enter_BadVersion:
            errorInfo = "版本错误"
        case .error_Enter_Unknown:
            errorInfo = "未知错误"
        case .error_Enter_NoAnchor:
            errorInfo = "房间内没有主播"
        default:
            errorInfo = "未知错误：\(errorCode)"
        }
        // app.showAlertError(self, informativeText: errorInfo)
        ProgressHUD.showErrorWithStatus(errorInfo)
        
        buttonEnterRoom.isEnabled = true
        buttonExitApp.isEnabled = true
    }
    
    func rtcEngine(_ engine: TTTRtcEngineKit!, didJoinChannel channel: String!, withUid uid: Int64, elapsed: Int) {
        ProgressHUD.dismiss()

        let sessionID = Int64(textFieldSessionID.integerValue)
        let userID = Int64(textFieldUserID.integerValue)
        let user = TTTUser(sessionID: sessionID, userID: userID, userType: .me, clientRole: clientRole)
        app.userMe = user
        if user.isAnchor {
            app.userAnchor = user
        }
        app.userArray.removeAll()
        app.userArray.append(user)

        let liveRoomStoryboard = NSStoryboard(name: NSStoryboard.Name("LiveRoom"), bundle: nil)
        let liveRoomWindowController = liveRoomStoryboard.instantiateInitialController() as! LiveRoomWindowController
        app.liveRoomWindowController = liveRoomWindowController
        liveRoomWindowController.showWindow(self)
        //liveRoomWindowController.window?.makeKeyAndOrderFront(nil)
        app.mainWindowController?.close()
        app.mainWindowController = nil
    }
    
    func rtcEngine(_ engine: TTTRtcEngineKit!, didAudioRouteChanged routing: TTTRtcAudioOutputRouting) {
        fillAudioPlayoutDevices()
    }
}
