//
//  HelloWorldViewController.swift
//  Timeliner
//
//  Created by Mitchell Tillman on 7/11/24.
//

import Cocoa

class HelloWorldViewController: NSViewController {
    override func loadView() {
        self.view = NSView(frame: NSRect(x: 0, y: 0, width: 200, height: 100))
        self.view.wantsLayer = true
        
        let label = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 100))
        label.stringValue = "Hello, World!"
        label.alignment = .center
        label.isEditable = false
        label.isBordered = false
        label.backgroundColor = .clear
        
        self.view.addSubview(label)
    }
}
