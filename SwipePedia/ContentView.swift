//
//  ContentView.swift
//  SwipePedia
//
//  Created by Serkan Dogantekin on 16.02.2025.
//

import SwiftUI

class ContentViewModel: ObservableObject {
    @Published var isShowingSplash = true
    @Published var selectedTab = 0
}

struct ContentView: View {
    @StateObject private var bookmarkManager = BookmarkManager()
    @StateObject private var localizationManager = LocalizationManager.shared
    @StateObject private var viewModel = ContentViewModel()
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("appLanguage") private var appLanguage = AppLanguage.english.rawValue
    
    var body: some View {
        Group {
            if viewModel.isShowingSplash {
                SplashScreen(isShowingSplash: $viewModel.isShowingSplash)
            } else {
                TabView(selection: $viewModel.selectedTab) {
                    SwipeScreen()
                        .tabItem {
                            Label(LocalizedStringKey("Discover"), systemImage: "square.stack")
                        }
                        .tag(0)
                    
                    BookmarkScreen()
                        .tabItem {
                            Label(LocalizedStringKey("Bookmarks"), systemImage: "bookmark.fill")
                        }
                        .tag(1)
                    
                    SettingsScreen()
                        .tabItem {
                            Label(LocalizedStringKey("Settings"), systemImage: "gear")
                        }
                        .tag(2)
                }
                .tint(Color(hex: "93aec1"))
                .toolbarBackground(.white, for: .tabBar)
                .toolbarColorScheme(.light, for: .tabBar)
            }
        }
        .environment(\.locale, AppLanguage(rawValue: appLanguage)?.locale ?? .current)
        .environmentObject(bookmarkManager)
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
}

#Preview {
    ContentView()
}
