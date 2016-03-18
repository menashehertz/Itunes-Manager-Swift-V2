//
//  MusicAlbum.swift
//  Itunes Manager
//
//  Created by Steven Hertz on 10/13/15.
//  Copyright © 2015 Steven Hertz. All rights reserved.
//

import Foundation
import CoreData

// available to Objective-C code
@objc(Album)


class Album : NSManagedObject{
    @NSManaged var collectionId: NSNumber
    @NSManaged var collectionName: String
    @NSManaged var artworkUrl60: String
    @NSManaged var artworkUrl100: String
    @NSManaged var collectionViewUrl: String
    @NSManaged var songs: [Song]
    
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    
    init(theDict: [String: AnyObject ], context: NSManagedObjectContext) {
        
        let entity =  NSEntityDescription.entityForName("Album", inManagedObjectContext: context)!
        super.init(entity: entity,insertIntoManagedObjectContext: context)

        self.collectionId =  theDict["collectionId"] as! Int
        self.collectionName = theDict["collectionName"] as! String
        self.artworkUrl60 = theDict["artworkUrl60"] as! String
        self.artworkUrl100 = theDict["artworkUrl100"] as! String
        self.collectionViewUrl =  theDict["collectionViewUrl"] as! String
    }
}