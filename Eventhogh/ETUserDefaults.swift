//
//  ETUserDefaults.swift
//  Eventhogh
//
//  Created by Gareth Fong on 3/9/20.
//  Copyright © 2020 Gareth Fong. All rights reserved.
//

import Foundation
@propertyWrapper

struct ETUserDefaults<T> {
    
    private let key : String
    private let defaultValue : T
    var storage = UserDefaults.standard
    
    init(key : String, defaultValue : T) {
        self.key = key
        self.defaultValue = defaultValue
    }
    
    var wrappedValue : T {
        set{
            storage.set(newValue, forKey: key)
            storage.synchronize()
        }
        get{
            return storage.bool(forKey: key) as? T ?? defaultValue
        }
    }
    /*
     //Usage : Preference data that can be presented in Switch / Action Sheets / Segmented Control ? Store it in UserDefaults
     @ETUserDefaults(key: "gmail", defaultValue: "") static var gmail : String
     @ETUserDefaults(key: "idToken", defaultValue: "") static var idToken : String
     AppDelegate._gmail.wrappedValue = user.profile.email
     */
}
