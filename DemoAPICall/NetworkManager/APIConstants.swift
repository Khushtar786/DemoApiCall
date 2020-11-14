//
//  APIConstants.swift
//  NetworkManagerDemo
//
//  Created by Honey Maheshwari on 02/06/20.
//  Copyright © 2020 Honey Maheshwari. All rights reserved.
//

import Foundation

typealias HttpClientResponseBlock = (HttpClientResponse) -> Void
typealias APIResponseBlock = (APIResponse) -> Void

enum HttpMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

enum APIResponse {
    case success(APISuccess)
    case failure(APIError)
}

struct HttpClientResponse {
    var data: Data?
    var headers: [String: Any]
    var error: Error?
    var statusCode: Int
    var url: URL?
}

struct APISuccess {
    var json: [String: Any]
    var headers: [String: Any]
    var url: URL?
}

struct APIError {
    var message: String
    var type: APIErrorType
    var statusCode: Int
    var info: [String: Any]?
}

extension APIError {
    init(type: APIErrorType) {
        self.message = type.getMessage()
        self.type = type
        self.statusCode = 0
    }
    
    init(with error: Error?, statusCode: Int, info: [String: Any]? = nil) {
        self.message = error?.localizedDescription ?? ""
        self.type = .customAPIError
        self.statusCode = statusCode
        self.info = info
        if let info = info {
            updateErrorMessage(from: info)
        }
        if self.message.count == 0 {
            self.message = error?.localizedDescription ?? ""
        }
    }
    
    mutating private func updateErrorMessage(from json: [String: Any]) {
        if let errors = json["errors"] as? [[String: Any]], let error = errors.first {
            self.message = (error["message"] as? String) ?? (error["reason"] as? String) ?? ""
        } else if let message = json["message"] as? String {
            self.message = message
        } else if let error = json["error"] as? [String: Any], let errors = error["errors"] as? [[String: Any]], let dictError = errors.first {
            self.message = (dictError["message"] as? String) ?? (dictError["reason"] as? String) ?? ""
        }
    }
}

enum APIErrorType {
    case invalidURL
    case invalidHeaderValue
    case noData
    case conversionFailed
    case invalidJSON
    case invalidResponse
    case noNetwork
    case customAPIError
    
    func getMessage() -> String {
        switch self {
        case .invalidURL: return "Invalid URL"
        case .invalidHeaderValue: return "Header value is not string"
        case .noData: return "No Data available"
        case .conversionFailed: return "Conversion Failed"
        case .invalidJSON: return "Invalid JSON"
        case .invalidResponse: return "Invalid Response"
        case .noNetwork: return "Please check your internet connection."
        case .customAPIError: return ""
        }
    }
}

struct APIConstants {
    static let deviceType: String = "ios"
    
    static let success: String = "success"
    static let apiKey: String = "apiKey"
    static let sessionId: String = "sessionId"
    static let message: String = "message"
    
    static let isValidSessionId: String = "isValidSessionId"
}

enum FirebaseAnalyticsEvent: String {
    case login = "log_in"
    case loginResponse = "log_in_response"
    case socialLoginResponse = "social_login_response"
    case signUp = "sign_up"
    case forgotPassword = "forgot_password"
}
