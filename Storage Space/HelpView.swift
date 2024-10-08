//
//  HelpView.swift
//  Storage Space
//
//  Created by Derrick Goodfriend on 10/18/24.
//

import SwiftUI

struct HelpView: View {
    let appArticles: [HelpArticle] = [
        HelpArticle(title: "Overview", icon: "info.circle", body: """
                    Storage Space helps users monitor storage space by scanning the contents of a selected folder and displaying the size of each folder and file within it. Users can see how much space is occupied by individual files or folders, which is useful for managing storage. The app also visualizes the percentage of space used on each mounted volume (e.g., hard drives, external drives) to help with volume management.
                    
                    How to Use

                    1.    Select a Folder to Scan:
                        •    On the main screen, click the “Select Folder” button.
                        •    A dialog will appear allowing you to choose a folder on your system.
                        •    Once you’ve selected the folder, it will display the folder path on the main screen.
                    
                    2.    Begin the Scan:
                        •    After selecting the folder, click the “Begin” button to start scanning the folder.
                        •    The app will scan all files and subfolders inside the selected folder, calculating the size of each.
                        •    The scan will display these sizes along with a bar representing the size as a percentage.
                    
                    3.    Viewing Results:
                        •    After the scan is complete, a detailed list will be shown with the names of the files/folders and their sizes.
                        •    The app sorts results by name or size, as selected from the “Sort By” dropdown.
                        •    You can see a bar for each folder or file, showing its contribution to the overall space on the selected volume.
                    
                    4.    Volume Information:
                        •    On the top of the screen, you can view gauges representing the percent full of all mounted volumes.
                        •    Each volume is listed with its total capacity and free space available.
                    
                    5.    Rescan or Select New Folder:
                        •    Use the “Rescan Current Folder” button to refresh the results if the folder contents change.
                        •    To choose a different folder, click the “Select New Folder” button and repeat the process.
                    """),
        HelpArticle(title: "App Settings", icon: "gear", body: """
        Toggling the \"Show Volumes Info Panel\" checkbox under the \"App Settings\" tab will show the volume info panel at the top of the scan results screen when checked and hide it when unchecked.
        
        If the volumes info panel is shown, toggling the \"Show Percent Full\" checkbox under the \"Info Panel\" tab will make the gauges display the used space percentage when checked, and the free space percentage when unchecked. 
        """),
        HelpArticle(title: "FAQ", icon: "questionmark", body: """
        1. What does the app do?

        The app scans a selected folder and displays the size of each file and subfolder, allowing you to visualize how much space is being used. It also shows the overall percentage of disk space used for all mounted volumes, making it easier to monitor storage usage.

        2. How do I select a folder to scan?

        Click the “Select Folder” button on the main screen, then choose a folder from the dialog that appears. Once selected, the folder path will be displayed on the screen.

        3. What does the percentage gauge represent?

        The percentage gauge represents the amount of storage space used on each mounted volume (e.g., your internal hard drive or external drives). It shows both the percentage of space used and the free space available on each volume.

        4. Can I sort the results?

        Yes. You can sort the folder and file results by name or size using the “Sort By” dropdown in the main window.

        5. How can I view updated results after modifying the contents of a folder?

        If you add or remove files from the selected folder after scanning, click the “Rescan Current Folder” button to refresh the results.

        6. What does the progress bar next to each folder/file represent?

        The progress bar shows the percentage of space that a specific file or folder occupies relative to the total space on the selected volume.

        7. How can I see storage usage as a percentage for mounted volumes?

        To view the percentage of storage space used for each mounted volume, make sure the “Show Percent Full” checkbox is selected in the “Info Panel” settings.

        8. Can I scan a different folder?

        Yes, click the “Select New Folder” button to choose a different folder, then click “Begin” to scan the new folder.

        9. What does the “Show Volumes Info Panel” setting do?

        When enabled, this setting shows or hides the information panel that displays the volume details at the top of the main window.
        """)
    ]
    
    let widgetArticles: [HelpArticle] = [
        HelpArticle(title: "Adding Widget", icon: "widget.small.badge.plus", body: """
        To add a widget to the desktop, control click / right click the desktop and select 'Edit Widgets...'
        
        Scroll throught the list or search for 'Storage Space'
        
        There are three sizes to choose from:
        •    Small (Displays system volume only)
        •    Medium (Displays system volume plus up to 3 additional mounted volumes in alphabetical order)
        •    Large (Displays system volume plus up to 7 additional mounted volumes in alphabetical order)
        
        Clicking a widget will add it to the desktop in the first available spot starting in the top left corner of your main display. Clicking and dragging the widget to the desktop allows you to place the widget wherever you would like.
        """)
    ]

    var body: some View {
        HelpListView(articles: appArticles, widgetArticles: widgetArticles)
    }
}

struct HelpListView: View {
    let articles: [HelpArticle]
    let widgetArticles: [HelpArticle]
        
    var body: some View {
        NavigationSplitView {
            if !articles.isEmpty {
                List {
                    Section("App Help") {
                        ForEach(articles) { article in
                            NavigationLink {
                                HelpArticleView(article: article)
                            } label: {
                                Label(article.title, systemImage: article.icon)
                            }
                        }
                    }
                    Section("Widget Help") {
                        ForEach(widgetArticles) { article in
                            NavigationLink {
                                HelpArticleView(article: article)
                            } label: {
                                Label(article.title, systemImage: article.icon)
                            }
                        }
                    }

                }
                .navigationTitle("Help")
            }
        } detail: {
            if !articles.isEmpty {
                HelpArticleView(article: articles[0])
            } else {
                Text("No articles available")
            }
        }
    }
}

struct WidgetHelpListView: View {
    let articles: [HelpArticle]
    
    @State var selection: HelpArticle?
    
    var body: some View {
        if !articles.isEmpty {
            List(articles, selection: $selection) { article in
                NavigationLink {
                    HelpArticleView(article: article)
                } label: {
                    Label(article.title, systemImage: article.icon)
                }
                
            }
            .onAppear {
                if selection == nil {
                    if !articles.isEmpty {
                        selection = articles.first
                    }
                }
            }
        }
    }
}

struct HelpArticleView: View {
    let article: HelpArticle
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text(article.title)
                    .font(.title)
                Divider()
                Text(article.body)
                    .padding(.top, 10)
            }
            .padding()
        }
    }
}

struct HelpArticle: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let icon: String
    let body: String
}

#Preview {
    HelpView()
}
