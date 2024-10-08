//
//  ContentView.swift
//  Storage Space
//
//  Created by Derrick Goodfriend on 10/7/24.
//

import SwiftUI

struct ContentView: View {
    @Environment(AppData.self) var appData
    @State private var folder: FolderItem?
    @State private var folderURL: URL?
    
    var body: some View {
        @Bindable var appData = appData
        VStack {
            if let folder = folder {
                if appData.showVolumesPanel {
                    VStack {
                        Text("Percent \(appData.showPercentFull ? "full" : "free") - all mounted volumes")
                            .textCase(.uppercase)
                            .font(.caption2)
                        StorageInfoView(volumes: getVolumeStorageInfo(), columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], showPercentFull: appData.showPercentFull)
                    }
                    .padding(.vertical, 10)
                    .background(Color.gray.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.bottom, 10)
                }
                VStack {
                    HStack {
                        Text("Selected folder: \(appData.selectedDirectory.path) [\(returnSizeFormattedString(appData.selectedDirectorySize))]")
                        Button("Select New Folder") {
                            selectFolder()
                        }.keyboardShortcut("s")
                        Button("Rescan Current Folder") {
                            self.folder = nil
                            loadFolderContents(from: appData.selectedDirectory)
                        }.keyboardShortcut("r")
                        .disabled(appData.scanInProgress)
                    }
                    if let volumeLabel = getVolumeLabel(for: appData.selectedDirectory.path) {
                        Text("Volume of selected folder: \(volumeLabel)")
                            .padding()
                    }
                    if let freeSpace = getFreeSpaceForVolume(containingPath: appData.selectedDirectory.path), let volumeSize = getTotalVolumeSizeForPath(appData.selectedDirectory.path), let volumeLabel = getVolumeLabel(for: appData.selectedDirectory.path) {
                        let percentFree = Int((Float(freeSpace)/Float(volumeSize)) * 100)
                        HStack {
                            ProgressView("Free space on selected volume [\(volumeLabel)]: \(returnSizeFormattedString(freeSpace)) / \(returnSizeFormattedString(volumeSize))", value: Float(freeSpace), total: Float(volumeSize))
                                .tint(percentFree > 50 ? .green : percentFree > 25 ? .yellow : .red)
                            Text("\(percentFree)% free")
                        }
                        .padding(.horizontal)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(Color.gray.opacity(0.25))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.bottom, 10)
                Picker("Sort By", selection: $appData.sortOrder) {
                    Text("Name Ascending (A-Z)")
                        .tag(SortOrder.nameAsc)
                    Text("Name Descending (Z-A)")
                        .tag(SortOrder.nameDesc)
                    Text("Size Ascending (Smallest First)")
                        .tag(SortOrder.sizeAsc)
                    Text("Size Descending (Largest First)")
                        .tag(SortOrder.sizeDesc)
                }
                Divider()
                ScrollView {
                    FolderView(folder: folder)
                }
            } else {
                VStack {
                    Text(appData.scanInProgress ? "Scanning file sizes..." : "Select folder and click Begin")
                        .onAppear {
                            loadSavedFolder()
                        }
                    Text("\(appData.scanInProgress ? "Current Directory" : "Selected Folder"): \(appData.currentDirectory.path)")
                    if !appData.scanInProgress {
                        Button("Select Folder") {
                            selectFolder()
                        }.keyboardShortcut("s")
                        .disabled(appData.scanInProgress)
                        Button("Begin") {
                            loadFolderContents(from: appData.selectedDirectory)
                        }.keyboardShortcut("b")
                        .disabled(appData.scanInProgress)
                    } else {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .scaleEffect(2.0)
                            .padding(.top, 40)
                    }
                }
            }
        }
        .padding()
    }
    
    func selectFolder() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        panel.prompt = "Select Folder"
        
        if panel.runModal() == .OK, let selectedURL = panel.urls.first {
            folder = nil
            folderURL = selectedURL
            saveBookmark(for: selectedURL)
            appData.selectedDirectory = selectedURL
            loadFolderContents(from: selectedURL)
        }
    }

    func saveBookmark(for url: URL) {
        do {
            let bookmark = try url.bookmarkData(options: [.withSecurityScope], includingResourceValuesForKeys: nil, relativeTo: nil)
            print("Bookmark data: \(bookmark.base64EncodedString(options: .lineLength64Characters))")
            UserDefaults.standard.set(bookmark, forKey: "savedFolderBookmark")
            appData.selectedDirectory = url
            print("Bookmark saved for \(url.path)")
        } catch {
            print("Failed to create bookmark for \(url): \(error)")
        }
    }

    func loadSavedFolder() {
        if let bookmarkData = UserDefaults.standard.data(forKey: "savedFolderBookmark") {
            do {
                print("Load Saved Folder, entering do")
                var isStale = false
                let url = try URL(resolvingBookmarkData: bookmarkData, options: [.withSecurityScope], relativeTo: nil, bookmarkDataIsStale: &isStale)
                print("URL: \(url.path)")
                if isStale {
                    print("Bookmark is stale. User needs to re-select the folder.")
                    selectFolder()
                } else {
                    if url.startAccessingSecurityScopedResource() {
                        print("If statement for security scope passed")
                        folderURL = url
                        appData.selectedDirectory = url
                        appData.currentDirectory = url
                        print(appData.selectedDirectory.path)
                        //loadFolderContents(from: url)
                    } else {
                        print("Failed to access folder: \(url.path)")
                    }
                }
            } catch {
                print("Failed to resolve bookmark: \(error)")
                selectFolder()
            }
        } else {
            selectFolder()
        }
    }

    func loadFolderContents(from url: URL) {
        @Bindable var appData = appData
        DispatchQueue.global(qos: .background).async {
            appData.scanInProgress = true
            let folderContents = getFolderContents(url: url, appData: $appData)
            DispatchQueue.main.async {
                print("async start")
                self.folder = folderContents
                appData.selectedDirectorySize = folderContents?.size ?? 0
                appData.scanInProgress = false
                print("async stop")
            }
        }
    }
}

#Preview {
    ContentView()
}
