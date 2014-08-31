//
//  AppDelegate.swift
//  KanjiApp
//
//  Created by Sky on 2014-07-01.
//  Copyright (c) 2014 Sky. All rights reserved.
//

import UIKit
import CoreData

enum ImportedFiletype {
    case Kanji
    case CSV
    case TSV
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UIAlertViewDelegate {
    
    func application(application: UIApplication, handleOpenURL url: NSURL) -> Bool {
        return true
    }
    
    var filetype: ImportedFiletype?
    var fileContents = ""
    
    func alertView(alertView: UIAlertView!, willDismissWithButtonIndex buttonIndex: Int) {
        if  buttonIndex == 1 &&
            fileContents != "" {
            if let filetype = filetype {
                switch filetype {
                case .Kanji:
                    importKanjiDatabase(fileContents)
                case .CSV:
                    additiveImportList(fileContents, delimiter: ",", column: 1, fallbackColumn: 0)
                case .TSV:
                    additiveImportList(fileContents, delimiter: "\t", column: 1, fallbackColumn: 0)
                }
            }
            
//            println(fileContents)
            fileContents = ""
        }
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        if url.pathExtension == "kanji" {
            filetype = .Kanji
        } else if url.pathExtension == "csv" {
            filetype = .CSV
            
        } else if url.pathExtension == "txt" {
            filetype = .TSV
            
        } else {
            filetype = nil
        }
        
        if filetype != nil {
            var error: NSErrorPointer = nil
            fileContents = NSString.stringWithContentsOfURL(url, encoding: NSUTF8StringEncoding, error: error)
        }
        
        if let filetype = filetype {
            switch filetype {
            case .Kanji:
                var alert = UIAlertView(title: "Import Data", message: "Warning, importing lists will delete all current user data, and replace it with the data from the imported file. Are you sure you wish to continue?", delegate: nil, cancelButtonTitle: "Cancel")
                alert.addButtonWithTitle("Import")
                alert.delegate = self
                alert.show()
            case .CSV:
                var alert = UIAlertView(title: "Import CSV", message: "Importing this file will add the contained words to the list of words to study. Are you sure you wish to continue?", delegate: nil, cancelButtonTitle: "Cancel")
                alert.addButtonWithTitle("Import From Midori")
                alert.delegate = self
                alert.show()
            case .TSV:
                var alert = UIAlertView(title: "Import TSV", message: "Importing this file will add the contained words to the list of words to study. Are you sure you wish to continue?", delegate: nil, cancelButtonTitle: "Cancel")
                alert.addButtonWithTitle("Import From Midori")
                alert.delegate = self
                alert.show()
            }
        }
        
        return true
    }
    
    func trimEntryExcess(var value: String) -> String {
        if value == "" {
            return value
        }
        
        let length = countElements(value)
        
        if length >= 2 {
            if  value[0..<1] == "\"" &&
                value[length - 1..<length] == "\"" {
                value = value[1..<length-1]
            }
        }
        
        return value
    }
    
    func additiveImportList(source: String, delimiter: String, column: Int, fallbackColumn: Int) {
        managedObjectContext.undoManager.beginUndoGrouping()
        
        var values = source.componentsSeparatedByString("\n")
        for value in values {
            let splits = value.componentsSeparatedByString(delimiter)
            
            if splits.count <= column {
                continue
            }
            var entry = splits[column]
            
            entry = trimEntryExcess(entry)
            
            if entry == "" {
                if splits.count <= fallbackColumn {
                    continue
                }
                
                entry = splits[fallbackColumn]
                entry = trimEntryExcess(entry)
            }
            
            if let card = managedObjectContext.fetchCardByKanji(entry) {
                card.suspended = false
            }
        }
        
        managedObjectContext.undoManager.endUndoGrouping()
        saveContext()
    }
    
    func resetDatabase() {
        for card in managedObjectContext.fetchCardsAllWords() {
            card.answersKnown = 0
            card.answersNormal = 0
            card.answersHard = 0
            card.answersForgot = 0
            card.interval = 0
            card.dueTime = 0
            card.enabled = false
            card.suspended = true
            card.known = false
        }
    }
    
    func importKanjiDatabase(source: String) {
        managedObjectContext.undoManager.beginUndoGrouping()
        resetDatabase()
        
        var values = source.componentsSeparatedByString("\n")
        for value in values {
//            println(value)
            let splits = value.componentsSeparatedByString(" ")
            
//            println(splits.count)
            
            if splits.count < 10 {
                continue
            }
            
            let index = splits[0].toInt()
            let answersKnown = splits[1].toInt()
            let answersNormal = splits[2].toInt()
            let answersHard = splits[3].toInt()
            let answersForgot = splits[4].toInt()
            let interval = splits[5].toInt()
            let dueTime = (splits[6] as NSString).doubleValue
            let enabled = splits[7].toInt()
            let suspended = splits[8].toInt()
            let known = splits[9].toInt()
            
            if let card = managedObjectContext.fetchCardByIndex(index!) {
                card.answersKnown = answersKnown!
                card.answersNormal = answersNormal!
                card.answersHard = answersForgot!
                card.answersForgot = answersKnown!
                card.interval = interval!
                card.dueTime = dueTime
                card.enabled = enabled!
                card.suspended = suspended!
                card.known = known!
            }
        }
        
        managedObjectContext.undoManager.endUndoGrouping()
        saveContext()
    }
                            
    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: NSDictionary?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    func saveContext () {
        var error: NSError? = nil
        let managedObjectContext = self.managedObjectContext
        if managedObjectContext != nil {
            if managedObjectContext.hasChanges && !managedObjectContext.save(&error) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                //println("Unresolved error \(error), \(error.userInfo)")
                abort()
            }
        }
    }

