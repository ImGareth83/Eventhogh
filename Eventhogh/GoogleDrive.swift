//
//  GoogleDrive.swift
//  Eventhogh
//
//  Created by Gareth Fong on 27/2/20.
//  Copyright © 2020 Gareth Fong. All rights reserved.
//

import Foundation
class GoogleDrive {

    let accessToken : String
    let website     : String
    
    typealias result = (Result<[GoogleFile]?,Error>) -> Void
    
    init(accessToken : String){
        self.accessToken = accessToken
        
        do {
            let credential = try ETPList<CredentialsPList>(fileName: "credentials")
            website=credential.data.driveURL
        } catch{
            fatalError("Error in setting up Google Drive")
        }
    }

    
    func getFiles(completion: @escaping result) {
        
        guard let url = URL(string: website) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        ETWebservice().download(of: GoogleFiles.self, from: request) { (result) in
            switch result {
                case .failure(let error): completion(.failure(error))
                case .success(let files): completion(.success(files.files))
            }
        }
        
    }
}
