//
//  PList.swift
//  Eventhogh
//
//  Created by Gareth Fong on 12/3/20.
//  Copyright © 2020 Gareth Fong. All rights reserved.
//

import Foundation

// A class to read and decode strongly typed values in `plist` files.
public class ETPList<Value: Codable> {
    
    // Data read for file
    public let data: Value
    
    //MARK: - Section Heading Initializations
    // Initialize a new Plist parser with given codable structure.
    // file: source of the plist (Info.Plist)
    public init(_ file: ETPList.Source = .infoPlist(Bundle.main)) throws {
        let rawData = try file.data()
        let decoder = JSONDecoder()
        self.data   = try decoder.decode(Value.self, from: rawData)
    }
    
    //constructor for other Plist
    public init(fileName : String) throws{
        let file : ETPList.Source = .plist(fileName, Bundle.main)
        let rawData = try file.data()
        let decoder = PropertyListDecoder()
        
        self.data   = try decoder.decode(Value.self, from: rawData)
    }
    
    // - infoPlist: main bundel's Info.plist file
    // - plist: other plist file with custom name
    public enum Source {
        case infoPlist(_: Bundle)
        case plist    (_: String, _: Bundle)
        
        // Get the raw data inside given plist file
        internal func data() throws -> Data {
            
            switch self {
                
            case .infoPlist(let bundle):
                guard let infoDict = bundle.infoDictionary else {
                    throw ConfigureError.fileNotFound
                }
                return try JSONSerialization.data(withJSONObject: infoDict)
                
            case .plist(let filename, let bundle):
                guard let path = bundle.path(forResource: filename, ofType: "plist") else {
                    throw ConfigureError.fileNotFound
                }
                return try Data(contentsOf: URL(fileURLWithPath: path))
            }
        }
        
    }
}

enum ConfigureError: Error {
    case fileNotFound
}

//MARK: - Section Heading PList Structs
public struct CredentialsPList: Codable {
    public let clientID     : String
    public let driveScope   : String
    public let sheetsScope  : String
    public let driveURL     : String
    public let sheetsURL    : String
    
    enum CodingKeys: String, CodingKey {
        case clientID       = "CLIENT_ID"
        case driveScope     = "DRIVE_SCOPE"
        case sheetsScope    = "SHEETS_SCOPE"
        case driveURL       = "GDRIVE_V3"
        case sheetsURL      = "SHEETS_V4"
    }
}

public struct InfoPList: Codable {
    
    public struct Configuration: Codable {
        
        //these are keys in the Configuration dictionary
        
        //public let url: URL?
        public let labelFolder : String
        public let labelFile   : String
        public let templateKey : Int
    }
    
    //Configuration is the dictionary in the info.plist
    public let Configuration: Configuration
    
}
