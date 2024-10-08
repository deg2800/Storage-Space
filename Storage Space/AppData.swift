//
//  AppData.swift
//  Storage Space
//
//  Created by Derrick Goodfriend on 10/16/24.
//

import Foundation

@Observable
class AppData {
    var currentDirectory: URL = URL.init(string: "/") ?? URL.homeDirectory
    var currentFile: URL = URL.init(string: "/") ?? URL.homeDirectory
    var sortOrder: SortOrder = .nameAsc
    var selectedDirectory: URL = URL.init(string: "/") ?? URL.homeDirectory
    var selectedDirectorySize: Int64 = 0
    var scanInProgress: Bool = false
    var showPercentFull: Bool = true
    var showVolumesPanel: Bool = true
}

enum SortOrder: CaseIterable {
    case nameAsc
    case nameDesc
    case sizeAsc
    case sizeDesc
}
