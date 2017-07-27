//
//  AppDelegate.swift
//  BuddyApp
//
//  Created by Ti Technologies on 17/07/17.
//  Copyright © 2017 Ti Technologies. All rights reserved.
//

import UIKit
import CoreData
import FBSDKCoreKit
import FBSDKLoginKit
import GoogleSignIn
import IQKeyboardManagerSwift
import UserNotifications


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,GIDSignInDelegate,UNUserNotificationCenterDelegate {
 var Usertoken = String()
    var UserId = Int()
    var USER_TYPE = String()
    var DeviceToken = String()
    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            center.delegate = self
            center.requestAuthorization(options: [.badge, .sound, .alert], completionHandler: {(grant, error)  in
                if error == nil {
                    if grant {
                        application.registerForRemoteNotifications()
                    } else {
                        //User didn't grant permission
                    }
                } else {
                    print(" notification error: ",error!)
                }
            })
        } else {
            // Fallback on earlier versions
            let notificationSettings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(notificationSettings)
        }
        
        
        GIDSignIn.sharedInstance().clientID = "681481687812-r3p3k9upg22juaq3co7bccqlbn8blhnc.apps.googleusercontent.com"
        GIDSignIn.sharedInstance().delegate = self
   IQKeyboardManager.sharedManager().enable = true
        
        
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        

    }
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        
        let googleDidHandle = GIDSignIn.sharedInstance().handle(url as URL!,
                                                                sourceApplication: sourceApplication,
                                                                annotation: annotation)
        
        let facebookDidHandle = FBSDKApplicationDelegate.sharedInstance().application(
            application,
            open: url as URL!,
            sourceApplication: sourceApplication,
            annotation: annotation)
        
        return googleDidHandle || facebookDidHandle
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
        
        
        if (error == nil)
        {
            let userId = user.userID                  // For client-side use only!
            let idToken = user.authentication.idToken // Safe to send to the server
            let name = user.profile.name
            let email = user.profile.email
            //let userImageURL = user.profile.imageURLWithDimension(200)
            // ...
            
            
                            //print(user)
                            print(userId!)
                            print(idToken!)
                            print(name!)
                            print(email!)
           
            
            let googleDict = ["name":name!,
                              "email":email!,
                              "userid":userId!,
                              "idToken":idToken!]
            
            
                        
            let notificationName = Notification.Name("NotificationIdentifier")
            
            // Register to receive notification
          //  NotificationCenter.default.addObserver(self, selector: #selector(RegisterViewController.methodOfReceivedNotification), name: notificationName, object: nil)
            
            // Post notification
    NotificationCenter.default.post(name: notificationName, object: nil, userInfo: ["googledata":googleDict])
            
            // Stop listening notification
          //  NotificationCenter.default.removeObserver(self, name: notificationName, object: nil);
            
            
            
            
            
        }
        else
        {
            print("\(error.localizedDescription)")
        }
        
        
    }
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenString = deviceToken.reduce("") { string, byte in
            string + String(format: "%02X", byte)
        }
        print("token: ", tokenString)
        
        userDefaults.set(tokenString, forKey: "devicetoken")
        
    }
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        print(userInfo)
        if application.applicationState == .active {
            //write your code here when app is in foreground
        } else {
            //write your code here for other state
        }
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
         FBSDKAppEvents.activateApp()
        
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        let loginManager: FBSDKLoginManager = FBSDKLoginManager()
        loginManager.logOut()
        self.saveContext()

    }

    
    /**
     Copies the sqlite, wal and shm file to the destination folder. Don't forget to merge the wal file using the commands printed int the console.
     @param destinationPath Path where sqlite files has to be copied
     @param persistentContainer NSPersistentContainer
     */
    public static func getSqliteTo(destinationPath: String, persistentContainer: NSPersistentContainer) {
        let storeUrl = persistentContainer.persistentStoreCoordinator.persistentStores.first?.url
        
        let sqliteFileName = storeUrl!.lastPathComponent
        let walFileName = sqliteFileName + "-wal"
        let shmFileName = sqliteFileName + "-shm"
        //Add all file names in array
        let fileArray = [sqliteFileName, walFileName, shmFileName]
        
        let storeDir = storeUrl!.deletingLastPathComponent()
        
        // Destination dir url, make sure file don't exists in that folder
        let destDir = URL(fileURLWithPath: destinationPath, isDirectory: true)
        
        do {
            for fileName in fileArray {
                let sourceUrl = storeDir.appendingPathComponent(fileName, isDirectory: false)
                let destUrl = destDir.appendingPathComponent(fileName, isDirectory: false)
                try FileManager.default.copyItem(at: sourceUrl, to: destUrl)
                print("File: \(fileName) copied to path: \(destUrl.path)")
            }
        }
        catch {
            print("\(error)")
        }
        print("\n\n\n ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ NOTE ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~\n")
        print("In your terminal run the following commands to merge wal file. Otherwise you may see partial or no data in \(sqliteFileName) file")
        print("\n-------------------------------------------------")
        print("$ cd \(destDir.path)")
        print("$ sqlite3 \(sqliteFileName)")
        print("sqlite> PRAGMA wal_checkpoint;")
        print("-------------------------------------------------\n")
        print("Press control + d")
//        abort() // uncomment it if you don't want to quit your application
        
    }

    
    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "BuddyApp")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

