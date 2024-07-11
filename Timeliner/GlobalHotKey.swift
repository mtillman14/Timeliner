//
//  GlobalHotKey.swift
//  Timeliner
//
//  Created by Mitchell Tillman on 7/11/24.
//

import Cocoa
import Carbon

class GlobalHotKey {
    private var hotKeyRef: EventHotKeyRef?
    private let hotKeyID = EventHotKeyID(signature: 0x4754494D, id: 1) // GTIM

    var onHotKeyPressed: (() -> Void)?

    init() {
        registerHotKey()
    }

    deinit {
        unregisterHotKey()
    }

    private func registerHotKey() {
        var gMyHotKeyRef: EventHotKeyRef?
        let hotKeyCode = UInt32(kVK_ANSI_T)
        let modifiers = UInt32(cmdKey | controlKey)

        let hotKeyFunction: EventHandlerProcPtr = { (nextHandler, theEvent, userData) -> OSStatus in
            let hotKey = Unmanaged<GlobalHotKey>.fromOpaque(userData!).takeUnretainedValue()
            hotKey.onHotKeyPressed?()
            return noErr
        }

        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
        var eventHandler: EventHandlerRef?

        let selfPtr = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
        InstallEventHandler(GetApplicationEventTarget(), hotKeyFunction, 1, &eventType, selfPtr, &eventHandler)

        let status = RegisterEventHotKey(hotKeyCode, modifiers, hotKeyID, GetApplicationEventTarget(), 0, &gMyHotKeyRef)
        
        if status == noErr {
            hotKeyRef = gMyHotKeyRef
        } else {
            print("Failed to register hot key. Error code: \(status)")
        }
    }

    private func unregisterHotKey() {
        if let hotKeyRef = hotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
        }
    }
}
