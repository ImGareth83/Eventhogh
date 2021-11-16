//
//  File.swift
//  Eventhogh
//
//  Created by Gareth Fong on 27/2/20.
//  Copyright © 2020 Gareth Fong. All rights reserved.
//
struct GoogleFile: Codable {
    var mimeType: String
    var id      : String
    var kind    : String
    var name    : String
}

struct GoogleFiles: Codable {
    var kind    : String
    var files   : [GoogleFile]
}
struct GoogleSheet: Codable {
    var spreadsheetId: String
    var data         : [GoogleValues]
}

struct GoogleValues: Codable {
    var range   : String
    var values  : [[String]]
    var majorDimension = "ROWS"
}


// MARK: - Welcome
struct Response: Codable {
    let version, reqID, status, sig: String
    let table: Table

    enum CodingKeys: String, CodingKey {
        case version
        case reqID = "reqId"
        case status, sig, table
    }
}

// MARK: - Table
struct Table: Codable {
    let cols: [Col]
    let rows: [Row]
    let parsedNumHeaders: Int
}

// MARK: - Col
struct Col: Codable {
    let id, label, type: String
    let pattern: String?
}

// MARK: - Row
struct Row: Codable {
    let c: [C?]
}

// MARK: - C
struct C: Codable {
    let v: String
}

struct Column: Codable {
    var id      : String
    var label   : String
    var type    : String
    var pattern : String
}
struct GoogleSheetUpdate : Codable {
    var spreadsheetId  : String
    var updatedRange   : String
    var updatedRows    : Int
    var updatedColumns : Int
    var updatedCells   : Int
}


