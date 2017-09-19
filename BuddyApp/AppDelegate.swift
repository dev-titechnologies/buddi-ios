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
import GoogleMaps
import Braintree
import BraintreeDropIn
import Firebase
import FirebaseMessaging
import GooglePlaces
//import FirebaseAnalytics
//import FirebaseInstanceID

protocol FCMTokenReceiveDelegate: class {
    func tokenReceived()
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,GIDSignInDelegate,UNUserNotificationCenterDelegate {
 
    weak var delegateFCM: FCMTokenReceiveDelegate?
    
    var timerrunningtime = Bool()
    var Usertoken = String()
    var UserId = Int()
    var USER_TYPE = String()
    var DeviceToken = String()
    var userName = String()
    var window: UIWindow?
    let notificationNameFCM = Notification.Name("FCMNotificationIdentifier")
    let SessionNotification = Notification.Name("SessionNotification")
    var TrainerProfileDictionary: NSDictionary!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        configureFirebase(application: application)
        GMSServices.provideAPIKey("AIzaSyDG9LK6RE-RWtyvRRposjxnxFR90Djk_0g")
        GMSPlacesClient.provideAPIKey("AIzaSyDG9LK6RE-RWtyvRRposjxnxFR90Djk_0g")
        GIDSignIn.sharedInstance().clientID = "635834235607-h0j2s9gtins29gliuc5jhu6v0dcrqfg2.apps.googleusercontent.com"

        GIDSignIn.sharedInstance().delegate = self
        IQKeyboardManager.sharedManager().enable = true
        
        BTAppSwitch.setReturnURLScheme("com.titechnologies.BuddyApp.payments")
        
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        
        print("FB URL:\(url)")
        let googleDidHandle = GIDSignIn.sharedInstance().handle(url as URL!,
                                                                sourceApplication: sourceApplication,
                                                                annotation: annotation)
        
        let facebookDidHandle = FBSDKApplicationDelegate.sharedInstance().application(
            application,
            open: url as URL!,
            sourceApplication: sourceApplication,
            annotation: annotation)
        
        if url.scheme?.localizedCaseInsensitiveCompare("com.titechnologies.BuddyApp.payments") == .orderedSame {
            print("Paypal open url in AppDelegate")
            return BTAppSwitch.handleOpen(url, sourceApplication: sourceApplication)
        }
        
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
                            print(userId!)
            print(idToken!)
            print(name!)
            print(email!)
            
            let googleDict = ["name":name!,
                              "email":email!,
                              "userid":userId!,
                              "idToken":idToken!]
            
            let notificationName = Notification.Name("NotificationIdentifier")
            
            // Post notification
            NotificationCenter.default.post(name: notificationName, object: nil, userInfo: ["googledata":googleDict])
        }else{
            print("\(error.localizedDescription)")
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    
        if let refreshedToken = FIRInstanceID.instanceID().token() {
            
            let data = refreshedToken.data(using: .utf8)!
            FIRInstanceID.instanceID().setAPNSToken(data, type: .sandbox)
            print("========== InstanceID token1 didRegisterForRemoteNotificationsWithDeviceToken: \(refreshedToken)")
            userDefaults.set(refreshedToken, forKey: "devicetoken")
        }
    }
    
    //MARK: - FCM TOKEN RECEIVE
    
    func tokenRefreshNotification(notification: NSNotification) {
        
        guard let refreshedToken = FIRInstanceID.instanceID().token()
            else {
                return
        }
        print("*********** InstanceID token: \(refreshedToken)")
        let data = refreshedToken.data(using: .utf8)!
        FIRInstanceID.instanceID().setAPNSToken(data, type: .sandbox)
        userDefaults.set(refreshedToken, forKey: "devicetoken")
       
        connectToFcm()
        delegateFCM?.tokenReceived()
    }
    
    func connectToFcm() {
        // Won't connect since there is no token
//        guard FIRInstanceID.instanceID().token() != nil else {
//            return
//        }
        
        FIRMessaging.messaging().disconnect()
        FIRMessaging.messaging().connect { (error) in
            if error != nil {
                print("Unable to connect with FCM. \(error?.localizedDescription ?? "")")
               
            } else {
                print("Connected to FCM.")
                }
        }
    }
    
