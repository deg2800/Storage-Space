//
//  StorageInfo.swift
//  Storage Space
//
//  Created by Derrick Goodfriend on 10/7/24.
//

import Foundation

struct VolumeInfo: Identifiable {
    let id: String
    let name: String
    let totalSpace: Int64
    let freeSpace: Int64
    let url: URL
    let type: String
}

func getVolumeStorageInfo() -> [VolumeInfo] {
    var volumesInfo: [VolumeInfo] = []
    var addedVolumeNames: Set<String> = []

    let fileManager = FileManager.default
    let resourceKeys: Set<URLResourceKey> = [
        .volumeNameKey,
        .volumeTotalCapacityKey,
        .volumeAvailableCapacityKey,
        .volumeIsInternalKey,
        .volumeIsRemovableKey,
        .volumeIsEjectableKey,
        .volumeTypeNameKey,
        .volumeIdentifierKey
    ]

    let mountedVolumes = fileManager.mountedVolumeURLs(includingResourceValuesForKeys: Array(resourceKeys), options: [.skipHiddenVolumes])

    mountedVolumes?.forEach { url in
        do {
            let resourceValues = try url.resourceValues(forKeys: resourceKeys)

            guard let volumeName = resourceValues.volumeName,
                  let totalCapacity = resourceValues.volumeTotalCapacity,
                  let availableCapacity = resourceValues.volumeAvailableCapacity,
                  let volumeType = resourceValues.volumeTypeName,
                  let volumeIdentifier = resourceValues.volumeIdentifier else {
                return
            }

            if !addedVolumeNames.contains(volumeName) && volumeType != "smbfs" {
                volumesInfo.append(VolumeInfo(id: volumeIdentifier.description, name: volumeName, totalSpace: Int64(totalCapacity), freeSpace: Int64(availableCapacity), url: url, type: volumeType))
                addedVolumeNames.insert(volumeName)
                print(url.absoluteString)
            }
        } catch {
            print("Error retrieving storage information for volume: \(error)")
        }
    }

    return volumesInfo
}
