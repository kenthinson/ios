//
//  FileProviderEnumeratorWorkingSet.swift
//  PickerFileProvider
//
//  Created by Marino Faggiana on 30/04/18.
//  Copyright © 2018 TWS. All rights reserved.
//
//  Author Marino Faggiana <m.faggiana@twsweb.it>
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import FileProvider

class FileProviderEnumeratorWorkingSet: NSObject, NSFileProviderEnumerator {
    
    var enumeratedItemIdentifier: NSFileProviderItemIdentifier
    
    init(enumeratedItemIdentifier: NSFileProviderItemIdentifier) {
        self.enumeratedItemIdentifier = enumeratedItemIdentifier
        super.init()
    }
    
    func invalidate() {
    }
    
    func enumerateItems(for observer: NSFileProviderEnumerationObserver, startingAt page: NSFileProviderPage) {
        
        var items: [NSFileProviderItemProtocol] = []
        
        // Tag
        let tags = NCManageDatabase.sharedInstance.getTags(predicate: NSPredicate(format: "account = %@", account))
        for tag in tags {
            
            if let metadata = NCManageDatabase.sharedInstance.getMetadata(predicate: NSPredicate(format: "account = %@ AND fileID = %@", account, tag.fileID))  {
                
                createFileIdentifierOnFileSystem(itemIdentifier: metadata.fileID, fileName: metadata.fileNameView)                
                let parentItemIdentifier = getDirectoryParent(metadataDirectoryID: metadata.directoryID)
                if parentItemIdentifier != nil {
                    let item = FileProviderItem(metadata: metadata, parentItemIdentifier: parentItemIdentifier!)
                    items.append(item)
                }
            }
        }
        
        // Favorite Directory
        /*
        listFavoriteIdentifierRank = NCManageDatabase.sharedInstance.getTableMetadatasDirectoryFavoriteIdentifierRank()
        for (identifier, _) in listFavoriteIdentifierRank {
            
            guard let metadata = NCManageDatabase.sharedInstance.getMetadata(predicate: NSPredicate(format: "account = %@ AND fileID = %@", account, identifier)) else {
                continue
            }
            guard let serverUrl = NCManageDatabase.sharedInstance.getServerUrl(metadata.directoryID) else {
                continue
            }
            // Create FS
            createFileIdentifier(itemIdentifier: metadata.fileID, fileName: metadata.fileNameView)
            let item = FileProviderItem(metadata: metadata, serverUrl: serverUrl)
            items.append(item)
        }
        */
        
        observer.didEnumerate(items)
        observer.finishEnumerating(upTo: nil)
    }
    
    func enumerateChanges(for observer: NSFileProviderChangeObserver, from anchor: NSFileProviderSyncAnchor) {
        observer.didUpdate(listUpdateItems)
        observer.finishEnumeratingChanges(upTo: anchor, moreComing: false)
    }
    
    func currentSyncAnchor(completionHandler: @escaping (NSFileProviderSyncAnchor?) -> Void) {
        
        setupActiveAccount()
        
        let anchor = NSFileProviderSyncAnchor("WorkingSet".data(using: .utf8)!)
        completionHandler(anchor)
    }
}
