//
//  File.swift
//  RickAndMorty
//
//  Created by Eric Rojas Pech on 02/12/23.
//

import Foundation

struct Client {
    let session = URLSession.shared
    let baseUrl: String
    private let contentType: String
    
    
    enum NetworkErrors: Error {
        case conecction
        case invalidRequest
        case invalidResponse
        case client
        case server
        
    }
    
    
    init(baseUrl: String, contentType:String = "application/json") {
        self.baseUrl = baseUrl
        self.contentType = contentType
    }
    
    typealias requestHandler = ((Data?) -> Void)
    typealias errorHandler = ((NetworkErrors) -> Void)
    
    func get (path: String, query: [String:String] = [:], success: requestHandler?, failure: errorHandler? = nil){
        request(method: "GET", path: path, query: query, body: nil, success: success, failure: failure)
    }
    
    
    
    func request(method: String, path: String, query: [String:String] = [:], body: Data?, success: requestHandler?, failure: errorHandler? = nil ){
        guard let request = buildRequest(method: method, path: path, query: query, body: body) else{
            failure?(NetworkErrors.invalidRequest)
            return
        }
        
        let task = session.dataTask(with: request) { data, response, error in
            if let err = error {
                #if DEBUG
                debugPrint(err)
                #endif
                failure?(NetworkErrors.conecction)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                failure?(NetworkErrors.invalidResponse)
                return
            }
            
            let status = StatusCode(rawValue: httpResponse.statusCode)
            #if DEBUG
            print("Status: \(httpResponse.statusCode)")
            debugPrint(httpResponse)
            #endif
            switch status {
            case .success:
                success?(data)
            case .clientError:
                failure?(NetworkErrors.client)
            case .serverError:
                failure?(NetworkErrors.server)
            default:
                failure?(NetworkErrors.invalidResponse)
            }
            
        }
        task.resume()
    }
    
    private func buildRequest(method: String, path: String, query: [String:String] = [:], body: Data?) -> URLRequest? {
        guard var urlComp = URLComponents(string: baseUrl) else { return nil }
        urlComp.path = path
        urlComp.queryItems = query.map { (key, value) in
            URLQueryItem(name: key, value: value)
        }
        
        guard let url = urlComp.url else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.addValue(contentType, forHTTPHeaderField: "Content-Type")
        
        request.httpBody = body
        #if DEBUG
        debugPrint(request)
        #endif
        return request
    }
}
