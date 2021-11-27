//
//  MMPreferencesWindowController.swift
//  Swift-NSToolBar
//
//  Created by Matthew Merritt on 12/11/17.
//  Copyright © 2017 MerrittWare. All rights reserved.
//

import Cocoa

public class MMPreferenceView {
    var title: String
    var icon: String
    var className: String
    var identifier: String
    var nib: String

    var toolbarIdentifier: NSToolbarItem.Identifier

    public init(title: String, icon: String, className: String, identifier: String, nib: String) {
        self.title = title
        self.icon  = icon
        self.className = className
        self.identifier = identifier
        self.nib = nib

        self.toolbarIdentifier = NSToolbarItem.Identifier(rawValue: identifier)
    }

    func addTo(toolbar: NSToolbar) {
        toolbar.insertItem(withItemIdentifier: self.toolbarIdentifier, at: toolbar.items.count)
    }

    var viewController: NSViewController? {
        guard let viewController: NSViewController.Type = self.className.convertToClass() else {
            return nil
        }

        let bundle = Bundle(for: NSClassFromString(viewController.className())!)
        return viewController.init(nibName: self.nib, bundle: bundle)
    }

}

public class MMPreferencesWindowController: NSWindowController, NSToolbarDelegate, NSWindowDelegate {

    public static var shared: MMPreferencesWindowController = MMPreferencesWindowController()

    var toolbar: NSToolbar? = nil
    var currentViewController: NSViewController!
    var currentView = ""

    var preferenceViews = [MMPreferenceView]()
    public var preferenceViewsToAdd = [MMPreferenceView]()

    convenience init() {
        self.init(windowNibName: "MMPreferencesWindowController")
    }

    override public func windowDidLoad() {
        super.windowDidLoad()

        // Make us the delegate so we know when the LogWindowController is going to display
        window?.delegate = self

        if toolbar == nil {
            toolbar = NSToolbar(identifier:"ScreenNameToolbarIdentifier")
            toolbar?.allowsUserCustomization = true
            toolbar?.delegate = self
            self.window?.toolbar = toolbar
        }
    }

    public func windowDidBecomeKey(_ notification: Notification) {
        for preferenceView in preferenceViewsToAdd {
            preferenceViews.append(preferenceView)
            preferenceViews.last?.addTo(toolbar: toolbar!)
        }

        preferenceViewsToAdd.removeAll()

        if preferenceViews.count > 0 {
            toolbar?.selectedItemIdentifier = preferenceViews.first?.toolbarIdentifier
            loadView(preferenceView: preferenceViews.first!, withAnimation: false)
        }
    }

    public func addPreferenceView(title: String, icon: String, className: String, identifier: String, nib: String) {
        let preferenceView = MMPreferenceView(title: title, icon: icon, className: className, identifier: identifier, nib: nib)
        preferenceViewsToAdd.append(preferenceView)
    }

    public func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        for view in preferenceViews {
            if view.toolbarIdentifier == itemIdentifier {
                let iconImage = NSImage(named: view.icon)

                let toolbarItem = NSToolbarItem(itemIdentifier: itemIdentifier)
                toolbarItem.label = view.title
                toolbarItem.image = iconImage
                toolbarItem.target = self
                toolbarItem.action = #selector(MMPreferencesWindowController.viewSelected(_:))

                return toolbarItem
            }
        }

        return nil
    }

    public func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return preferenceViews.compactMap { $0.toolbarIdentifier }
    }

    public func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return self.toolbarDefaultItemIdentifiers(toolbar)
    }

    public func toolbarSelectableItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return self.toolbarDefaultItemIdentifiers(toolbar)
    }

    public func toolbarWillAddItem(_ notification: Notification) {
//        Swift.print("toolbarWillAddItem")
    }

    public func toolbarDidRemoveItem(_ notification: Notification) {
//        Swift.print("toolbarDidRemoveItem")
    }

    @IBAction func viewSelected(_ sender: NSToolbarItem) {
//        Swift.print("view is selected")

        loadView(preferenceView: preferenceViews.filter { $0.toolbarIdentifier == sender.itemIdentifier }.first!, withAnimation: true)
    }

    func loadView(preferenceView: MMPreferenceView, withAnimation shouldAnimate: Bool) {
        if ( currentView ==  preferenceView.toolbarIdentifier.rawValue) {
            return
        }

        currentView = preferenceView.toolbarIdentifier.rawValue

        currentViewController = preferenceView.viewController

        let newView = currentViewController.view

        let windowRect = self.window?.frame
        let currentViewRect = newView.frame

        let titlebarHeight = self.window?.titlebarHeight

        self.window?.title = preferenceView.title
        window?.contentView = newView

        let yPos = windowRect!.origin.y + (windowRect!.size.height - currentViewRect.size.height - titlebarHeight!)
        let newFrame = NSMakeRect(windowRect!.origin.x, yPos, currentViewRect.size.width, currentViewRect.size.height + titlebarHeight!)

        self.window?.setFrame(newFrame, display: true, animate: true)
    }

}

extension NSWindow {
    var titlebarHeight: CGFloat {
        let contentHeight = contentRect(forFrameRect: frame).height
        return frame.height - contentHeight
    }
}

extension String {

    func convertToClass<T>() -> T.Type? {
        return StringClassConverter<T>.convert(string: self)
    }
}

class StringClassConverter<T> {

    static func convert(string className: String) -> T.Type? {
        let theNameSpace = "MMPreferencesWindow"
        guard let nameSpace = Bundle.main.infoDictionary?["CFBundleExecutable"] as? String else {
            return nil
        }

        var theClass: T.Type? = nil

        if let aClass: T.Type = NSClassFromString("\(nameSpace).\(className)") as? T.Type {
            theClass = aClass
        } else if let aClass: T.Type = NSClassFromString("\(theNameSpace).\(className)") as? T.Type {
            theClass = aClass
        }

        return theClass
    }

}
