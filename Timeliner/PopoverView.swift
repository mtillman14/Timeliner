//
//  PopoverView.swift
//  Timeliner
//
//  Created by Mitchell Tillman on 7/11/24.
//

import SwiftUI
import UniformTypeIdentifiers
import AppKit

struct FileAccessError: Identifiable {
    let id = UUID()
    let message: String
}

struct DeleteConfirmation: Identifiable {
    let id = UUID()
    let indexSet: IndexSet
}

struct PopoverView: View {
    @EnvironmentObject var viewModel: TimelineViewModel
    @State private var isAddingEntry = false
    @State private var isManagingCategories = false
    @State private var editingEntry: TimelineEntry?
    @State private var fileAccessError: FileAccessError?
    @State private var deleteConfirmation: TimelineEntry?
    @State private var scrollProxy: ScrollViewProxy?
    @State private var lastAddedEntryID: UUID?
    
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                Text("Timeliner")
                    .font(.headline)
                
                if viewModel.entries.isEmpty {
                    Text("No entries yet. Add your first entry!")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                } else {
                    ScrollViewReader { proxy in
                        List {
                            ForEach(viewModel.entries) { entry in
                                EntryRow(
                                    entry: entry,
                                    onEdit: { editingEntry = entry },
                                    onOpenLink: {
                                        if let link = entry.universalLink {
                                            openLink(link)
                                        }
                                    },
                                    onDelete: {
                                        print("Delete requested for entry: \(entry.id)")
                                        deleteConfirmation = entry
                                    }
                                )
                                .id(entry.id)
                            }
                        }
                        .onChange(of: viewModel.entries) { _ in
                            if let id = lastAddedEntryID {
                                proxy.scrollTo(id, anchor: .top)
                                lastAddedEntryID = nil
                            }
                        }
                    }
                }
                
                HStack {
                    Button("Add Entry") {
                        isAddingEntry = true
                    }
                    
                    Spacer()
                    
                    Button("Manage Categories") {
                        isManagingCategories = true
                    }
                }
                .padding(.horizontal)
            }
            .frame(width: 300, height: 400)
            .padding()
            
            if deleteConfirmation != nil {
                DeleteConfirmationView(entry: $deleteConfirmation) { confirmed in
                    if confirmed, let entry = deleteConfirmation {
                        deleteEntry(entry)
                    }
                    deleteConfirmation = nil
                }
            }
        }
        .sheet(isPresented: $isAddingEntry) {
            AddEntryView(onSave: { entry in
                viewModel.addEntry(description: entry.description, date: entry.date, category: entry.category, universalLink: entry.universalLink)
                lastAddedEntryID = entry.id
            })
        }
        .sheet(isPresented: $isManagingCategories) {
            ManageCategoriesView()
        }
        .sheet(item: $editingEntry) { entry in
            EditEntryView(entry: entry)
        }
        .alert(item: $fileAccessError) { error in
            Alert(title: Text("File Access Error"), message: Text(error.message), dismissButton: .default(Text("OK")))
        }
    }
    
    private func deleteEntry(_ entry: TimelineEntry) {
        if let index = viewModel.entries.firstIndex(where: { $0.id == entry.id }) {
            viewModel.deleteEntry(at: IndexSet(integer: index))
        }
    }
    
    private func openLink(_ link: String) {
        guard let url = URL(string: link) else {
            fileAccessError = FileAccessError(message: "Invalid URL")
            return
        }
        
//         File by file permissions
        if url.isFileURL {
            let openPanel = NSOpenPanel()
            openPanel.message = "Please grant access to the file"
            openPanel.prompt = "Grant Access"
            openPanel.allowedContentTypes = [.item]
            openPanel.allowsOtherFileTypes = true
            openPanel.canChooseFiles = true
            openPanel.canChooseDirectories = false
            openPanel.allowsMultipleSelection = false
            openPanel.directoryURL = url.deletingLastPathComponent()
            
            openPanel.begin { response in
                if response == .OK {
                    if let selectedURL = openPanel.url, selectedURL == url {
                        NSWorkspace.shared.open(url)
                    } else {
                        fileAccessError = FileAccessError(message: "Selected file does not match the original link")
                    }
                }
            }
            
            // Bring the open panel to the front
            openPanel.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        } else {
            NSWorkspace.shared.open(url)
        }
    }
}

struct EntryRow: View {
    let entry: TimelineEntry
    let onEdit: () -> Void
    let onOpenLink: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            if let icon = entry.icon {
                Image(nsImage: icon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 20)
            }
            VStack(alignment: .leading, spacing: 5) {
                Text(entry.description)
                    .font(.body)
                
                HStack {
                    Text(entry.date, style: .date)
                        .font(.caption)
                    Text(entry.date, style: .time)
                        .font(.caption)
                    Spacer()
                    Text(entry.category)
                        .font(.caption)
                        .padding(4)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(4)
                }
                
                if entry.universalLink != nil {
                    Button("Open Link", action: onOpenLink)
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
        }
        .padding(.vertical, 5)
        .contentShape(Rectangle())
        .onTapGesture {
            onEdit()
        }
        .contextMenu {
            Button("Edit") { onEdit() }
            Button("Delete", role: .destructive) { onDelete() }
        }
    }
}

struct DeleteConfirmationView: View {
    @Binding var entry: TimelineEntry?
    var onConfirm: (Bool) -> Void
    
    var body: some View {
        VStack {
            Text("Delete Entry")
                .font(.headline)
            Text("Are you sure you want to delete this entry?")
                .padding()
            HStack {
                Button("Cancel") {
                    onConfirm(false)
                }
                .keyboardShortcut(.escape, modifiers: [])
                
                Button("Delete") {
                    onConfirm(true)
                }
                .keyboardShortcut(.return, modifiers: [])
                .foregroundColor(.red)
            }
        }
        .padding()
        .background(Color(NSColor.windowBackgroundColor))
        .cornerRadius(10)
        .shadow(radius: 10)
    }
}
