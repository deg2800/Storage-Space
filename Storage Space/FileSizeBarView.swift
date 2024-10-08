//
//  FileSizeBarView.swift
//  Storage Space
//
//  Created by Derrick Goodfriend on 10/16/24.
//

import SwiftUI

struct FileSizeBarView: View {
    let fileSize: Int64
    let totalSize: Int64

    var body: some View {
        ProgressView(value: Double(fileSize), total: Double(totalSize))
            .progressViewStyle(LinearProgressViewStyle())
            .frame(height: 10)
    }
}

#Preview {
    FileSizeBarView(fileSize: 100, totalSize: 1000)
}
