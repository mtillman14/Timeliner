//
//  AddEntryView.swift
//  Timeliner
//
//  Created by Mitchell Tillman on 7/11/24.
//

import SwiftUI

struct AddEntryView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var viewModel: TimelineViewModel
    
    @State private var description = ""
    @State private var date = Date()
    @State private var selectedCategory = ""
    @State private var universalLink = ""
    
    var onSave: (TimelineEntry) -> Void
    
    var body: some View {
        VStack {
            Form {
                Section(header: Text("Entry Details")) {
                    TextEditor(text: $description)
                        .frame(height: 100)
                    DatePicker("Date", selection: $date)
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(viewModel.categories, id: \.self) { category in
                            Text(category)
                        }
                    }
                }
                
                Section(header: Text("Universal Link")) {
                    TextField("Paste or drop link here", text: $universalLink)
                        .onDrop(of: ["public.url"], isTargeted: nil) { providers in
                            if let provider = providers.first {
                                provider.loadItem(forTypeIdentifier: "public.url", options: nil) { (urlData, error) in
                                    if let urlData = urlData as? Data {
                                        self.universalLink = String(decoding: urlData, as: UTF8.self)
                                    }
                                }
                                return true
                            }
                            return false
                        }
                }
            }
            
            HStack {
                Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                Spacer()
                Button("Save") {
                    saveEntry()
                }
            }
            .padding()
        }
        .frame(width: 300, height: 400)
        .onAppear {
            if !viewModel.categories.isEmpty {
                selectedCategory = viewModel.categories[0]
            }
        }
    }
    
    private func saveEntry() {
        let newEntry = TimelineEntry(
            description: description,
            date: date,
            category: selectedCategory,
            universalLink: universalLink.isEmpty ? nil : universalLink
        )
        onSave(newEntry)
        presentationMode.wrappedValue.dismiss()
    }
}

struct ManageCategoriesView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var viewModel: TimelineViewModel
    @State private var newCategory = ""
    @State private var editingCategory: String?
    @State private var editedCategoryName = ""
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Add New Category")) {
                    HStack {
                        TextField("New Category", text: $newCategory)
                        Button("Add") {
                            if !newCategory.isEmpty {
                                viewModel.addCategory(newCategory)
                                newCategory = ""
                            }
                        }
                    }
                }
                
                Section(header: Text("Existing Categories")) {
                    ForEach(viewModel.categories, id: \.self) { category in
                        if editingCategory == category {
                            HStack {
                                TextField("Category Name", text: $editedCategoryName)
                                Button("Save") {
                                    viewModel.updateCategory(oldName: category, newName: editedCategoryName)
                                    editingCategory = nil
                                }
                                Button("Cancel") {
                                    editingCategory = nil
                                }
                            }
                        } else {
                            HStack {
                                Text(category)
                                Spacer()
                                Button("Edit") {
                                    editingCategory = category
                                    editedCategoryName = category
                                }
                            }
                        }
                    }
                    .onDelete(perform: deleteCategories)
                }
            }
            .navigationTitle("Manage Categories")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
    
    private func deleteCategories(at offsets: IndexSet) {
        offsets.forEach { index in
            let categoryToDelete = viewModel.categories[index]
            viewModel.deleteCategory(categoryToDelete)
        }
    }
}
