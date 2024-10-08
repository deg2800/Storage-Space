//
//  Storage_Space_Widget.swift
//  Storage Space Widget
//
//  Created by Derrick Goodfriend on 10/7/24.
//

import WidgetKit
import SwiftUI

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), volumes: [VolumeInfo(id: "example", name: "Macintosh HD", totalSpace: 500000000000, freeSpace: 250000000000, url: URL.init(string: "file:///")!, type: "apfs")])
    }
    
    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        let volumes = getVolumeStorageInfo()
        let limitedVolumes = limitVolumes(volumes: volumes, size: context.family)
        return SimpleEntry(date: Date(), volumes: limitedVolumes)
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        var entries: [SimpleEntry] = []
        let currentDate = Date()
        
        let volumes = getVolumeStorageInfo()
        
        let interval = configuration.updateInterval
        let showPercentFull = configuration.showPercentFull
        
        for minuteOffset in stride(from: 0, to: 60, by: interval) {
            let entryDate = Calendar.current.date(byAdding: .minute, value: minuteOffset, to: currentDate)!
            let limitedVolumes = limitVolumes(volumes: volumes, size: context.family)
            let entry = SimpleEntry(date: entryDate, volumes: limitedVolumes, showPercentfull: showPercentFull)
            entries.append(entry)
        }
        
        let nextRefresh = Calendar.current.date(byAdding: .minute, value: interval, to: currentDate)!
        return Timeline(entries: entries, policy: .after(nextRefresh))
    }
    
    func limitVolumes(volumes: [VolumeInfo], size: WidgetFamily) -> [VolumeInfo] {
            switch size {
            case .systemSmall:
                return Array(volumes.prefix(1))
            case .systemMedium:
                return Array(volumes.prefix(4))
            case .systemLarge:
                return Array(volumes.prefix(8))
            default:
                return volumes
            }
        }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let volumes: [VolumeInfo]
    var showPercentfull: Bool = true
}

struct Storage_Space_WidgetEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        VStack {
            Text(entry.showPercentfull ? "PERCENT FULL" : "PERCENT FREE")
                .font(.caption)
            StorageInfoView(volumes: entry.volumes, columns: entry.volumes.count == 1 ? [GridItem(.flexible())] : [GridItem(.flexible()), GridItem(.flexible())], showPercentFull: entry.showPercentfull)
        }
    }
}

struct Storage_Space_Widget: Widget {
    let kind: String = "Storage_Space_Widget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            Storage_Space_WidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
    }
}
