//
//  ETJSONParser.swift
//  Eventhogh
//
//  Created by Gareth Fong on 18/3/20.
//  Copyright © 2020 Gareth Fong. All rights reserved.
//

import Foundation
import Combine

class ETWebservice {
    
    enum ETWebError: Error {
        case invalidResponse
        case invalidData
        case decodingError
        case serverError
    }
    
    typealias result<T> = (Result<T, Error>) -> Void
    
    func download<T: Codable>(of type: T.Type, from url: URLRequest, completion: @escaping result<T>) {
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
            }
            
            guard let response = response as? HTTPURLResponse else {
                completion(.failure(ETWebError.invalidResponse))
                return
            }
                        
            if HttpStatusCode.status(code: response.statusCode) == HttpStatus.success {
                if let data = data {
                    do {
                        
                        let decodedData = try JSONDecoder().decode(T.self, from: data)
                        completion(.success(decodedData))
                    }
                    catch {
                        print("decoding error : \(error)")

                        print("decoding data : \(String(decoding: data, as: UTF8.self))")
                        completion(.failure(ETWebError.decodingError))
                    }
                } else {
                    completion(.failure(ETWebError.invalidData))
                }
            } else {
                completion(.failure(ETWebError.serverError))
            }
        }.resume()
    }
}

