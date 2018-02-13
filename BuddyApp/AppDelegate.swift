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
import IQKeyboardManagerSwift
import UserNotifications
import GoogleMaps
import Braintree
import BraintreeDropIn
import Firebase
import FirebaseMessaging
import GooglePlaces
//import Google
import Stripe
import TwitterKit
import TwitterCore
import GoogleSignIn

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
    var isInSessionRoutePageAppDelegate = Bool()
    var window: UIWindow?
    let notificationNameFCM = Notification.Name("FCMNotificationIdentifier")
    let SessionNotification = Notification.Name("SessionNotification")
    var TrainerProfileDictionary: NSDictionary!
    
    var chatpushnotificationBool = Bool()
    var isLaunchFromBackGroundState = Bool()
    var isLaunchFromKilledState = Bool()
    var profileImageData: NSData = NSData()
    
    //JOSE 2-2-2018
    var CancelStopBool = Bool()
    /////
    
    
    //MARK: - APPDELEGATE FUNCTIONS
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
//        if userDefaults.value(forKey: "devicetoken") == nil {
//            print("***** configureFirebase Call in AppDelegate ******")
//            configureFirebase(application: application)
//        }
        
        profileImageData = NSData()
        
        if application.applicationState == .inactive {
            print("***** App From Inactive State *****")
            isLaunchFromKilledState = true
        }else if application.applicationState == .background{
            print("***** App From Background State *****")
            isLaunchFromBackGroundState = true
        }
        
        application.applicationIconBadgeNumber = 0
        
        configureFirebase(application: application)
        
        NewRelic.start(withApplicationToken:NEW_RELIC_KEY)
        
        GMSServices.provideAPIKey(GOOGLE_API_KEY)
        GMSPlacesClient.provideAPIKey(GOOGLE_API_KEY)
        GIDSignIn.sharedInstance().clientID = GID_CLIENT_ID

        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().shouldFetchBasicProfile = true

        IQKeyboardManager.sharedManager().enable = true
        
        guard let gai = GAI.sharedInstance() else {
            assert(false, "Google Analytics not configured correctly")
            return true
        }
        
        gai.tracker(withTrackingId: GOOGLE_TRACKER_ID)
        gai.trackUncaughtExceptions = true
        // Optional: set Logger to VERBOSE for debug information.
        // Remove before app release.
        gai.logger.logLevel = .verbose;
        
        BTAppSwitch.setReturnURLScheme(PAYPAL_PAYMENT_RETURN_URL)
        
        Stripe.setDefaultPublishableKey(STRIPE_PUBLISHER_KEY)
        
        TWTRTwitter.sharedInstance().start(withConsumerKey: TWITTER_CONSUMER_KEY, consumerSecret: TWITTER_CONSUMER_SECRET)
        
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
        
        if url.scheme?.localizedCaseInsensitiveCompare(PAYPAL_PAYMENT_RETURN_URL) == .orderedSame {
            print("Paypal open url in AppDelegate")
            return BTAppSwitch.handleOpen(url, sourceApplication: sourceApplication)
        }
        
        if url.absoluteString.contains("twitterkit"){
            return TWTRTwitter.sharedInstance().application(application, open: url, options: [:])
        }
        
        return googleDidHandle || facebookDidHandle
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
        if (error == nil)
        {
            print("**** Google Signup Response in AppDelegate ******")
            let userId = user.userID
            let idToken = user.authentication.idToken
            let name = user.profile.name
            let email = user.profile.email
            
            print(userId!)
            print(idToken!)
            print(name!)
            print(email!)
            let userImageURL = user.profile.imageURL(withDimension: 200)
            print(userImageURL!)
            
            let googleDict = ["name" : name!,
                              "email" : email!,
                              "userid" : userId!,
                              "idToken" : idToken!,
                              "userimage" : userImageURL!] as [String : Any]
            
            let notificationName = Notification.Name("NotificationIdentifier")
            
            // Post notification
            NotificationCenter.default.post(name: notificationName, object: nil, userInfo: ["googledata":googleDict])
        }else{
            print("\(error.localizedDescription)")
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    
        print("**** didRegisterForRemoteNotificationsWithDeviceToken *****")
        
        Messaging.messaging().apnsToken = deviceToken as Data
        Messaging.messaging().setAPNSToken(deviceToken as Data, type: .prod)
        customDelegateCall()
    }
    
    func customDelegateCall() {
        if let deviceTokenFromUserDefault = userDefaults.value(forKey: "devicetoken") as? String{
            print("*** deviceTokenFromUserDefault ** :\(deviceTokenFromUserDefault)")
            print("================ Firebase Delegate Call =============")
            connectToFcm()
            delegateFCM?.tokenReceived()
        }
    }
    
    //MARK: - FCM TOKEN RECEIVE
    
    func tokenRefreshNotification(notification: NSNotification) {
        
        guard let refreshedToken = InstanceID.instanceID().token()
            else {
                return
        }
        
        print("*********** InstanceID token: \(refreshedToken)")
        let data = refreshedToken.data(using: .utf8)!
        
        Messaging.messaging().apnsToken = data as Data
        Messaging.messaging().setAPNSToken(data, type: .prod)
       // InstanceID.instanceID().setAPNSToken(data, type: .prod)
        userDefaults.set(refreshedToken, forKey: "devicetoken")
               
        connectToFcm()
        delegateFCM?.tokenReceived()
        
        //-----
        
//        let token = String(format: "%@", deviceToken as CVarArg)
//        debugPrint("*** deviceToken: \(token)")
//        //        #if RELEASE_VERSION
//        //            InstanceID.instanceID().setAPNSToken(deviceToken as Data, type:FIRInstanceIDAPNSTokenType.prod)
//        //        #else
//        //            InstanceID.instanceID().setAPNSToken(deviceToken as Data, type:InstanceIDAPNSTokenType.sandbox)
//        //        #endif
//        Messaging.messaging().apnsToken = deviceToken as Data
//        let firebaseToken = InstanceID.instanceID().token()!
//        debugPrint("Firebase Token:",InstanceID.instanceID().token() as Any)
//        userDefaults.set(firebaseToken, forKey: "devicetoken")
//        print("========== InstanceID token1 didRegisterForRemoteNotificationsWithDeviceToken: \(firebaseToken)")

    }
    
    func connectToFcm() {
        print("**** Connect To FCM ****")
        // Won't connect since there is no token
//        guard FIRInstanceID.instanceID().token() != nil else {
//            return
//        }
        
        Messaging.messaging().shouldEstablishDirectChannel = true
//        Messaging.messaging().disconnect()
//        Messaging.messaging().connect { (error) in
//            if error != nil {
//                print("Unable to connect with FCM. \(error?.localizedDescription ?? "")")
//            } else {
//                print("Connected to FCM")
//            }
//        }
    }
    
    //MARK: - APPLICATION METHODS
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        print(userInfo)
        
        print(application.backgroundTimeRemaining)
        
        let NotificationDict = (userInfo as NSDictionary)["data"] as! String
        print("RECIVE NOTIFICATION DICT",NotificationDict)
        let notificationType = (userInfo as NSDictionary)["type"] as! String
        
        if application.applicationState == .active {
            //write your code here when app is in foreground
            print("ACTIVE STATE")
            
            if notificationType == "1"{
                
                //BOOK SESSION
                userDefaults.set(true, forKey: "sessionBookedNotStarted")
                
                // Post notification
                NotificationCenter.default.post(name: notificationNameFCM, object: nil, userInfo: [
                    "pushData":NotificationDict,
                    "type":notificationType
                    ])
                
            }else if notificationType == "2"{
                print("TYPE 2")
                
                //STARTED SESSION
                userDefaults.set(false, forKey: "sessionBookedNotStarted")
//                userDefaults.removeObject(forKey: "TrainerProfileDictionary")
                
                NotificationCenter.default.post(name: SessionNotification, object: nil, userInfo: [
                    "pushData":(userInfo as NSDictionary)["type"] as! String,
                    "type":notificationType
                    ])
                
            }else if notificationType == "3"{
                
                //CANCELLED SESSION
                userDefaults.set(false, forKey: "sessionBookedNotStarted")
//                userDefaults.removeObject(forKey: "TrainerProfileDictionary")
                
                print("3")
                NotificationCenter.default.post(name: SessionNotification, object: nil, userInfo: [
                    "pushData":(userInfo as NSDictionary)["type"] as! String,
                    "type":notificationType
                    ])
                
            }else if notificationType == "4"{
                
                //COMPLETED SESSION
                userDefaults.set(false, forKey: "sessionBookedNotStarted")
                userDefaults.removeObject(forKey: "TrainerProfileDictionary")
                
                print("4")
                NotificationCenter.default.post(name: SessionNotification, object: nil, userInfo: [
                    "pushData":(userInfo as NSDictionary)["type"] as! String,
                    "type":notificationType
                    ])
                
            }else if notificationType == "5"{
                
                //REQUEST BOOKING
                
                  print("5")
                NotificationCenter.default.post(name: notificationNameFCM, object: nil, userInfo: [
                    "pushData":NotificationDict,
                    "type":notificationType,
                    "aps":(((userInfo as NSDictionary)["aps"] as! NSDictionary)["alert"] as! NSDictionary)["body"] as! String
                    ])
                
            }else if notificationType == "6"{
                // EXTEND BOOKING
                
                NotificationCenter.default.post(name: SessionNotification, object: nil, userInfo: [
                    "pushData":(userInfo as NSDictionary)["type"] as! String,
                    "type":notificationType,
                    "data":NotificationDict
                    ])
            }
        } else {
            
            if notificationType == "1"{
                
                NotificationCenter.default.post(name: notificationNameFCM, object: nil, userInfo: [
                    "pushData":NotificationDict,
                    "type":notificationType
                    ])
                
                userDefaults.set(true, forKey: "sessionBookedNotStarted")
                
                TrainerProfileDictionary = CommonMethods.convertToDictionary(text: NotificationDict )! as NSDictionary
                
                userDefaults.set(NSKeyedArchiver.archivedData(withRootObject: self.TrainerProfileDictionary), forKey: "TrainerProfileDictionary")
            }else if notificationType == "2"{
                print("TYPE 2")
                userDefaults.set(true, forKey: "sessionBookedNotStarted")
                // userDefaults.removeObject(forKey: "TrainerProfileDictionary")
                
                NotificationCenter.default.post(name: SessionNotification, object: nil, userInfo: [
                    "pushData":(userInfo as NSDictionary)["type"] as! String,
                    "type":notificationType
                    ])
                
            }else if notificationType == "3"{
                print("3")
                userDefaults.removeObject(forKey: "TimerData")
                appDelegate.timerrunningtime = false
                TrainerProfileDetail.deleteBookingDetails()
                
                NotificationCenter.default.post(name: SessionNotification, object: nil, userInfo: [
                    "pushData":(userInfo as NSDictionary)["type"] as! String,
                    "type":notificationType
                    ])
                
            }else if notificationType == "4"{
                print("4")
                userDefaults.removeObject(forKey: "TimerData")
                appDelegate.timerrunningtime = false
                TrainerProfileDetail.deleteBookingDetails()
                
                NotificationCenter.default.post(name: SessionNotification, object: nil, userInfo: [
                    "pushData":notificationType,
                    "type":notificationType
                    ])
                
            }else if notificationType == "5"{
                //REQUEST BOOKING
                
                print("5")
                NotificationCenter.default.post(name: notificationNameFCM, object: nil, userInfo: [
                    "pushData":NotificationDict,
                    "type":notificationType,
                    "aps":(((userInfo as NSDictionary)["aps"] as! NSDictionary)["alert"] as! NSDictionary)["body"] as! String
                    ])
                
                TrainerProfileDictionary = [
                    "pushData":NotificationDict,
                    "type":notificationType,
                    "aps":(((userInfo as NSDictionary)["aps"] as! NSDictionary)["alert"] as! NSDictionary)["body"] as! String
                    ] as NSDictionary

                if abs(application.backgroundTimeRemaining) > 30{
                    print("TIME EXPIRED")
                    CommonMethods.alertView(view: (self.window?.rootViewController)!, title: ALERT_TITLE, message: REQUEST_TIME_EXPIRED, buttonTitle: "Ok")
                }else{
                    NotificationCenter.default.post(name: notificationNameFCM, object: nil, userInfo: [
                        "pushData":NotificationDict,
                        "type":notificationType,
                        "aps":(((userInfo as NSDictionary)["aps"] as! NSDictionary)["alert"] as! NSDictionary)["body"] as! String])
                    
                    TrainerProfileDictionary = [
                        "pushData":NotificationDict,
                        "type":notificationType,
                        "aps":(((userInfo as NSDictionary)["aps"] as! NSDictionary)["alert"] as! NSDictionary)["body"] as! String
                        ] as NSDictionary
                }
            }else if notificationType == "6"{
//                            print(Date().daysBetweenDate(toDate: response.notification.date))
//                              let extentedTimeDict = CommonMethods.convertToDictionary(text:NotificationDict)! as NSDictionary
//                        let timeDiff = Date().daysBetweenDate(toDate: response.notification.date)
//                         let sessionTime =  Int(extentedTimeDict["extend_time"]! as! String)!*60
//                            let remaintime = 60 - timeDiff
//                            
//                            print("REMAING TIME",remaintime)
            }
        }
    }

    func applicationWillResignActive(_ application: UIApplication) {
        
        print("*********** applicationWillResignActive ***********")

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
        
        print("*********** applicationDidBecomeActive ***********")
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        FBSDKAppEvents.activateApp()
        customDelegateCall()
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

extension AppDelegate: MessagingDelegate {
    
    /// The callback to handle data message received via FCM for devices running iOS 10 or above.
    func application(received remoteMessage: MessagingRemoteMessage) {
        print("applicationReceivedRemoteMessage",remoteMessage.appData)
        
        let NotificationDict = (remoteMessage.appData as NSDictionary)["data"] as! String
        
        if (remoteMessage.appData as NSDictionary)["type"] as! String == "1"{
            // Post notification
            userDefaults.set(true, forKey: "sessionBookedNotStarted")
            
             NotificationCenter.default.post(name: notificationNameFCM, object: nil, userInfo: [
                "pushData":NotificationDict,
                "type":(remoteMessage.appData as NSDictionary)["type"] as! String
                ])
            
        }else if (remoteMessage.appData as NSDictionary)["type"] as! String == "2"{
            print("TYPE 2")
            userDefaults.set(false, forKey: "sessionBookedNotStarted")
            
            NotificationCenter.default.post(name: SessionNotification, object: nil, userInfo: [
                "pushData":(remoteMessage.appData as NSDictionary)["type"] as! String,
                "type":(remoteMessage.appData as NSDictionary)["type"] as! String
                ])
            
          //  CommonMethods.alertView(view: (self.window?.rootViewController)!, title: ALERT_TITLE, message: "Trainee has started the session", buttonTitle: "Ok")
        }else if (remoteMessage.appData as NSDictionary)["type"] as! String == "3"{
            
            userDefaults.removeObject(forKey: "TimerData")
            appDelegate.timerrunningtime = false
            userDefaults.set(false, forKey: "isCurrentlyInTrainingSession")

            TrainerProfileDetail.deleteBookingDetails()
            
            NotificationCenter.default.post(name: SessionNotification, object: nil, userInfo: [
                "pushData":(remoteMessage.appData as NSDictionary)["type"] as! String,
                "type":(remoteMessage.appData as NSDictionary)["type"] as! String
                ])
            
           // CommonMethods.alertView(view: (self.window?.rootViewController)!, title: ALERT_TITLE, message: "Session have been Cancelled", buttonTitle: "Ok")
            print("3")
        } else if (remoteMessage.appData as NSDictionary)["type"] as! String == "4"{
            print("4")
            userDefaults.removeObject(forKey: "TimerData")
            appDelegate.timerrunningtime = false
            TrainerProfileDetail.deleteBookingDetails()
            
            NotificationCenter.default.post(name: SessionNotification, object: nil, userInfo: [
                "pushData":(remoteMessage.appData as NSDictionary)["type"] as! String,
                "type":(remoteMessage.appData as NSDictionary)["type"] as! String
                ])
            
           // CommonMethods.alertView(view: (self.window?.rootViewController)!, title: ALERT_TITLE, message: "Session have been Completed", buttonTitle: "Ok")
        }else if (remoteMessage.appData as NSDictionary)["type"] as! String == "5"{
            
            
            //REQUEST BOOKING
            
            print("5")
            NotificationCenter.default.post(name: notificationNameFCM, object: nil, userInfo: [
                "pushData":NotificationDict,
                "type":(remoteMessage.appData as NSDictionary)["type"] as! String,
                "aps":((remoteMessage.appData as NSDictionary)["notification"] as! NSDictionary)["body"] as! String
                ])
            
        }else if (remoteMessage.appData as NSDictionary)["type"] as! String == "6"{
            
            
            // EXTEND BOOKING
            
            NotificationCenter.default.post(name: SessionNotification, object: nil, userInfo: [
                "pushData":(remoteMessage.appData as NSDictionary)["type"] as! String,
                "data":NotificationDict,
                "type":(remoteMessage.appData as NSDictionary)["type"] as! String
                ])
        }

    }
    
    // Registering for Firebase notifications
    func configureFirebase(application: UIApplication) {
        
        print("******* configureFirebase *******")
        Messaging.messaging().delegate = self
        FirebaseApp.configure()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.tokenRefreshNotification),
                                               name: NSNotification.Name.InstanceIDTokenRefresh, object: nil)

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
    internal func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        // FCM token updated, update it on Backend Server
        print("didRefreshRegistrationToken:\(fcmToken)")
    }
    
    
    internal func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print("remoteMessage: \(remoteMessage)") 
    }
    
    //Called when a notification is delivered to a foreground app.
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([])
        
        print("willPresent notification",notification.request.content.userInfo)
        
        let NotificationDict = (notification.request.content.userInfo as NSDictionary)["data"] as! String
        let notificationType = (notification.request.content.userInfo as NSDictionary)["type"] as! String
        let notificationAps = (notification.request.content.userInfo as NSDictionary)["aps"] as! NSDictionary
        
        if notificationType == "1"{
            
            //BOOK SESSION
            userDefaults.set(true, forKey: "sessionBookedNotStarted")
            NotificationCenter.default.post(name: notificationNameFCM, object: nil, userInfo: [
                "pushData":NotificationDict,
                "type":notificationType
                ])
            
        }else if notificationType == "2"{
            print("TYPE 2")
            
            //STARTED SESSION
            userDefaults.set(false, forKey: "sessionBookedNotStarted")
         //   userDefaults.removeObject(forKey: "TrainerProfileDictionary")
            NotificationCenter.default.post(name: SessionNotification, object: nil, userInfo: [
                "pushData":(notification.request.content.userInfo as NSDictionary)["type"] as! String,
                "type":notificationType
                ])
            
        }else if notificationType == "3"{
            
            //CANCELLED SESSION
            userDefaults.set(false, forKey: "sessionBookedNotStarted")
          //  userDefaults.removeObject(forKey: "TrainerProfileDictionary")
            userDefaults.set(false, forKey: "isCurrentlyInTrainingSession")

            print("3")
            NotificationCenter.default.post(name: SessionNotification, object: nil, userInfo: [
                "pushData":(notification.request.content.userInfo as NSDictionary)["type"] as! String,
                "type":notificationType,
                "status":notificationAps
                ])
        }else if notificationType == "4"{
            
            //COMPLETED SESSION
            userDefaults.set(false, forKey: "sessionBookedNotStarted")
            userDefaults.removeObject(forKey: "TrainerProfileDictionary")

            print("4")
            NotificationCenter.default.post(name: SessionNotification, object: nil, userInfo: [
                "pushData":(notification.request.content.userInfo as NSDictionary)["type"] as! String,
                "type":notificationType
                ])
        }else if notificationType == "5"{
            
            //REQUEST BOOKING
            print("5")
            
            NotificationCenter.default.post(name: notificationNameFCM, object: nil, userInfo: [
                "pushData" : NotificationDict,
                "type" : notificationType,
                "aps":(((notification.request.content.userInfo as NSDictionary)["aps"] as! NSDictionary)["alert"] as! NSDictionary)["body"] as! String
                ])
            
        }else if notificationType == "6"{
            // EXTEND BOOKING
             NotificationCenter.default.post(name: SessionNotification, object: nil, userInfo: [
                "pushData":(notification.request.content.userInfo as NSDictionary)["type"] as! String,
                "type":notificationType,
                "data":NotificationDict
                ])
        }else if notificationType == "8"{
            
            
            //CHAT MESSAGES
            
            NotificationCenter.default.post(name: notificationNameFCM, object: nil, userInfo: [
                "pushData":(notification.request.content.userInfo as NSDictionary)["type"] as! String,
                "type":notificationType
                ])
        }
    }
    
    //Called to let your app know which action was selected by the user for a given notification.
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        print("User Info = \(response.notification.date.timeIntervalSinceNow)")
        
        let NotificationDict = (response.notification.request.content.userInfo as NSDictionary)["data"] as! String
        print("RECIVED",NotificationDict)
        let notificationType = (response.notification.request.content.userInfo as NSDictionary)["type"] as! String

        if notificationType == "1"{
            
            NotificationCenter.default.post(name: notificationNameFCM, object: nil, userInfo: [
                "pushData":NotificationDict,
                "type":notificationType
                ])

            userDefaults.set(true, forKey: "sessionBookedNotStarted")
            TrainerProfileDictionary = CommonMethods.convertToDictionary(text: NotificationDict )! as NSDictionary
            
            userDefaults.set(NSKeyedArchiver.archivedData(withRootObject: self.TrainerProfileDictionary), forKey: "TrainerProfileDictionary")
            
        }else if notificationType == "2"{
            print("** Notif TYPE 2")
            userDefaults.set(true, forKey: "sessionBookedNotStarted")
           // userDefaults.removeObject(forKey: "TrainerProfileDictionary")
            
            if isLaunchFromKilledState {
                userDefaults.set(true, forKey: "isSessionStartedFromPush_AppKilledState")
                UserDefaults.standard.set(response.notification.date, forKey: "sessionStartedPushReceivedTime")
            }
            
            NotificationCenter.default.post(name: SessionNotification, object: nil, userInfo: [
                "pushData":(response.notification.request.content.userInfo as NSDictionary)["type"] as! String,
                "type":notificationType
                ])
            
        }else if notificationType == "3"{
            print("** Notif TYPE 3")
            
            userDefaults.removeObject(forKey: "TimerData")
            appDelegate.timerrunningtime = false
            userDefaults.set(false, forKey: "isCurrentlyInTrainingSession")

            TrainerProfileDetail.deleteBookingDetails()
            
//            if isLaunchFromKilledState {
//                userDefaults.set(true, forKey: "pushClickSessionStopFromKilledState")
//            }
//            TrainerProfileDictionary = CommonMethods.convertToDictionary(text: NotificationDict)! as NSDictionary
            
//            print("TrainerProfileDictionary:\(TrainerProfileDictionary)")
//            CommonMethods.alertView(view: (self.window?.rootViewController)!, title: ALERT_TITLE, message: "Notif 3 :\(TrainerProfileDictionary)", buttonTitle: "Ok")

            NotificationCenter.default.post(name: SessionNotification, object: nil, userInfo: [
                "pushData" : notificationType,
                "type" : notificationType
                ])
          
        }else if notificationType == "4"{
            print("** Notif TYPE 4")
            userDefaults.removeObject(forKey: "TimerData")
            appDelegate.timerrunningtime = false
            TrainerProfileDetail.deleteBookingDetails()
            NotificationCenter.default.post(name: SessionNotification, object: nil, userInfo: [
                "pushData":(response.notification.request.content.userInfo as NSDictionary)["type"] as! String,
                "type":notificationType
                ])
            
        }else if notificationType == "5"{
            
            print("** Notif TYPE 5")
            //REQUEST BOOKING

            if abs(response.notification.date.timeIntervalSinceNow)/60 > 30{
                print("TIME EXPIRED")
                CommonMethods.alertView(view: (self.window?.rootViewController)!, title: ALERT_TITLE, message: "\(REQUEST_TIME_EXPIRED))", buttonTitle: "Ok")
                
            }else{
                NotificationCenter.default.post(name: notificationNameFCM, object: nil, userInfo: [
                    "pushData":NotificationDict,
                    "type":notificationType,
                    "aps":(((response.notification.request.content.userInfo as NSDictionary)["aps"] as! NSDictionary)["alert"] as! NSDictionary)["body"] as! String
                    ])
                
                TrainerProfileDictionary = [
                    "pushData":NotificationDict,
                    "type":notificationType,
                    "aps":(((response.notification.request.content.userInfo as NSDictionary)["aps"] as! NSDictionary)["alert"] as! NSDictionary)["body"] as! String
                    ] as NSDictionary
            }
        }else if notificationType == "6"{
            
//            print(Date().daysBetweenDate(toDate: response.notification.date))
//              let extentedTimeDict = CommonMethods.convertToDictionary(text:NotificationDict)! as NSDictionary
//        let timeDiff = Date().daysBetweenDate(toDate: response.notification.date)
//         let sessionTime =  Int(extentedTimeDict["extend_time"]! as! String)!*60
//            let remaintime = 60 - timeDiff
//            
//            print("REMAINING TIME",remaintime)
        }

        completionHandler()
    }
}
