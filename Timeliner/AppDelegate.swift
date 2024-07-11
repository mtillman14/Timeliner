//
//  AppDelegate.swift
//  Timeliner
//
//  Created by Mitchell Tillman on 7/11/24.
//

// AppDelegate.swift

import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var popover: NSPopover?
    var timelineViewModel: TimelineViewModel!
    var globalHotKey: GlobalHotKey!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        timelineViewModel = TimelineViewModel()
        
        // Create the status item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "clock", accessibilityDescription: "Timeliner")
            button.action = #selector(togglePopover(_:))
        }
        
        // Create the popover with SwiftUI view
        popover = NSPopover()
        popover?.contentSize = NSSize(width: 300, height: 400)
        popover?.behavior = .transient
        popover?.contentViewController = NSHostingController(rootView: PopoverView().environmentObject(timelineViewModel))
        
        // Set up global hot key
        globalHotKey = GlobalHotKey()
        globalHotKey.onHotKeyPressed = { [weak self] in
            self?.togglePopover(nil)
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // This will trigger saving of entries and categories
        timelineViewModel.addEntry(description: "", date: Date(), category: "", universalLink: nil)
        timelineViewModel.deleteEntry(at: IndexSet(integer: timelineViewModel.entries.count - 1))
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }

    @objc func togglePopover(_ sender: AnyObject?) {
        if let event = NSApp.currentEvent {
            if event.type == .rightMouseUp {
                showContextMenu()
            } else {
                if let button = statusItem?.button {
                    if popover?.isShown == true {
                        popover?.performClose(sender)
                    } else {
                        popover?.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
                    }
                }
            }
        }
    }

    func showContextMenu() {
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
        statusItem?.menu = menu
        statusItem?.button?.performClick(nil)
        statusItem?.menu = nil
    }
}
