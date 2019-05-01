//
// Created by John Nyquist on 2019-05-01.
// Copyright (c) 2019 Nyquist Art + Logic LLC. All rights reserved.
//

import Foundation

class Section: NSObject, Codable {
    var name: String
    var folders: [Folder]

    init(name: String,
         folders: [Folder]) {
        self.name = name
        self.folders = folders
        super.init()
    }
}

