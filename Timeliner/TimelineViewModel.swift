//
//  TimelineViewModel.swift
//  Timeliner
//
//  Created by Mitchell Tillman on 7/11/24.
//

// TimelineViewModel.swift

import Foundation

class TimelineViewModel: ObservableObject {
    @Published var entries: [TimelineEntry] = []
    @Published var categories: [String] = []
    
    private let entriesKey = "timelineEntries"
    private let categoriesKey = "categories"
    
    init() {
        loadEntries()
        loadCategories()
    }
    
    func addEntry(description: String, date: Date, category: String, universalLink: String?) {
        let newEntry = TimelineEntry(description: description, date: date, category: category, universalLink: universalLink)
        entries.append(newEntry)
        sortEntriesDescending()
        saveEntries()
    }
    
    func deleteEntry(at offsets: IndexSet) {
        print("TimelineViewModel: Deleting entries at offsets: \(offsets)")
        entries.remove(atOffsets: offsets)
        saveEntries()
    }
    
    func updateEntry(_ entry: TimelineEntry) {
        if let index = entries.firstIndex(where: { $0.id == entry.id }) {
            entries[index] = entry
            sortEntriesDescending()
            saveEntries()
        }
    }
    
    func addCategory(_ category: String) {
        categories.append(category)
        saveCategories()
    }
    
    func deleteCategory(_ category: String) {
        categories.removeAll { $0 == category }
        saveCategories()
    }
    
    func updateCategory(oldName: String, newName: String) {
        if let index = categories.firstIndex(of: oldName) {
            categories[index] = newName
            
            // Update all entries that use this category
            for i in 0..<entries.count {
                if entries[i].category == oldName {
                    entries[i].category = newName
                }
            }
            
            saveCategories()
            saveEntries()
        }
    }
    
    private func saveEntries() {
        if let encoded = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(encoded, forKey: entriesKey)
        }
    }
    
    private func loadEntries() {
        if let savedEntries = UserDefaults.standard.data(forKey: entriesKey) {
            if let decodedEntries = try? JSONDecoder().decode([TimelineEntry].self, from: savedEntries) {
                entries = decodedEntries.map { entry in
                    var updatedEntry = entry
                    updatedEntry.icon = entry.universalLink.flatMap { URL(string: $0) }.flatMap { getIconForURL($0) }
                    return updatedEntry
                }
                sortEntriesDescending()
            }
        }
    }
    
    private func sortEntriesDescending() {
        entries.sort { $0.date > $1.date }
    }
    
    private func saveCategories() {
        UserDefaults.standard.set(categories, forKey: categoriesKey)
    }
    
    private func loadCategories() {
        if let savedCategories = UserDefaults.standard.stringArray(forKey: categoriesKey) {
            categories = savedCategories
        } else {
            // Default categories if none are saved
            categories = ["Work", "Personal", "Health", "Other"]
        }
    }
}
