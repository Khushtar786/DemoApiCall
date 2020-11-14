//
//  AuthenticationInterface.swift
//  NetworkManagerDemo
//
//  Created by Honey Maheshwari on 02/06/20.
//  Copyright © 2020 Honey Maheshwari. All rights reserved.
//

import UIKit

class AuthenticationInterface: BaseInterface {

    static let shared = AuthenticationInterface()
    
    //API:- https://jsonplaceholder.typicode.com/posts
    
    func GetApiCall(completion: @escaping APIResponseBlock)  {
        performGetOperation(endPoint: APIEndPoints.GetDataAPI) { (response) in
            switch response {
            case .success(let apiSuccess):
                let success = apiSuccess.json.getBool(forKey: APIConstants.success)
                let message = apiSuccess.json.getString(forKey: APIConstants.message)
                if success {
                    let list = GetAllDataModel(apiSuccess.json)
                    completion(list, success, message)
                } else {
                    completion(apiSuccess.json, success, message)
                }
            case .failure(let apiError):
                self.parseErrorResponse(apiError, completion: completion)
            }
        }
    }
}
