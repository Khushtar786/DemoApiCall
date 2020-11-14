//
//  NetworkHttpClient.swift
//  NetworkManagerDemo
//
//  Created by Honey Maheshwari on 02/06/20.
//  Copyright © 2020 Honey Maheshwari. All rights reserved.
//

import Foundation

struct AppSession {
    static let shared = AppSession()
    var session: URLSession
    
    init() {
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        configuration.urlCache = nil
        session = URLSession(configuration: configuration)
    }
}

protocol NetworkHttpClient {
    func callRestAPIWith(_ url: URL, httpMethod: HttpMethod, parameters: [String: Any], headers: [String: String], completionHandler: @escaping HttpClientResponseBlock)
    func getAllRunningTasks(completionHandler: @escaping ([URLSessionTask]) -> Void)
    func cancelAllAPICalls()
    func cancelTaskWithUrl(_ url: URL)
}

extension NetworkHttpClient {
    
    func callRestAPIWith(_ url: URL, httpMethod: HttpMethod, parameters: [String: Any], headers: [String: String], completionHandler: @escaping HttpClientResponseBlock) {
        let request = enqueueRequestWith(url, httpMethod: httpMethod, parameters: parameters, headers: headers)
        enqueueDataTaskWith(request, completionHandler: completionHandler)
    }
    
    private func enqueueRequestWith(_ url: URL, httpMethod: HttpMethod, parameters: [String: Any], headers: [String: String]) -> URLRequest {
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 30.0)
        request.httpMethod = httpMethod.rawValue
        request.allHTTPHeaderFields = headers
        if headers["Content-Type"] == nil {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        request.setValue("no-cache", forHTTPHeaderField: "Cache-Control")
        
        switch httpMethod {
        case .post:
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: JSONSerialization.WritingOptions())
            } catch let error {
                print("error while creating post request -> \(error.localizedDescription)")
            }
        case .put:
            if parameters.count > 0 {
                request.httpBody = query(parameters).data(using: .utf8, allowLossyConversion: false)
            }
        case .delete:
            if let jsonData = try? JSONSerialization.data(withJSONObject: parameters) {
                request.httpBody = jsonData
            }
        case .get:
            if let encodedURL = URLEncode(url: url, parameters: parameters) {
                request.url = encodedURL
            }
        }
        return request
    }
    
    private func enqueueDataTaskWith(_ request: URLRequest, completionHandler: @escaping HttpClientResponseBlock) {
        let session = AppSession.shared.session
        let dataTask = session.dataTask(with: request, completionHandler: { (data, urlResponse, error) -> Void in
            var statusCode = Int.max
            var allHeaderFields = [String: Any]()
            if let httpResponse = urlResponse as? HTTPURLResponse {
                statusCode = httpResponse.statusCode
                allHeaderFields = (httpResponse.allHeaderFields as? [String: Any]) ?? [:]
            }
            DispatchQueue.main.async {
                let response = HttpClientResponse(data: data, headers: allHeaderFields, error: error, statusCode: statusCode, url: request.url)
                completionHandler(response)
            }
        })
        dataTask.resume()
    }
    
    func getAllRunningTasks(completionHandler: @escaping ([URLSessionTask]) -> Void) {
        let session = AppSession.shared.session
        session.getAllTasks { (tasks) in
            let runningTasks = tasks.filter({ $0.state == .running })
            completionHandler(runningTasks)
        }
    }
    
    func cancelTaskWithUrl(_ url: URL) {
        getAllRunningTasks { (tasks) in
            tasks.filter({ $0.originalRequest?.url == url }).first?.cancel()
        }
    }
    
    func cancelAllAPICalls() {
        getAllRunningTasks { (tasks) in
            _ = tasks.map({ $0.cancel() })
        }
    }
    
    // MARK: - Encoding
    
    private func URLEncode(url: URL, parameters: [String: Any] = [:]) -> URL? {
        guard !parameters.isEmpty else {
            return nil
        }
        if var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false), !parameters.isEmpty {
            let percentEncodedQuery = (urlComponents.percentEncodedQuery.map { $0 + "&" } ?? "") + query(parameters)
            urlComponents.percentEncodedQuery = percentEncodedQuery
            return urlComponents.url
        }
        return nil
    }
    
    private func JSONEncode(url: URL, parameters: [String: Any]?) -> Data? {
        guard parameters != nil else {
            return nil
        }
        guard !parameters!.isEmpty else {
            return nil
        }
        return query(parameters!).data(using: .utf8, allowLossyConversion: false)!
    }
    
    private func query(_ parameters: [String: Any]) -> String {
        var components: [(String, String)] = []
        for key in parameters.keys.sorted(by: <) {
            let value = parameters[key]!
            components += queryComponents(fromKey: key, value: value)
        }
        return components.map { "\($0)=\($1)" }.joined(separator: "&")
    }
    
    private func queryComponents(fromKey key: String, value: Any) -> [(String, String)] {
        var components: [(String, String)] = []
        if let dictionary = value as? [String: Any] {
            for (nestedKey, value) in dictionary {
                components += queryComponents(fromKey: "\(key)[\(nestedKey)]", value: value)
            }
        } else if let array = value as? [Any] {
            for value in array {
                components += queryComponents(fromKey: "\(key)[]", value: value)
            }
        } else if let value = value as? NSNumber {
            if value.isBoolean {
                components.append((escape(key), escape((value.boolValue ? "1" : "0"))))
            } else {
                components.append((escape(key), escape("\(value)")))
            }
        } else if let bool = value as? Bool {
            components.append((escape(key), escape((bool ? "1" : "0"))))
        } else {
            components.append((escape(key), escape("\(value)")))
        }
        return components
    }
    
    private func escape(_ string: String) -> String {
        let generalDelimitersToEncode = ":#[]@"
        let subDelimitersToEncode = "!$&'()*+,;="
        var allowedCharacterSet = CharacterSet.urlQueryAllowed
        allowedCharacterSet.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        return string.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) ?? string
    }
    
}

extension NSNumber {
    fileprivate var isBoolean: Bool { return CFBooleanGetTypeID() == CFGetTypeID(self) }
}
