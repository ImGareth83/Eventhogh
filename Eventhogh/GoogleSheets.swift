//
//  GoogleSheets.swift
//  Eventhogh
//
//  Created by Gareth Fong on 18/2/20.
//  Copyright © 2020 Gareth Fong. All rights reserved.
//

import Foundation

class GoogleSheets {
    
    let spreadsheetId : String
    let accessToken   : String
    var website       : String
    
    typealias retrieveResponse = (Result<GoogleValues?,Error>) -> Void
    typealias updateResponse = (Result<GoogleSheetUpdate?,Error>) -> Void
    typealias sqlResponse = (Result<Response?,Error>) -> Void

    init(spreadsheetId : String, accessToken : String){
        self.accessToken   = accessToken
        self.spreadsheetId = spreadsheetId
        
        do {
            let credential = try ETPList<CredentialsPList>(fileName: "credentials")
            website=credential.data.sheetsURL
        } catch{
            fatalError("Error in setting up Google Sheets")
        }
        
        self.website+=spreadsheetId
    }
    
    //https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets.values/get
    func getSpreadsheet(withRange: String, completion: @escaping retrieveResponse){
        
        let url = website+"/values/\(withRange)"
        
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod="GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        ETWebservice().download(of: GoogleValues.self, from: request) { (result) in
            switch result {
                case .failure(let error): completion(.failure(error))
                case .success(let files):completion(.success(files))
            }
        }
    }
    
    //query api https://developers.google.com/chart/interactive/docs/querylanguage
    func getSpreadsheet(by query: String, completion: @escaping sqlResponse){
        
//        let url = "https://docs.google.com/a/google.com/spreadsheets/d/\(spreadsheetId)"+"/gviz/tq?tq=\(query)"
        
        var url = "https://docs.google.com/a/google.com/spreadsheets/d/\(spreadsheetId)"
        url = url + "/gviz/tq?tq=\(query)"
        url = url + "&access_token=\(accessToken)"
        
        print("\(url)")
        
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod="GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        ETWebservice().download(of: Response.self, from: request) { (result) in
            switch result {
                case .failure(let error): completion(.failure(error))
                case .success(let table): completion(.success(table))
            }
        }
    }
    
    //https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets.values/update
    func updateSpreadsheet(sheets: GoogleValues, completion: @escaping updateResponse){

        let withRange = sheets.range

        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(sheets) else {
            return
        }
        
//        print(String(data: data, encoding: .utf8)!)

        let userSheet = website+"/values/\(withRange)?valueInputOption=USER_ENTERED"

        var request = URLRequest(url: URL(string: userSheet)!)
        request.httpMethod = "PUT"
        request.httpBody   = data
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        ETWebservice().download(of: GoogleSheetUpdate.self, from: request) { (result) in
            switch result {
                case .failure(let error): completion(.failure(error))
                case .success(let response): completion(.success(response))
            }
        }
    }
    
     //query api https://developers.google.com/chart/interactive/docs/querylanguage
        func findRow(by query: String, completion: @escaping sqlResponse){
            
    //        let url = "https://docs.google.com/a/google.com/spreadsheets/d/\(spreadsheetId)"+"/gviz/tq?tq=\(query)"
            
            var url = "https://docs.google.com/a/google.com/spreadsheets/d/\(spreadsheetId)"
            url = url + "/gviz/tq?tq=\(query)"
            url = url + "&access_token=\(accessToken)"
            
            print("\(url)")
            
            var request = URLRequest(url: URL(string: url)!)
            request.httpMethod="GET"
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            
            ETWebservice().download(of: Response.self, from: request) { (result) in
                switch result {
                    case .failure(let error): completion(.failure(error))
                    case .success(let table): completion(.success(table))
                }
            }
        }
}
