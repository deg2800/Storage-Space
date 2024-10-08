//
//  StorageInfoView.swift
//  Storage Space
//
//  Created by Derrick Goodfriend on 10/7/24.
//

import SwiftUI

struct StorageInfoView: View {
    var volumes: [VolumeInfo]
    
    var columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    var showPercentFull: Bool = true
    
    var body: some View {
        VStack {
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(volumes, id: \.name) { volume in
                    HStack {
                        let usedSpace = volume.totalSpace - volume.freeSpace
                        let usagePercentage = (Double(usedSpace) / Double(volume.totalSpace)) * 100
                        let usagePrecentInt = Int(usagePercentage)
                        
                        let freeSpacePercentage = (Double(volume.freeSpace) / Double(volume.totalSpace)) * 100
                        let freeSpacePrecentInt = Int(freeSpacePercentage)
                        
                        var percentage: Double {
                            if showPercentFull {
                                return usagePercentage
                            } else {
                                return freeSpacePercentage
                            }
                        }
                        
                        var percentInt: Int {
                            if showPercentFull {
                                return usagePrecentInt
                            } else {
                                return freeSpacePrecentInt
                            }
                        }
                        
                        Gauge(value: percentage, in: 0...100) {
                            Text(percentInt.description)
                                .foregroundStyle(getColor(for: usagePercentage))
                        }
                        .gaugeStyle(.accessoryCircularCapacity)
                        .tint(getColor(for: usagePercentage))
                        .minimumScaleFactor(0.5)
                        
                        VStack(alignment: .leading) {
                            Text(volume.name)
                                .font(.subheadline)
                            
                            let totalSpace = formatSize(volume.totalSpace)
                            let freeSpace = formatSize(volume.freeSpace)
                            
                            Text("\(totalSpace)\n\(freeSpace) free")
                                .font(.footnote)
                            Text("\(volume.type)")
                                .font(.footnote)
                        }
                    }
                    .frame(width: 140)
                }
            }
        }
    }
    
    private func formatSize(_ sizeInBytes: Int64) -> String {
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
    
    private func getColor(for percentage: Double) -> Color {
        switch percentage {
        case 75...100:
            return .red
        case 50...74:
            return .yellow
        default:
            return .green
        }
    }
}

#Preview {
    StorageInfoView(volumes: [VolumeInfo(id: "example", name: "Macintosh HD", totalSpace: 500000000000, freeSpace: 250000000000, url: URL.init(string: "file:///")!, type: "apfs")])
        .frame(maxWidth: .infinity)
}
