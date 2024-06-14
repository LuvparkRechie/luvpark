
import UIKit
import Flutter
import GoogleMaps
import awesome_notifications

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
        
       
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate}

        GeneratedPluginRegistrant.register(with: self)  
 
        
        SwiftAwesomeNotificationsPlugin.setPluginRegistrantCallback { registry in          
            SwiftAwesomeNotificationsPlugin.register(
                with: registry.registrar(forPlugin: "io.flutter.plugins.awesomenotifications.AwesomeNotificationsPlugin")!)          
             
        }
        
        
        // Return the result of the superclass implementation of didFinishLaunchingWithOptions
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
