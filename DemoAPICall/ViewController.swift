//
//  ViewController.swift
//  DemoAPICall
//
//  Created by Sunil Kumar on 13/11/20.
//  Copyright © 2020 Wiantech. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
   //MARK:- IBOutlet's of the Controller-
    @IBOutlet weak var tblView: UITableView!
    
    
    //MARK:- Class variable's of the Controller-
    var arrData = [GetDataModel]()
    
    //MARK:- Views Life cycle of the Controller-
    override func viewDidLoad() {
        super.viewDidLoad()
        self.GetAllData()
    }
    
    //MARK:-Custom function of the Controller-
    private func GetAllData() {
        AuthenticationInterface.shared.GetApiCall() { (response, success, message) in
            if let list = response as? GetAllDataModel, success {
                self.arrData = list.arrOfData
                DispatchQueue.main.async {
                   self.tblView.reloadData()
                }
            } else if let message = message {
                self.ShowAlert(title: "Alert!", message: message)
            }
        }
    }
}

//MARK:- UITableViewDelegate,UITableViewDataSource

extension ViewController : UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DataTableViewCell", for: indexPath) as! DataTableViewCell
        
        cell.lblUserID.text = "\(arrData[indexPath.row].userId)"
        cell.lblID.text = "\(arrData[indexPath.row].id)"
        cell.lblTitle.text = arrData[indexPath.row].title
        cell.lblBody.text = arrData[indexPath.row].body
        return cell
    }
    
    
}
