//
//  Note.swift
//  MilestoneProject7
//
//  Created by John Nyquist on 4/26/19.
//  Copyright © 2019 Nyquist Art + Logic LLC. All rights reserved.
//

import Foundation

class Note: NSObject, Codable {
    var text: String
    var dateCreated: Date

    init(text: String,
         dateCreated: Date) {
        self.text = text
        self.dateCreated = dateCreated
    }

}
