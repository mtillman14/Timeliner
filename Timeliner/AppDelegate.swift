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
        if let button = statusItem?.button {
            if popover?.isShown == true {
                popover?.performClose(sender)
            } else {
                popover?.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
                
                // Adjust the popover position after it's shown
                DispatchQueue.main.async {
                    if let popoverWindow = self.popover?.contentViewController?.view.window,
                       let buttonWindow = button.window {
                        let buttonFrame = button.convert(button.bounds, to: nil)
                        let windowFrame = buttonWindow.convertToScreen(buttonFrame)
                        
                        // Get the height of the menu bar
                        let menuBarHeight = NSStatusBar.system.thickness
                        
                        // Calculate the new origin for the popover window
                        let newOriginX = windowFrame.origin.x + (windowFrame.width - popoverWindow.frame.width) / 2 + 5 // Shift slightly to the right
                        let newOriginY = windowFrame.origin.y - popoverWindow.frame.height - menuBarHeight + 5 // Move slightly up
                        
                        // Set the new frame for the popover window
                        popoverWindow.setFrameOrigin(NSPoint(x: newOriginX, y: newOriginY))
                    }
                }
            }
        }
    }
}
