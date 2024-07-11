//
//  EditEntryView.swift
//  Timeliner
//
//  Created by Mitchell Tillman on 7/11/24.
//

import SwiftUI

struct EditEntryView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var viewModel: TimelineViewModel
    @State private var entry: TimelineEntry
    
    init(entry: TimelineEntry) {
        _entry = State(initialValue: entry)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Entry Details")) {
                    TextEditor(text: $entry.description)
                        .frame(height: 100)
                    DatePicker("Date", selection: $entry.date)
                    Picker("Category", selection: $entry.category) {
                        ForEach(viewModel.categories, id: \.self) { category in
                            Text(category)
                        }
                    }
                }
                
                Section(header: Text("Universal Link")) {
                    TextField("Link", text: Binding(
                        get: { self.entry.universalLink ?? "" },
                        set: { self.entry.universalLink = $0.isEmpty ? nil : $0 }
                    ))
                }
            }
            .navigationTitle("Edit Entry")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.updateEntry(entry)
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}