    //MARK: - APPLICATION METHODS
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        print(userInfo)
        if application.applicationState == .active {
            //write your code here when app is in foreground
            
            print("ACTIVE")
            
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

extension AppDelegate: FIRMessagingDelegate {
    
    /// The callback to handle data message received via FCM for devices running iOS 10 or above.
    func applicationReceivedRemoteMessage(_ remoteMessage: FIRMessagingRemoteMessage) {
        print("applicationReceivedRemoteMessage",remoteMessage.appData)
        
        let NotificationDict = (remoteMessage.appData as NSDictionary)["data"] as! String
        
        if (remoteMessage.appData as NSDictionary)["type"] as! String == "1"{
            // Post notification
            userDefaults.set(true, forKey: "sessionBookedNotStarted")
             NotificationCenter.default.post(name: notificationNameFCM, object: nil, userInfo: ["pushData":NotificationDict,"type":(remoteMessage.appData as NSDictionary)["type"] as! String])
        }else if (remoteMessage.appData as NSDictionary)["type"] as! String == "2"{
            print("TYPE 2")
            userDefaults.set(false, forKey: "sessionBookedNotStarted")
            NotificationCenter.default.post(name: SessionNotification, object: nil, userInfo: ["pushData":(remoteMessage.appData as NSDictionary)["type"] as! String])
          //  CommonMethods.alertView(view: (self.window?.rootViewController)!, title: ALERT_TITLE, message: "Trainee has started the session", buttonTitle: "Ok")
        }else if (remoteMessage.appData as NSDictionary)["type"] as! String == "3"{
            userDefaults.removeObject(forKey: "TimerData")
            appDelegate.timerrunningtime = false
            TrainerProfileDetail.deleteBookingDetails()
            NotificationCenter.default.post(name: SessionNotification, object: nil, userInfo: ["pushData":(remoteMessage.appData as NSDictionary)["type"] as! String])
           // CommonMethods.alertView(view: (self.window?.rootViewController)!, title: ALERT_TITLE, message: "Session have been Cancelled", buttonTitle: "Ok")
            print("3")
        } else if (remoteMessage.appData as NSDictionary)["type"] as! String == "4"{
            print("4")
            userDefaults.removeObject(forKey: "TimerData")
            appDelegate.timerrunningtime = false
            TrainerProfileDetail.deleteBookingDetails()
            NotificationCenter.default.post(name: SessionNotification, object: nil, userInfo: ["pushData":(remoteMessage.appData as NSDictionary)["type"] as! String])
           // CommonMethods.alertView(view: (self.window?.rootViewController)!, title: ALERT_TITLE, message: "Session have been Completed", buttonTitle: "Ok")
        }else if (remoteMessage.appData as NSDictionary)["type"] as! String == "5"{
            
            
            //REQUEST BOOKING
            
            print("5")
            NotificationCenter.default.post(name: notificationNameFCM, object: nil, userInfo: ["pushData":NotificationDict,"type":(remoteMessage.appData as NSDictionary)["type"] as! String,"aps":((remoteMessage.appData as NSDictionary)["notification"] as! NSDictionary)["body"] as! String])
        }
    }
    
    // Registering for Firebase notifications
    func configureFirebase(application: UIApplication) {
        
        print("configureFirebase")
        FIRMessaging.messaging().remoteMessageDelegate = self
        FIRApp.configure()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.tokenRefreshNotification),
                                               name: NSNotification.Name.firInstanceIDTokenRefresh, object: nil)

        // Register for remote notifications. This shows a permission dialog on first run, to
        // show the dialog at a more appropriate time move this registration accordingly.
        // [START register_for_notifications]
        
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
    }
    
    //MARK: FCM Token Refreshed
    func messaging(_ messaging: FIRMessaging, didRefreshRegistrationToken fcmToken: String) {
        // FCM token updated, update it on Backend Server
        print("didRefreshRegistrationToken")
    }
    
    
    func messaging(_ messaging: FIRMessaging, didReceive remoteMessage: FIRMessagingRemoteMessage) {
        print("remoteMessage: \(remoteMessage)")
    }
    
    //Called when a notification is delivered to a foreground app.
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([])
        
        print("willPresent notification",notification.request.content.userInfo)
        
        let NotificationDict = (notification.request.content.userInfo as NSDictionary)["data"] as! String
        
