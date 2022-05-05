//
//  UserProfile.swift
//  ColorCoder
//
//  Created by Jelmer de Vries on 03/05/2022.
//  Copyright © 2022 Jelmer de Vries. All rights reserved.
//

import Foundation

struct UserProfile: Codable {
    
    var initials: String
    var age: Int
    var sex: String
    
    init(_ userInfo: [ExperimentParameter: String]) {
        self.initials = userInfo[.initials]!
        self.age = Int(userInfo[.age]!)!
        self.sex = userInfo[.sex]!
    }
}
