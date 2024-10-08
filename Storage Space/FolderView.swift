//
//  FolderView.swift
//  Storage Space
//
//  Created by Derrick Goodfriend on 10/16/24.
//

import SwiftUI

struct FolderView: View {
    @Environment(AppData.self) var appData
    let folder: FolderItem
    var background = false
    
    var body: some View {
        DisclosureGroup {
            if let children = folder.children {
                ForEach(sortedChildren(children)) { child in
                    FolderView(folder: child, background: !background)
                        .padding(.leading, 10)
                }
            }
        } label: {
            VStack(alignment: .leading) {
                Text("\(folder.name) [\(returnSizeFormattedString(folder.size))]")
                FileSizeBarView(fileSize: folder.size, totalSize: appData.selectedDirectorySize)
            }
            .background(background ? Color.gray.opacity(0.2) : nil)
        }

    }
    
    func sortedChildren(_ children: [FolderItem]) -> [FolderItem] {
        switch appData.sortOrder {
            case .nameAsc:
                return children.sorted(by: {$0.name < $1.name})
            case .nameDesc:
                return children.sorted(by: {$0.name > $1.name})
            case .sizeAsc:
                return children.sorted(by: {$0.size < $1.size})
            case .sizeDesc:
                return children.sorted(by: {$0.size > $1.size})
        }
    }
    
}

#Preview {
    FolderView(folder: FolderItem(name: "Macintosh HD", size: 564823648, children: nil))
}

func returnSizeFormattedString(_ sizeInBytes: Int64) -> String {
    let sizeInTB = Double(sizeInBytes) / 1_000_000_000_000
    let sizeInGB = Double(sizeInBytes) / 1_000_000_000
    let sizeInMB = Double(sizeInBytes) / 1_000_000
    let sizeInKB = Double(sizeInBytes) / 1_000

    if sizeInTB >= 1 {
        return String(format: "%.2f TB", sizeInTB)
    } else if sizeInGB >= 1 {
        return String(format: "%.2f GB", sizeInGB)
    } else if sizeInMB >= 1 {
        return String(format: "%.2f MB", sizeInMB)
    } else if sizeInKB >= 1 {
        return String(format: "%.2f KB", sizeInKB)
    } else {
        return String(format: "%d B", sizeInBytes)
    }
}
