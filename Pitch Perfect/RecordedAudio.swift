//
//  RecordedAudio.swift
//  Pitch Perfect
//
//  Created by Sukh on 13/06/2015.
//  Copyright (c) 2015 Sukh Kalsi. All rights reserved.
//

import Foundation

final class RecordedAudio: NSObject{

    let filePathUrl: NSURL
    let title: String
    
    init(filePathUrl: NSURL, title: String) {
        self.filePathUrl = filePathUrl
        self.title = title
    }
}
