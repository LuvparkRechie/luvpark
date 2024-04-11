
import UIKit
import Flutter
import GoogleMaps
import flutter_local_notifications

// Subclass FlutterAppDelegate to customize Flutter's app delegate
@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    
    // Override the application(_:didFinishLaunchingWithOptions:) method
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        // Provide the API key for Google Maps services
        GMSServices.provideAPIKey("AIzaSyCaDHmbTEr-TVnJY8dG0ZnzsoBH3Mzh4cE")
        
        // Register the Flutter plugins with the app
        GeneratedPluginRegistrant.register(with: self)
        
        // Set up communication between Flutter local notifications plugin and Flutter app
        FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { registry in
            GeneratedPluginRegistrant.register(with: registry)
        }

        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
        }
        
        // Return the result of the superclass implementation of didFinishLaunchingWithOptions
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
