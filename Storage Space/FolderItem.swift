//
//  FolderItem.swift
//  Storage Space
//
//  Created by Derrick Goodfriend on 10/16/24.
//

import Foundation
import SwiftUI

struct FolderItem: Identifiable {
    let id = UUID()
    let name: String
    let size: Int64
    var children: [FolderItem]?
}

func getFolderSize(url: URL) -> Int64 {
    var folderSize: Int64 = 0
    let fileManager = FileManager.default
    
    if let enumerator = fileManager.enumerator(at: url, includingPropertiesForKeys: [.fileSizeKey], options: [], errorHandler: nil) {
        for case let fileURL as URL in enumerator {
            do {
                let resourceValues = try fileURL.resourceValues(forKeys: [.fileSizeKey])
                if let fileSize = resourceValues.fileSize {
                    folderSize += Int64(fileSize)
                }
            } catch {
                print("Error reading file size for \(fileURL): \(error)")
            }
        }
    }
    
    return folderSize
}

func getFolderContents(url: URL, appData: Bindable<AppData>) -> FolderItem? {
    let fileManager = FileManager.default
    var folderSize: Int64 = 0
    var children: [FolderItem] = []
    
    let excludedDirectories = [
        "/System",              // Sealed system volume
        "/System/Volumes/Data", // Separate data volume
        "/private/var",         // System caches
        "/Volumes"              // Mounted external volumes
    ]
    
    do {
        if excludedDirectories.contains(url.path) {
            return nil
        }

        let contents = try fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: [.isDirectoryKey, .fileSizeKey], options: [])
        
        for fileURL in contents {
            var isDirectory: ObjCBool = false
            fileManager.fileExists(atPath: fileURL.path, isDirectory: &isDirectory)
            
            if isDirectory.boolValue {
                print("Scanning directory \(fileURL.lastPathComponent)...")
                appData.wrappedValue.currentDirectory = fileURL
                if let childFolder = getFolderContents(url: fileURL, appData: appData) {
                    folderSize += childFolder.size
                    children.append(childFolder)
                }
            } else {
                print("Scanning file \(fileURL.lastPathComponent)...")
                appData.wrappedValue.currentFile = fileURL
                let fileSize = try fileURL.resourceValues(forKeys: [.fileSizeKey]).fileSize ?? 0
                folderSize += Int64(fileSize)
                children.append(FolderItem(name: fileURL.lastPathComponent, size: Int64(fileSize), children: nil))
            }
        }
    } catch {
        print("Error getting folder contents: \(error.localizedDescription)")
        return nil
    }
    
    return FolderItem(name: url.lastPathComponent, size: folderSize, children: children)
}
func getFreeSpaceForVolume(containingPath path: String) -> Int64? {
    var stat = statfs()
    
    if statfs(path, &stat) == 0 {
        let freeSpace = Int64(stat.f_bsize) * Int64(stat.f_bavail)
        return freeSpace
    } else {
        print("Error retrieveing volume information: \(path)")
        return nil
    }
}

func getFreeSpace(for volumeURL: URL) -> Int64? {
    do {
        let attributes = try FileManager.default.attributesOfFileSystem(forPath: volumeURL.path)
        
        if let freeSpace = attributes[.systemFreeSize] as? Int64 {
            return freeSpace
        }
    } catch {
        print("Error retrieving file system free size: \(error)")
    }
    
    return nil
}

func getTotalVolumeSizeForPath(_ path: String) -> Int64? {
    var stat = statfs()
    
    if statfs(path, &stat) == 0 {
        let totalSpace = Int64(stat.f_bsize) * Int64(stat.f_blocks)
        return totalSpace
    } else {
        print("Error retrieveing volume information: \(path)")
        return nil
    }
}

func getTotalVolumeSize(for volumeURL: URL) -> Int64? {
    do {
        let attributes = try FileManager.default.attributesOfFileSystem(forPath: volumeURL.path)
        
        if let volumeSize = attributes[.systemSize] as? Int64 {
            return volumeSize
        }
    } catch {
        print("Error retrieving file system total size: \(error)")
    }
    
    return nil
}

func getVolumeMountPoint(forPath path: String) -> String? {
    var url = URL(fileURLWithPath: path)
    
    while url.pathComponents.count > 1 {
        do {
            let resourceValues = try url.resourceValues(forKeys: [.isVolumeKey])
            
            if resourceValues.isVolume == true {
                return url.path
            }
        } catch {
            print("Error checking if URL is a volume: \(error)")
            return nil
        }
        
        url.deleteLastPathComponent()
    }
    
    return url.path
}

func getVolumeLabel(for path: String) -> String? {
    let url = URL(fileURLWithPath: path)
    
    do {
        let resourceValues = try url.resourceValues(forKeys: [.volumeNameKey])
        return resourceValues.volumeName
    } catch {
        print("Error retrieving volume label: \(error)")
        return nil
    }
}
