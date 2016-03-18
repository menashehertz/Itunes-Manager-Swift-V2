//
//  SongNotes.swift
//  Itunes Manager
//
//  Created by Steven Hertz on 10/19/15.
//  Copyright © 2015 Steven Hertz. All rights reserved.
//

import Foundation


class SongNote: NSObject, NSCoding {
    var trackId: NSNumber = 0
    var note: String = " "
    var likeLevel: NSNumber = 0

    init(trackId: NSNumber, note: String, likeLevel: NSNumber) {
        self.trackId = trackId
        self.note = note
        self.likeLevel = likeLevel
    }
    
    
    // MARK: - NSCoding
    
    func encodeWithCoder(archiver: NSCoder) {
        archiver.encodeObject(trackId, forKey: "trackId")
        archiver.encodeObject(note, forKey: "note")
        archiver.encodeObject(likeLevel, forKey: "likeLevel")
    }
    
    required init(coder unarchiver: NSCoder) {
        super.init()
        trackId = unarchiver.decodeObjectForKey("trackId") as! NSNumber
        note = unarchiver.decodeObjectForKey("note") as! String
        likeLevel = unarchiver.decodeObjectForKey("likeLevel") as! NSNumber
    }
 
}

