//
//  TimelinerApp.swift
//  Timeliner
//
//  Created by Mitchell Tillman on 7/11/24.
//

import SwiftUI

@main
struct TimelinerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}
