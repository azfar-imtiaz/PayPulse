//
//  PayPulseApp.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2024-11-15.
//

import SwiftUI
import UserNotifications
import Toasts

@main
struct PayPulseApp: App {
    
    @StateObject var authManager = AuthManager.shared
    
    private let apiClient: PayPulseAPIClient
    
    private let authService: AuthService
    private let invoiceService: InvoiceService
    private let userService: UserService
    
    init() {
        _authManager = StateObject(wrappedValue: AuthManager.shared)
        
        self.apiClient = PayPulseAPIClient(authManager: AuthManager.shared)
        
        self.authService = AuthService(apiClient: apiClient, authManager: AuthManager.shared)
        self.invoiceService = InvoiceService(apiClient: apiClient)
        self.userService = UserService(apiClient: apiClient)
        
        AuthManager.shared.setServices(
            apiClient: self.apiClient,
            authService: self.authService,
            invoiceService: self.invoiceService,
            userService: self.userService
        )
    }
    
    var body: some Scene {
        WindowGroup {
            /*
            ContentView(
                invoiceService: invoiceService,
                userService: userService
            )
                .installToast(position: .bottom)
                .environmentObject(authManager)
             */
            
            if authManager.isAuthenticated {
                ContentView(
                    invoiceService: invoiceService,
                    userService: userService
                )
                    .installToast(position: .bottom)
                    .environmentObject(authManager)
            } else {
                AuthView(authService: authService)
                    .environmentObject(authManager)
            }
             
            
            /*
            AuthView(authService: authService)
                .environmentObject(authManager)
             */
            
        }
    }
    
    /*
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    init() {
        
        let credentialsProvider = AWSCognitoCredentialsProvider(
            regionType: .EUWest1,
            identityPoolId: ProcessInfo.processInfo.environment["IDENTITY_POOL_ID"]!
        )

        let serviceConfiguration = AWSServiceConfiguration(
            region: .EUWest1,
            credentialsProvider: credentialsProvider
        )

        AWSServiceManager.default().defaultServiceConfiguration = serviceConfiguration
        
        AWSMobileClient.default().initialize { (state, error) in
            if let error = error {
                print("Error initializing AWSMobileClient: \(error.localizedDescription)")
            } else {
                print("AWSMobileClient initialized: \(state?.rawValue ?? "Unknown state")")
            }
        }
        
        UINavigationBar.appearance().largeTitleTextAttributes = [
            .font: UIFont(name: Typography.FontName.extraBold, size: Typography.Size.navigation)!,
            .foregroundColor: UIColor(Color.secondaryDarkGray)
        ]
        UINavigationBar.appearance().titleTextAttributes = [
            .font: UIFont(name: Typography.FontName.medium, size: Typography.Size.headline)!,
            .foregroundColor: UIColor(Color.secondaryDarkGray)
        ]
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .installToast(position: .bottom)
                .onAppear {
                    requestNotificationsPermission()
                }
        }
    }
    
    func requestNotificationsPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                print("Error requesting notifications authorization: \(error)")
            } else {
                print("Notifications authorization granted: \(granted)")
            }
        }
        
        UIApplication.shared.registerForRemoteNotifications()
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // convert the device token to a string
        let tokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("Device token: \(tokenString)")
        
        // initialize AWS
        let credentialsProvider = AWSStaticCredentialsProvider(
            accessKey: ProcessInfo.processInfo.environment["AWS_ACCESS_KEY"]!,
            secretKey: ProcessInfo.processInfo.environment["AWS_SECRET_KEY"]!
        )
        let configuration = AWSServiceConfiguration(region: .EUWest1, credentialsProvider: credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        
        // register the device token with SNS
        let sns = AWSSNS.default()
        let request = AWSSNSCreatePlatformEndpointInput()
        request?.platformApplicationArn = ProcessInfo.processInfo.environment["PLATFORM_APPLICATION_ARN"]!
        request?.token = tokenString
        
        if let request = request {
            sns.createPlatformEndpoint(request).continueWith { (task) -> Any? in
                if let error = task.error {
                    print("Error creating endpoint: \(error)")
                } else if let result = task.result {
                    print("Created endpoint ARN: \(result.endpointArn ?? "nil")")
                }
                return nil
            }
        }
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications: \(error.localizedDescription)")
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // set the UNUserNotificationCenter delegate
        UNUserNotificationCenter.current().delegate = self
        return true
    }
    
    // called when a notification is delivered while the app is in the foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // TODO: Figure out why this gets called twice.
        let userInfo = notification.request.content.userInfo
        print("Notification receieved in foreground: \(userInfo)")
        
//        if let invoiceID = userInfo["invoiceID"] as? String {
//            print("Invoice ID: \(invoiceID)")
//        }
        completionHandler([.banner, .sound, .badge])
    }
    
    // called when a user interacts with a notification (background or foreground)
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        print("Notification interaction: \(userInfo)")
        
        if let invoiceID = userInfo["invoiceID"] as? String {
            print("Invoice ID: \(invoiceID)")
            // TODO: Handle opening the invoice here
        }
        completionHandler()
    }
     */
}