    // #pragma mark - Core Data stack

    // Returns the managed object context for the application.
    // If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
    var managedObjectContext: NSManagedObjectContext {
        if _managedObjectContext == nil {
            let coordinator = self.persistentStoreCoordinator
            if coordinator != nil {
                _managedObjectContext = NSManagedObjectContext()
                _managedObjectContext!.persistentStoreCoordinator = coordinator
                _managedObjectContext!.undoManager = NSUndoManager()
                
//                println("undo manager \(_managedObjectContext?.undoManager)")
            }
        }
        return _managedObjectContext!
    }
    var _managedObjectContext: NSManagedObjectContext? = nil

    // Returns the managed object model for the application.
    // If the model doesn't already exist, it is created from the application's model.
    var managedObjectModel: NSManagedObjectModel {
        if _managedObjectModel == nil {
            let modelURL = NSBundle.mainBundle().URLForResource("KanjiApp", withExtension: "momd")
            _managedObjectModel = NSManagedObjectModel(contentsOfURL: modelURL)
        }
        return _managedObjectModel!
    }
    var _managedObjectModel: NSManagedObjectModel? = nil

    // Returns the persistent store coordinator for the application.
    // If the coordinator doesn't already exist, it is created and the application's store added to it.
    var persistentStoreCoordinator: NSPersistentStoreCoordinator {
        if _persistentStoreCoordinator == nil {
            let storeURL = self.applicationDocumentsDirectory.URLByAppendingPathComponent("KanjiApp.sqlite")
            var error: NSError? = nil
            _persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
            if _persistentStoreCoordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: nil, error: &error) == nil {
                /*
                Replace this implementati coon with code to handle the error appropriately.

                abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                Typical reasons for an error here include:
                * The persistent store is not accessible;
                * The schema for the persistent store is incompatible with current managed object model.
                Check the error message to determine what the actual problem was.


                If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.

                If you encounter schema incompatibility errors during development, you can reduce their frequency by:
                * Simply deleting the existing store:
                NSFileManager.defaultManager().removeItemAtURL(storeURL, error: nil)

                * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
                [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true}

                Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.

                */
//                println("Unresolved error \(error), \(error.description)")
                abort()
            }
        }
        return _persistentStoreCoordinator!
    }
    var _persistentStoreCoordinator: NSPersistentStoreCoordinator? = nil

    // #pragma mark - Application's Documents directory
                                    
    // Returns the URL to the application's Documents directory.
    var applicationDocumentsDirectory: NSURL {
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.endIndex-1] as NSURL
    }

}

