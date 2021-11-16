//
//  AppDelegate.swift
//  Eventhogh
//
//  Created by Gareth Fong on 12/3/20.
//  Copyright © 2020 Gareth Fong. All rights reserved.
//

import UIKit
import GoogleSignIn

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        do {
            try setCredential()
        } catch {
            fatalError("Error in setting up Google Sign-In")
        }
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        
        // use default scene configuration in the info.plist
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }
    
    //MARK: - Google sign-in
    @available(iOS 9.0, *)
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        return GoogleSignIn.handle(url: url)
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return GoogleSignIn.handle(url: url)
    }
    
    func setCredential() throws{
        //setup the app configuration from the credential.plist
        let credential = try ETPList<CredentialsPList>(fileName: "credentials")
        GoogleSignIn.setClientID(with: credential.data.clientID)
        GoogleSignIn.setScopes(scopes: [credential.data.driveScope, credential.data.sheetsScope])
        GoogleSignIn.setDelegate(delegate: self)
        GoogleSignIn.restorePreviousSignIn()
    }
}
//MARK: - Google Sign-in Delegate
extension AppDelegate : GIDSignInDelegate {
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
        if let user = user{
            GoogleSignIn.accessToken = user.authentication.accessToken
            
            // Perform any operations on signed in user here.
            //        let userId = user.userID                  // For client-side use only!
            //        let idToken = user.authentication.idToken // Safe to send to the server
            //        let fullName = user.profile.name
            //        let givenName = user.profile.givenName
            //        let familyName = user.profile.familyName
            //        let email = user.profile.email
            
            //        AppDelegate._gmail.wrappedValue = user.profile.email
            
            // Post notification after user successfully sign in
            NotificationCenter.default.post(name: .signInGoogleCompleted, object: nil)
        }
        
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        
        //AppDelegate._gmail.wrappedValue = ""
        GoogleSignIn.disconnect()
        
        print("didDisconnectWith")
    }
    
    
    class func getAppDelegate() -> AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    func getDocDir() -> String {
        return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    }
}
// MARK:- Notification names
extension Notification.Name {
    
    /// Notification when user successfully sign in using Google
    static var signInGoogleCompleted: Notification.Name {
        return .init(rawValue: #function)
    }
}
