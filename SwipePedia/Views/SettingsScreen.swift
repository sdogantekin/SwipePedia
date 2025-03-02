import SwiftUI
import MessageUI

struct SettingsScreen: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("appLanguage") private var appLanguage = AppLanguage.english.rawValue
    @EnvironmentObject private var bookmarkManager: BookmarkManager
    @StateObject private var localizationManager = LocalizationManager.shared
    @State private var showingResetAlert = false
    @State private var showingMailView = false
    @State private var mailResult: Result<MFMailComposeResult, Error>? = nil
    
    private func updateAppLanguage(to newValue: String) {
        withAnimation {
            localizationManager.updateLocale()
            WikipediaLanguageManager.shared.languageChanged()
            // Force view refresh
            bookmarkManager.objectWillChange.send()
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(hex: "f3b7ad").opacity(0.3),  // Soft pink
                        Color(hex: "93aec1").opacity(0.2)   // Blue-gray
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                List {
                    // Language Settings
                    Section(LocalizedStringKey("Language")) {
                        Picker(LocalizedStringKey("Content Language"), selection: $appLanguage) {
                            ForEach(AppLanguage.allCases) { language in
                                HStack(spacing: 12) {
                                    // Flag and native name only
                                    Text(language.flag)
                                        .font(.title2)
                                    Text(language.nativeName)
                                        .foregroundColor(.primary)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .tag(language.rawValue)
                            }
                        }
                        .pickerStyle(.navigationLink)
                        .onChange(of: appLanguage, initial: false) { oldValue, newValue in
                            FirebaseManager.shared.logLanguageChange(to: newValue)
                            updateAppLanguage(to: newValue)
                        }
                    }
                    .listRowBackground(Color.white)  // White background for list items
                    
                    // Theme Settings
                    Section(LocalizedStringKey("Appearance")) {
                        Toggle(isOn: $isDarkMode.animation()) {
                            Label {
                                Text(LocalizedStringKey("Dark Mode"))
                            } icon: {
                                Image(systemName: isDarkMode ? "moon.fill" : "moon")
                            }
                        }
                        .onChange(of: isDarkMode, initial: false) { oldValue, newValue in
                            FirebaseManager.shared.logThemeChange(isDark: newValue)
                        }
                        .tint(Color(hex: "9dbdba"))  // Sage green
                    }
                    .listRowBackground(Color.white)
                    
                    // Data Management
                    Section(LocalizedStringKey("Data")) {
                        Button(role: .destructive) {
                            showingResetAlert = true
                        } label: {
                            Label(LocalizedStringKey("Clear Saved Articles"), systemImage: "trash")
                        }
                        .foregroundColor(Color(hex: "ec6a52"))  // Coral red
                    }
                    .listRowBackground(Color.white)
                    
                    // About
                    Section(LocalizedStringKey("About")) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("SwipePedia")
                                .font(.headline)
                            Text(LocalizedStringKey("Version 1.0"))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text(LocalizedStringKey("App Description"))
                                .font(.footnote)
                                .foregroundColor(.secondary)
                                .padding(.top, 4)
                        }
                        .padding(.vertical, 8)
                    }
                    .listRowBackground(Color.white)
                    
                    // Contact
                    Section {
                        Button(action: {
                            if MFMailComposeViewController.canSendMail() {
                                showingMailView = true
                            } else {
                                // Handle case where mail isn't available
                                UIPasteboard.general.string = "developer@swipepedia.app"
                                // Show a toast or alert that email was copied
                            }
                        }) {
                            Label("Contact Developer", systemImage: "envelope.fill")
                        }
                    }
                    .listRowBackground(Color.white)
                }
                .scrollContentBackground(.hidden)  // Hide default list background
                .background(Color.clear)  // Clear background to show gradient
            }
            .navigationTitle(LocalizedStringKey("Settings"))
        }
        .alert(LocalizedStringKey("Clear Saved Articles"), isPresented: $showingResetAlert) {
            Button(LocalizedStringKey("Cancel"), role: .cancel) {}
            Button(LocalizedStringKey("Clear All"), role: .destructive) {
                bookmarkManager.clearAllBookmarks()
            }
        } message: {
            Text(LocalizedStringKey("Clear Articles Warning"))
        }
        .environment(\.locale, AppLanguage(rawValue: appLanguage)?.locale ?? .current)
        .sheet(isPresented: $showingMailView) {
            MailView(
                result: $mailResult,
                subject: "SwipePedia Feedback",
                recipients: ["developer@swipepedia.app"],
                messageBody: """
                    App Version: \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown")
                    Device: \(UIDevice.current.model)
                    iOS Version: \(UIDevice.current.systemVersion)
                    
                    Feedback:
                    
                    """
            )
        }
    }
}

struct MailView: UIViewControllerRepresentable {
    @Binding var result: Result<MFMailComposeResult, Error>?
    let subject: String
    let recipients: [String]
    let messageBody: String
    @Environment(\.presentationMode) var presentation
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        @Binding var presentation: PresentationMode
        @Binding var result: Result<MFMailComposeResult, Error>?
        
        init(presentation: Binding<PresentationMode>,
             result: Binding<Result<MFMailComposeResult, Error>?>) {
            _presentation = presentation
            _result = result
        }
        
        func mailComposeController(_ controller: MFMailComposeViewController,
                                 didFinishWith result: MFMailComposeResult,
                                 error: Error?) {
            defer {
                $presentation.wrappedValue.dismiss()
            }
            guard error == nil else {
                self.result = .failure(error!)
                return
            }
            self.result = .success(result)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(presentation: presentation, result: $result)
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<MailView>) -> MFMailComposeViewController {
        let vc = MFMailComposeViewController()
        vc.mailComposeDelegate = context.coordinator
        vc.setSubject(subject)
        vc.setToRecipients(recipients)
        vc.setMessageBody(messageBody, isHTML: false)
        return vc
    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController,
                              context: UIViewControllerRepresentableContext<MailView>) {
    }
}

#Preview {
    SettingsScreen()
        .environmentObject(BookmarkManager())
} 