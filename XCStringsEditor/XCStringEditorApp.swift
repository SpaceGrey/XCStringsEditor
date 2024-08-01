//
//  XCStringEditorApp.swift
//  XCStringEditor
//
//  Created by JungHoon Noh on 1/20/24.
//

import SwiftUI

extension Notification.Name {
    static let findCommand = Notification.Name("findCommand")
}

@main
struct XCStringEditorApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.controlActiveState) private var controlActiveState
    
    @State private var stringsModel: XCStringsModel = XCStringsModel()
    @State private var isDiscardConfirmVisible: Bool = false
    
    var body: some Scene {
        Window("XCStringsEditor", id: "main") {
            ContentView()
                .background(FileDropView { url in
                    openURL(url)
                })
                .environment(stringsModel)
                .environment(appDelegate.windowDelegate)
                .onReceive(NotificationCenter.default.publisher(for: NSWindow.willCloseNotification)) { newValue in
                    if let url = stringsModel.settingsFileURL {
                        stringsModel.settings.save(to: url)
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: .receivedOpenURLsNotification), perform: { newValue in
                    guard let urls = newValue.userInfo?["urls"] as? [URL], let url = urls.first else {
                        return
                    }
                    
                    openURL(url)
                })
                .confirmationDialog("Unsaved Changes Detected", isPresented: $isDiscardConfirmVisible) {
                    Button("Save and Open", role: .none) {
                        guard let url = stringsModel.openingFileURL else {
                            return
                        }
                        stringsModel.save()
                        stringsModel.load(file: url)
                    }
                    
                    Button("Discard and Open", role: .destructive) {
                        guard let url = stringsModel.openingFileURL else {
                            return
                        }
                        stringsModel.load(file: url)
                    }
                    
                    Button("Cancel", role: .cancel) {
                    }
                } message: {
                    Text("You have unsaved changes. Do you want to save your changes before opening a new file?")
                }

        }
        .commands {
            CommandGroup(replacing: .newItem) {
                Divider()
                Button("Open") {
                    open()
                }
                .keyboardShortcut("o", modifiers: [.command]) // Cmd + O
                
                Menu("Open Recent") {
                    let recents = (UserDefaults.standard.array(forKey: "RecentFiles") as? [String])?.map { URL(filePath: $0) } ?? [URL]()
                    if recents.isEmpty == false {
                        ForEach(recents.reversed(), id: \.self) { url in
                            Button {
                                stringsModel.load(file: url)
                                
                                var recents = UserDefaults.standard.array(forKey: "RecentFiles") as? [String] ?? [String]()
                                if let index = recents.firstIndex(where: { $0 == url.path(percentEncoded: false) }) {
                                    recents.remove(at: index)
                                    recents.append(url.path(percentEncoded: false))
                                    UserDefaults.standard.set(recents, forKey: "RecentFiles")
                                }
                            } label: {
                                HStack {
                                    Image(nsImage: NSWorkspace.shared.icon(forFile: url.path(percentEncoded: false)))
                                    Text(verbatim: url.lastPathComponent)
                                }
                            }
                        }
                        Divider()
                        Button("Clear Menu") {
                            UserDefaults.standard.removeObject(forKey: "RecentFiles")
                        }
                    }
                }
                
                Divider()
                
                Button("Save") {
                    stringsModel.save()
                }
                .keyboardShortcut("s", modifiers: [.command]) // Cmd + S
                .disabled(stringsModel.fileURL == nil)
            }
            CommandGroup(after: .pasteboard) {
                Button("Copy Source Text") {
                    stringsModel.copySourceText()
                }
                .keyboardShortcut("c", modifiers: [.command, .control]) // Cmd + Control + C
                .disabled(stringsModel.selected.isEmpty)
                
                Button("Copy Translation") {
                    stringsModel.copyTranslationText()
                }
                .keyboardShortcut("c", modifiers: [.command, .option]) // Cmd + Option + C
                .disabled(stringsModel.selected.isEmpty)

                Button("Copy Source and Translation Text") {
                    stringsModel.copySourceAndTranslationText()
                }
                .keyboardShortcut("c", modifiers: [.command, .option, .control]) // Cmd + Option + Control + C
                .disabled(stringsModel.selected.isEmpty)

                Divider() // ------------------------
                
                Button("Clear Translation") {
                    stringsModel.clearTranslation()
                }
                .keyboardShortcut("e", modifiers: [.command]) // Cmd + E
                .disabled(stringsModel.selected.isEmpty)
                
                Button("Copy from Source Text") {
                    stringsModel.copyFromSourceText()
                }
                .keyboardShortcut("d", modifiers: [.command]) // Cmd + D
                .disabled(stringsModel.selected.isEmpty)
                
                Divider() // ------------------------
                
                Button("Mark for Review") {
                    stringsModel.markNeedsReview()
                }
                .disabled(stringsModel.selected.isEmpty)
                Button("Mark as Reviewed") {
                    stringsModel.reviewed()
                }
                .disabled(stringsModel.selected.isEmpty)

                if stringsModel.selected.isEmpty == false && stringsModel.items(with: Array(stringsModel.selected)).allSatisfy({ $0.shouldTranslate == false }) {
                    Button("Mark for Translation") {
                        stringsModel.setShouldTranslate(true)
                    }
                } else {
                    Button("Mark as \"Don't Translate\"") {
                        stringsModel.setShouldTranslate(false)
                    }
                    .disabled(stringsModel.selected.isEmpty)
                }
                                
                Divider()
                
                Button("Mark for Translate Later") {
                    stringsModel.markTranslateLater(value: true)
                }
                .keyboardShortcut("l", modifiers: [.command]) // Cmd + L
                .disabled(stringsModel.selected.isEmpty)
                
                Button("Unmark Translate Later") {
                    stringsModel.markTranslateLater(value: false)
                }
                .keyboardShortcut("l", modifiers: [.shift, .command]) // Cmd + Shift + L
                .disabled(stringsModel.selected.isEmpty)
                
                Button("Mark for Needs Work") {
                    stringsModel.markNeedsWork(value: true)
                }
                .keyboardShortcut("w", modifiers: [.control, .command]) // Cmd + Control + W
                .disabled(stringsModel.selected.isEmpty)

                Button("Mark for Needs Work for All Languages") {
                    stringsModel.markNeedsWork(value: true, allLanguages: true)
                }
                .disabled(stringsModel.selected.isEmpty)
                .keyboardShortcut("w", modifiers: [.control, .option, .command]) // Cmd + Option + Control + W
                
                Button("Clear Needs Work for All Languages") {
                    stringsModel.clearNeedsWork(allLanguages: true)
                }

                Button("Unmark Needs Work") {
                    stringsModel.markNeedsWork(value: false)
                }
                .keyboardShortcut("w", modifiers: [.control, .shift, .command]) // Cmd + Shift + Control + W
                .disabled(stringsModel.selected.isEmpty)

                Divider() // ------------------------
                
                Button("Auto Translate") {
                    Task {
                        await stringsModel.translate()
                    }
                }
                .keyboardShortcut("t", modifiers: [.command, .option]) // Cmd + Option + T
                .disabled(stringsModel.selected.isEmpty)

                Button("Reverse Translate") {
                    stringsModel.reverseTranslate()
                }
                .keyboardShortcut("t", modifiers: [.shift, .option, .command]) // Cmd + Option + Shift + T
                .disabled(stringsModel.selected.isEmpty)

                Button("Check Translation") {
                    stringsModel.detectLanguage()
                }
                .disabled(true) //stringsModel.selected.isEmpty)
            }
            CommandGroup(after: .toolbar) {
                Button(stringsModel.staleItemsHidden ? "Show Stale Items" : "Hide Stale Items") {
                    stringsModel.staleItemsHidden.toggle()
                }
                Button(stringsModel.dontTranslateItemsHidden ? "Show \"Don't Translate\" Items" : "Hide \"Don't Translate\" Items") {
                    stringsModel.dontTranslateItemsHidden.toggle()
                }
                Button(stringsModel.translateLaterItemsHidden ? "Show Translate Later Items" : "Hide Translate Later Items") {
                    stringsModel.translateLaterItemsHidden.toggle()
                }
                Divider()
            }
            
            CommandGroup(replacing: .appInfo) {
                Button("About XCStringsEditor") {
                    NSApplication.shared.orderFrontStandardAboutPanel(
                        options: [
                            NSApplication.AboutPanelOptionKey.credits: NSAttributedString(
                                string: "https://github.com/xiles",
                                attributes: [
                                    NSAttributedString.Key.font: NSFont.boldSystemFont(
                                        ofSize: NSFont.smallSystemFontSize)
                                ]
                            )
                        ]
                    )
                }
            }
        } // commands
        
        Settings {
            SettingsView()
        }
    }
}

extension XCStringEditorApp {
    func open() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        if panel.runModal() == .OK {
            if let fileURL = panel.url {
                openURL(fileURL)
            }
        }
    }

    private func openURL(_ url: URL) {
        if stringsModel.isModified == false {
            stringsModel.load(file: url)
        } else {
            stringsModel.openingFileURL = url
            isDiscardConfirmVisible = true
        }
    }
}
