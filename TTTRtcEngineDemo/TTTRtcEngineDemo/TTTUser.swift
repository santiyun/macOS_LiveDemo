import Cocoa

/// 用户类型
enum TTTUserType {
    case me
    case remoteUser
}

/// 用户类
class TTTUser: NSObject {
    private(set) var sessionID: Int64
    private(set) var userID: Int64
    private(set) var userType: TTTUserType
    private(set) var isMe: Bool
    var clientRole: TTTRtcClientRole
    var isSpeaking = false
    var isAnchor: Bool {
        return clientRole == .clientRole_Anchor
    }
    var isAudience: Bool {
        return clientRole == .clientRole_Audience
    }

    init(sessionID: Int64, userID: Int64, userType: TTTUserType, clientRole: TTTRtcClientRole) {
        self.sessionID = sessionID
        self.userID = userID
        self.userType = userType
        self.isMe = (userType == .me)
        self.clientRole = clientRole
    }
}

