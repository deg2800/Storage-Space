//
//  AppIntent.swift
//  Storage Space Widget
//
//  Created by Derrick Goodfriend on 10/7/24.
//

import WidgetKit
import AppIntents

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "Storage Space" }
    static var description: IntentDescription { "Shows free space on mounted volumes" }

    @Parameter(title: "Update Interval (minutes)", default: 5)
        var updateInterval: Int
    @Parameter(title: "Show Percent Full", description: "Unchecked, values in the gauge will display the percentage of free space. Checked, it will display the percentage of used space.", default: true)
        var showPercentFull: Bool
}