        if (notification.request.content.userInfo as NSDictionary)["type"] as! String == "1"{
            
            //BOOK SESSION
            userDefaults.set(true, forKey: "sessionBookedNotStarted")
            
            // Post notification
            NotificationCenter.default.post(name: notificationNameFCM, object: nil, userInfo: ["pushData":NotificationDict,"type":(notification.request.content.userInfo as NSDictionary)["type"] as! String])
        }else if (notification.request.content.userInfo as NSDictionary)["type"] as! String == "2"{
            print("TYPE 2")
            
            //STARTED SESSION
            userDefaults.set(false, forKey: "sessionBookedNotStarted")
            userDefaults.removeObject(forKey: "TrainerProfileDictionary")
            NotificationCenter.default.post(name: SessionNotification, object: nil, userInfo: ["pushData":(notification.request.content.userInfo as NSDictionary)["type"] as! String])
            
        }else if (notification.request.content.userInfo as NSDictionary)["type"] as! String == "3"{
            
            //CANCELLED SESSION
            userDefaults.set(false, forKey: "sessionBookedNotStarted")
            userDefaults.removeObject(forKey: "TrainerProfileDictionary")

            
            print("3")
            NotificationCenter.default.post(name: SessionNotification, object: nil, userInfo: ["pushData":(notification.request.content.userInfo as NSDictionary)["type"] as! String])
        }else if (notification.request.content.userInfo as NSDictionary)["type"] as! String == "4"{
            
            
            //COMPLETED SESSION
            userDefaults.set(false, forKey: "sessionBookedNotStarted")
            userDefaults.removeObject(forKey: "TrainerProfileDictionary")

            
            print("4")
            NotificationCenter.default.post(name: SessionNotification, object: nil, userInfo: ["pushData":(notification.request.content.userInfo as NSDictionary)["type"] as! String])
        }else if (notification.request.content.userInfo as NSDictionary)["type"] as! String == "5"{
            
            
            //REQUEST BOOKING
            
            
            
            
            
            
            
            print("5")
        NotificationCenter.default.post(name: notificationNameFCM, object: nil, userInfo: ["pushData":NotificationDict,"type":(notification.request.content.userInfo as NSDictionary)["type"] as! String, "aps":(((notification.request.content.userInfo as NSDictionary)["aps"] as! NSDictionary)["alert"] as! NSDictionary)["body"] as! String])
            
            
            
            
        }else if (notification.request.content.userInfo as NSDictionary)["type"] as! String == "6"{
            
            
            // EXTEND BOOKING
            
             NotificationCenter.default.post(name: SessionNotification, object: nil, userInfo: ["pushData":(notification.request.content.userInfo as NSDictionary)["type"] as! String,"data":NotificationDict])
            
            
        }

    }
    
    //Called to let your app know which action was selected by the user for a given notification.
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("User Info = \(response.notification.date.timeIntervalSinceNow)")
        
        let NotificationDict = (response.notification.request.content.userInfo as NSDictionary)["data"] as! String
        print("RECIVED",NotificationDict)

        
        if (response.notification.request.content.userInfo as NSDictionary)["type"] as! String == "1"{
        NotificationCenter.default.post(name: notificationNameFCM, object: nil, userInfo: ["pushData":NotificationDict])

            userDefaults.set(true, forKey: "sessionBookedNotStarted")
            
         TrainerProfileDictionary = CommonMethods.convertToDictionary(text: NotificationDict )! as NSDictionary
            
            userDefaults.set(NSKeyedArchiver.archivedData(withRootObject: self.TrainerProfileDictionary), forKey: "TrainerProfileDictionary")
            
                     
                }
        else if (response.notification.request.content.userInfo as NSDictionary)["type"] as! String == "2"{
            print("TYPE 2")
            userDefaults.set(false, forKey: "sessionBookedNotStarted")
            userDefaults.removeObject(forKey: "TrainerProfileDictionary")
            NotificationCenter.default.post(name: SessionNotification, object: nil, userInfo: ["pushData":(response.notification.request.content.userInfo as NSDictionary)["type"] as! String])
        }
        else if (response.notification.request.content.userInfo as NSDictionary)["type"] as! String == "3"{
            print("3")
            userDefaults.removeObject(forKey: "TimerData")
            appDelegate.timerrunningtime = false
            TrainerProfileDetail.deleteBookingDetails()
            NotificationCenter.default.post(name: SessionNotification, object: nil, userInfo: ["pushData":(response.notification.request.content.userInfo as NSDictionary)["type"] as! String])
          
        }
        else if (response.notification.request.content.userInfo as NSDictionary)["type"] as! String == "4"{
            print("4")
            userDefaults.removeObject(forKey: "TimerData")
            appDelegate.timerrunningtime = false
            TrainerProfileDetail.deleteBookingDetails()
            NotificationCenter.default.post(name: SessionNotification, object: nil, userInfo: ["pushData":(response.notification.request.content.userInfo as NSDictionary)["type"] as! String])
            
            
        }else if (response.notification.request.content.userInfo as NSDictionary)["type"] as! String == "5"{
            
            
            if abs(response.notification.date.timeIntervalSinceNow) > 30
            {
                print("TIME EXPAIRED")
                
                CommonMethods.alertView(view: (self.window?.rootViewController)!, title: ALERT_TITLE, message: "Request time expaired", buttonTitle: "Ok")
                
            }
            else
            
                
            
            {
            
            
            //REQUEST BOOKING
                      
            print("5")
            NotificationCenter.default.post(name: notificationNameFCM, object: nil, userInfo: ["pushData":NotificationDict,"type":(response.notification.request.content.userInfo as NSDictionary)["type"] as! String,"aps":(((response.notification.request.content.userInfo as NSDictionary)["aps"] as! NSDictionary)["alert"] as! NSDictionary)["body"] as! String])
            
            
            
            
            
            
            TrainerProfileDictionary = ["pushData":NotificationDict,"type":(response.notification.request.content.userInfo as NSDictionary)["type"] as! String,"aps":(((response.notification.request.content.userInfo as NSDictionary)["aps"] as! NSDictionary)["alert"] as! NSDictionary)["body"] as! String] as NSDictionary
            }
          
        }

        completionHandler()
    }
}
