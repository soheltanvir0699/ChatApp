//
//  Room.swift
//  ChatAppRealtime
//
//  Created by Apple Guru on 29/11/19.
//  Copyright © 2019 Apple Guru. All rights reserved.
//

import UIKit

struct Room {
    var roomId: String?
    var roomName: String?
    init(roomName:String,roomId:String) {
        self.roomName = "🙋🏻‍♂️ \(roomName)"
        self.roomId = roomId
    }
}
