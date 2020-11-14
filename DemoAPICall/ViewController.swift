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
    
    var arrData = [GetDataModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.GetAllData()
    }
    
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