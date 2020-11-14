//
//  LoginModel.swift
//  NetworkManagerDemo
//
//  Created by Moreyeahs on 02/06/20.
//  Copyright © 2020 Honey Maheshwari. All rights reserved.
//

import Foundation


struct GetAllDataModel {
    
    var arrOfData:[GetDataModel]
    init(_ json:[String:Any]) {

        if let arr = json as? [[String: Any]] {
            arrOfData = arr.map({ GetDataModel($0) })
        } else {
            arrOfData = [GetDataModel]()
        }
    }
}



struct GetDataModel {
    
    var userId: Int
    var id: Int
    var title:String
    var body:String
    
    init(_ json: [String: Any]) {
        userId = json.getInt(forKey: "userId")
        id = json.getInt(forKey: "id")
        title = json.getString(forKey: "title")
        body = json.getString(forKey: "body")
    }
    
}
