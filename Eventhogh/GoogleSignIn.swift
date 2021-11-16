//
//  GoogleService.swift
//  Eventhogh
//
//  Created by Gareth Fong on 17/2/20.
//  Copyright © 2020 Gareth Fong. All rights reserved.
//

import Foundation
import GoogleSignIn

class GoogleSignIn : NSObject{
    static var accessToken : String = ""
    
    //MARK: - Google Sign-in
    static func setClientID(with id:String) {
        GIDSignIn.sharedInstance().clientID = id
    }
    
    static func clientID() -> String {
        GIDSignIn.sharedInstance().currentUser.authentication.clientID
    }
    
    static func setDelegate(delegate : GIDSignInDelegate) {
        GIDSignIn.sharedInstance().delegate = delegate
    }
    
    static func handle(url:URL)->Bool {
        GIDSignIn.sharedInstance().handle(url)
    }
    
    static func setPresentingViewController(_ vc: UIViewController){
        GIDSignIn.sharedInstance().presentingViewController=vc
    }
    
    static func presentViewController() -> UIViewController {
        GIDSignIn.sharedInstance().presentingViewController
    }
    
    static func signIn(){
        GIDSignIn.sharedInstance()?.signIn()
    }
    
    static func hasPreviousSignIn()->Bool{
        GIDSignIn.sharedInstance().hasPreviousSignIn()
    }
    
    static func restorePreviousSignIn(){
        GIDSignIn.sharedInstance().restorePreviousSignIn()
    }
    
    static func signOut(){
        GoogleSignIn.accessToken=""
        GIDSignIn.sharedInstance().signOut()
    }
    
    static func currentUser()->GIDAuthentication?{
        return GIDSignIn.sharedInstance()?.currentUser?.authentication
    }
    
    
    static func setAccessToken() {
        guard let token = GIDSignIn.sharedInstance().currentUser.authentication.accessToken else {
            fatalError("Error in authenticating access token")
        }        
        GoogleSignIn.accessToken = token
    }
    
    static func getToken() {
        GIDSignIn.sharedInstance()?.currentUser.authentication.getTokensWithHandler({ (auth, error) in
            guard error == nil else { return }
            guard let auth  = auth else { return }
            GoogleSignIn.accessToken = auth.accessToken
        })
    }
    
    static func refreshToken() {
        GIDSignIn.sharedInstance()?.currentUser.authentication.refreshTokens(handler: { (auth, error) in
            guard error == nil else { return }
            guard let auth  = auth else { return }
            GoogleSignIn.accessToken = auth.accessToken
        })
    }
    
    static func setScopes(scopes : [String]){
        GIDSignIn.sharedInstance().scopes=scopes
    }
    
    static func getScopes() -> [Any]{
        (GIDSignIn.sharedInstance().currentUser?.grantedScopes)!
    }
    
    static func disconnect(){
        GIDSignIn.sharedInstance()?.disconnect()
    }
}
