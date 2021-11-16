//
//  HttpStatus.swift
//  Eventhogh
//
//  Created by Gareth Fong on 18/3/20.
//  Copyright © 2020 Gareth Fong. All rights reserved.
//

import Foundation

struct HttpStatusCode {
    static func status(code : Int) -> HttpStatus {
        switch code {
        case 100..<200:return .informational
        case 200..<300:return .success
        case 300..<400:return .redirection
        case 400..<500:return .clientError
        case 500..<600:return .serverError
        default       :return .undefined
        }
    }
}
enum HttpStatus {
    case informational
    case success
    case redirection
    case clientError
    case serverError
    case undefined
}

