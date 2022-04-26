//
//  Constants.swift
//  ColorCoder
//
//  Created by Jelmer de Vries on 28/09/2019.
//  Copyright © 2019 Jelmer de Vries. All rights reserved.
//

import Foundation

struct ImageIdentifier {
    static let player   = "player"
    static let ball     = "projectile"
}

struct CategoryMask {
    static let paddle: UInt32   = 0x1 << 0
    static let ball: UInt32     = 0x1 << 1
    static let wall: UInt32     = 0x1 << 2
}
