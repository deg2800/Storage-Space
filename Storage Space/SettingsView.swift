//
//  SettingsView.swift
//  Storage Space
//
//  Created by Derrick Goodfriend on 10/18/24.
//

import SwiftUI

struct SettingsView: View {
    @Environment(AppData.self) var appData
    @AppStorage("showVolumesPanel") var showVolumesPanel: Bool = true
    @AppStorage("showPercentFull") var showPercentFull: Bool = true
        
    var body: some View {
        @Bindable var appData = appData
        
        TabView {
            VStack {
                Form {
                    Toggle("Show Volumes Info Panel", isOn: $showVolumesPanel)
                }
                .padding()
                .onChange(of: showVolumesPanel) {
                    appData.showVolumesPanel = showVolumesPanel
                }
                .onAppear {
                    appData.showVolumesPanel = showVolumesPanel
                }
            }
            .tabItem {
                Label("App Settings", systemImage: "gear")
            }
            VStack {
                Form {
                    Toggle("Show Percent Full", isOn: $showPercentFull)
                    Text("SHOWING GAUGES AS PERCENT \(showPercentFull ? "FULL" : "FREE")")
                        .font(.caption)
                }
                .padding()
                .onChange(of: showPercentFull) {
                    appData.showPercentFull = showPercentFull
                }
                .onAppear {
                    appData.showPercentFull = showPercentFull
                }
            }
            .tabItem {
                Label("Info Panel", systemImage: "info.circle")
            }
        }
    }
}

#Preview {
    SettingsView()
}
