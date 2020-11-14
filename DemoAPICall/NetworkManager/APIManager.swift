//
//  APIManager.swift
//  NetworkManagerDemo
//
//  Created by Honey Maheshwari on 02/06/20.
//  Copyright © 2020 Honey Maheshwari. All rights reserved.
//

import Foundation
import KRProgressHUD

protocol APIManager: NetworkHttpClient {
    func performGetOperation(endPoint: String, parameters: [String: Any], headers: [String: String], showHUD: Bool, completionHandler: @escaping APIResponseBlock)

    func performPostOperation(endPoint: String, parameters: [String: Any], headers: [String: String], showHUD: Bool, completionHandler: @escaping APIResponseBlock)

    func performPutOperation(endPoint: String, parameters: [String: Any], headers: [String: String], showHUD: Bool, completionHandler: @escaping APIResponseBlock)

    func performDeleteOperation(endPoint: String, parameters: [String: Any], headers: [String: String], showHUD: Bool, completionHandler: @escaping APIResponseBlock)
    
    func getAllRunningTasksEndPoints(completionHandler: @escaping ([String]) -> Void)
    
    func cancelTask(with key: String, completion: @escaping () -> Void)
}

extension APIManager {
    
    func performGetOperation(endPoint: String, parameters: [String: Any] = [:], headers: [String: String] = [:], showHUD: Bool = true, completionHandler: @escaping APIResponseBlock) {
        if !ReachabilityManager.shared.isReachable {
            completionHandler(.failure(APIError(type: .noNetwork)))
            return
        }
        guard let url = URL(string: endPoint) else {
            completionHandler(.failure(APIError(type: .invalidURL)))
            return
        }
        displayLoader(showHUD, show: true)
        printLog("endPoint -> \(endPoint)", "parameters -> \(parameters)", "headers -> \(headers)")
        callRestAPIWith(url, httpMethod: .get, parameters: parameters, headers: headers) { (response) in
            self.displayLoader(showHUD, show: false)
            self.parseResponse(response, completionHandler: completionHandler)
        }
    }
    
    func performPostOperation(endPoint: String, parameters: [String: Any] = [:], headers: [String: String] = [:], showHUD: Bool = true, completionHandler: @escaping APIResponseBlock) {
        if !ReachabilityManager.shared.isReachable {
            completionHandler(.failure(APIError(type: .noNetwork)))
            return
        }
        guard let url = URL(string: endPoint) else {
            completionHandler(.failure(APIError(type: .invalidURL)))
            return
        }
        displayLoader(showHUD, show: true)
        printLog("endPoint -> \(endPoint)", "parameters -> \(parameters)", "headers -> \(headers)")
        callRestAPIWith(url, httpMethod: .post, parameters: parameters, headers: headers) { (response) in
            self.displayLoader(showHUD, show: false)
            self.parseResponse(response, completionHandler: completionHandler)
        }
    }
    
    func performPutOperation(endPoint: String, parameters: [String: Any] = [:], headers: [String: String] = [:], showHUD: Bool = true, completionHandler: @escaping APIResponseBlock) {
        if !ReachabilityManager.shared.isReachable {
            completionHandler(.failure(APIError(type: .noNetwork)))
            return
        }
        guard let url = URL(string: endPoint) else {
            completionHandler(.failure(APIError(type: .invalidURL)))
            return
        }
        displayLoader(showHUD, show: true)
        printLog("endPoint -> \(endPoint)", "parameters -> \(parameters)", "headers -> \(headers)")
        callRestAPIWith(url, httpMethod: .put, parameters: parameters, headers: headers) { (response) in
            self.displayLoader(showHUD, show: false)
            self.parseResponse(response, completionHandler: completionHandler)
        }
    }
    
    func performDeleteOperation(endPoint: String, parameters: [String: Any] = [:], headers: [String: String] = [:], showHUD: Bool = true, completionHandler: @escaping APIResponseBlock) {
        if !ReachabilityManager.shared.isReachable {
            completionHandler(.failure(APIError(type: .noNetwork)))
            return
        }
        guard let url = URL(string: endPoint) else {
            completionHandler(.failure(APIError(type: .invalidURL)))
            return
        }
        displayLoader(showHUD, show: true)
        printLog("endPoint -> \(endPoint)", "parameters -> \(parameters)", "headers -> \(headers)")
        callRestAPIWith(url, httpMethod: .delete, parameters: parameters, headers: headers) { (response) in
            self.displayLoader(showHUD, show: false)
            self.parseResponse(response, completionHandler: completionHandler)
        }
    }
    
