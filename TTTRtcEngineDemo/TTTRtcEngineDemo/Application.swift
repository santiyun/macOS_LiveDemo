//
//  Application.swift
//  TTTRtcEngineDemo
//
//  Created by doubon on 2017/8/19.
//  Copyright © 2017年 3ttech. All rights reserved.
//

import Cocoa

class Application: NSObject {
    private static let sharedInstance = Application.init()
    class var shared: Application {
        return sharedInstance
    }
    
    var rtcEngine: TTTRtcEngineKit!
    var channelProfile = TTTRtcChannelProfile.channelProfile_LiveBroadcasting
    var videoCompositingLayout: TTTRtcVideoCompositingLayout?
    lazy var userArray = [TTTUser]()
    weak var userMe: TTTUser?
    weak var userAnchor: TTTUser?
    
    var mainWindowController: MainWindowController?
    var liveRoomWindowController: LiveRoomWindowController?
    
    private override init() {
        super.init()
    }
    
    func user(index: Int) -> TTTUser? {
        let user = userArray[index]
        return user
    }
    
    func user(userID: Int64) -> TTTUser? {
        var theUser: TTTUser?
        for user in userArray {
            if user.userID == userID {
                theUser = user
                break
            }
        }
        return theUser
    }

    func showAlert(window: NSWindow?, alertStyle: NSAlert.Style, messageText: String, informativeText: String) -> Void {
        let alert = NSAlert()
        alert.messageText = messageText
        alert.informativeText = informativeText
        alert.addButton(withTitle: "确定")
        alert.alertStyle = alertStyle
        if window != nil {
            alert.beginSheetModal(for: window!, completionHandler: { (modalResponse: NSApplication.ModalResponse) in
            })
        } else {
            alert.runModal()
        }
    }
    
    func showAlertInfo(_ viewController: NSViewController?, informativeText: String) -> Void {
        DispatchQueue.main.async {
            self.showAlert(window: viewController?.view.window, alertStyle: .informational,
                           messageText: "提示", informativeText: informativeText)
        }
    }
    
    func showAlertWarning(_ viewController: NSViewController?, informativeText: String) -> Void {
        DispatchQueue.main.async {
            self.showAlert(window: viewController?.view.window, alertStyle: .critical,
                           messageText: "提示", informativeText: informativeText)
        }
    }
    
    func showAlertError(_ viewController: NSViewController?, informativeText: String) -> Void {
        DispatchQueue.main.async {
            self.showAlert(window: viewController?.view.window, alertStyle: .critical,
                           messageText: "提示", informativeText: informativeText)
        }
    }
}

let app: Application = Application.shared
