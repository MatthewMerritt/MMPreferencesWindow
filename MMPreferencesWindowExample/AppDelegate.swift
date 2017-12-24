//
//  AppDelegate.swift
//  MMPreferencesWindowExample
//
//  Created by Matthew Merritt on 12/23/17.
//  Copyright © 2017 Matthew Merritt. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    let newWindowController: PreferencesWindowController = PreferencesWindowController.shared

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application

        // Add the demo PreferenceViews
        newWindowController.addPreferenceView(title: "General", icon: "NSPreferencesGeneral", className: "PreferencesViewController", identifier: "GeneralView", nib: "GeneralView")
        newWindowController.addPreferenceView(title: "Advanced", icon: "NSAdvanced", className: "PreferencesViewController", identifier: "AdvancedView", nib: "AdvancedView")

    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    @IBAction func preferencesButtonAction(_ sender: Any) {
        newWindowController.showWindow (nil)
    }

}