    // MARK: - End Point Operations
    
    func getAllRunningTasksEndPoints(completionHandler: @escaping ([String]) -> Void) {
        getAllRunningTasks { (tasks) in
            let taskEndPoints = tasks.compactMap({ $0.originalRequest?.url?.absoluteString })
            completionHandler(taskEndPoints)
        }
    }
    
    func cancelTask(with key: String, completion: @escaping () -> Void) {
        getAllRunningTasks { (tasks) in
            for task in tasks {
                if let url = task.originalRequest?.url?.absoluteString {
                    if url.contains(key) {
                        task.cancel()
                        completion()
                        return
                    }
                }
            }
            completion()
        }
    }
    
    // MARK: - Parsing
    
    func parseResponse(_ response: HttpClientResponse, completionHandler: @escaping APIResponseBlock) {
        if let data = response.data, data.count > 0 {
            if let dictResponse = data.dictionary {
                printLog("response -> \(dictResponse)", "url -> \(String(describing: response.url))", "statusCode -> \(response.statusCode)")
                if 200...299 ~= response.statusCode {
                    let successResponse = APISuccess(json: dictResponse, headers: response.headers, url: response.url)
                    completionHandler(.success(successResponse))
                } else {
                    let error = APIError(with: nil, statusCode: response.statusCode, info: dictResponse)
                    completionHandler(.failure(error))
                }
            } else {
                printLog("response -> invalidJSON", "url -> \(String(describing: response.url))", "statusCode -> \(response.statusCode)")
                completionHandler(.failure(APIError(type: .invalidJSON)))
            }
        } else if let error = response.error {
            var apiError = APIError(with: error, statusCode: response.statusCode)
            let nsError = error as NSError
            if nsError.code == NSURLErrorCancelled {
                printLog("api cancelled")
                apiError.message = ""
            }
            printLog("error -> \(apiError.message)", "url -> \(String(describing: response.url))", "statusCode -> \(response.statusCode)")
            completionHandler(.failure(apiError))
        } else if response.data == nil {
            printLog("error -> noData", "url -> \(String(describing: response.url))", "statusCode -> \(response.statusCode)")
            completionHandler(.failure(APIError(type: .noData)))
        } else if let data = response.data, let stringData = String(data: data, encoding: .utf8), stringData.count > 0 {
            printLog("response -> \(stringData)", "url -> \(String(describing: response.url))", "statusCode -> \(response.statusCode)")
            let apiError = APIError(message: stringData, type: APIErrorType.customAPIError, statusCode: response.statusCode)
            completionHandler(.failure(apiError))
        } else {
            printLog("error -> invalidResponse", "url -> \(String(describing: response.url))", "statusCode -> \(response.statusCode)")
            completionHandler(.failure(APIError(type: .invalidResponse)))
        }
    }
    
    // MARK: - Loading-
    
    func displayLoader(_ shouldDisplay: Bool, show: Bool) {
        if shouldDisplay {
            if show {
                // display loader
                presentIndicator()
            } else {
                // hide loader
                dismissIndicator()
            }
        }
    }
    
    // MARK: - Logs-
    
    func printLog(_ values: Any...) {
        if Constant.isDebugingEnabled {
            _ = values.map({ print($0) })
        }
    }
    
    
    //MARK:-Loader Function
    
     //MARK:-Loader Function
       func dismissIndicator() {
           DispatchQueue.main.async {
               AppDelegate.appDelegate().window?.isUserInteractionEnabled = true
              KRProgressHUD.dismiss()
           }
       }
       
       //Present Loader
       func presentIndicator() {
           DispatchQueue.main.async {
               AppDelegate.appDelegate().window?.isUserInteractionEnabled = false
               KRProgressHUD.show()
           }
       }
   
}
