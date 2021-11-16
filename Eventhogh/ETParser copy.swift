//
//  ETParser.swift
//  Eventhogh
//
//  Created by Gareth Fong on 18/3/20.
//  Copyright © 2020 Gareth Fong. All rights reserved.
//

import Foundation
class ETJSONParser {
    
    typealias result<T> = (Result<[T], Error>) -> Void
    
    enum DataError: Error {
        case invalidResponse
        case invalidData
        case decodingError
        case serverError
    }
    
    func downloadList<T: Decodable>(of type: T.Type, from url: URL, completion: @escaping result<T>) {
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
            }
            
            guard let response = response as? HTTPURLResponse else {
                completion(.failure(DataError.invalidResponse))
                return
            }
            
            if HttpStatusCode.status(code: response.statusCode) == HttpStatus.success {
                if let data = data {
                    do {
                        let decodedData: [T] = try JSONDecoder().decode([T].self, from: data)
                        completion(.success(decodedData))
                    }
                    catch {
                        completion(.failure(DataError.decodingError))
                    }
                } else {
                    completion(.failure(DataError.invalidData))
                }
            } else {
                completion(.failure(DataError.serverError))
            }
        }.resume()
    }
}
