//
//  Note.swift
//  MilestoneProject7
//
//  Created by John Nyquist on 4/26/19.
//  Copyright © 2019 Nyquist Art + Logic LLC. All rights reserved.
//

import Foundation

class Folder: NSObject, Codable {
    var name: String
    var noteCount: Int
    var dateCreated: Date
    
    init(name: String,
         noteCount: Int,
         dateCreated: Date) {
        self.name = name
        self.noteCount = noteCount
        self.dateCreated = dateCreated
    }
}
