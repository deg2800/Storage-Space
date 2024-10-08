//
//  Storage_SpaceApp.swift
//  Storage Space
//
//  Created by Derrick Goodfriend on 10/7/24.
//

import SwiftUI

@main
struct Storage_SpaceApp: App {
    @State var appData = AppData()
    @AppStorage("showVolumesPanel") var showVolumesPanel: Bool = true
    @AppStorage("showPercentFull") var showPercentFull: Bool = true
    @Environment(\.openWindow) var openWindow
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appData)
                .onAppear {
                    appData.showVolumesPanel = showVolumesPanel
                    appData.showPercentFull = showPercentFull
                    NSWindow.allowsAutomaticWindowTabbing = false
                }
                .frame(minWidth: 750, idealWidth: 850, maxWidth: .infinity, minHeight: 475, idealHeight: 750, maxHeight: .infinity)
        }
        .commands {
            CommandGroup(replacing: CommandGroupPlacement.newItem) {
                Button("Select Folder") {
                    
                }.keyboardShortcut("s")
                    .disabled(true)
                Button("Begin Scan") {
                    
                }.keyboardShortcut("b")
                    .disabled(true)
                Button("Rescan Selected Folder") {
                    
                }.keyboardShortcut("r")
                    .disabled(true)
            }
            CommandGroup(replacing: CommandGroupPlacement.pasteboard) {
                
            }
            CommandGroup(replacing: CommandGroupPlacement.undoRedo) {
                
            }
            CommandGroup(replacing: .help) {
                Group {
                    Button("Help") {
                        openWindow(id: "helpView")
                    }.keyboardShortcut("p")
                    
                    Link("Developer Website", destination: URL(
                        string: "https://derrickgoodfriend.com/")!)
                    .keyboardShortcut("d")
                }
            }
        }
        Settings {
            SettingsView()
                .environment(appData)
                .frame(width: 300, height: 200)
        }
        Window("Help", id: "helpView") {
            HelpView()
                .navigationTitle("Help")
        }
    }
}
