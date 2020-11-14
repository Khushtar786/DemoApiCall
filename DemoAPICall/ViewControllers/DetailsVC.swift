//
//  DetailsVC.swift
//  DemoAPICall
//
//  Created by Sunil Kumar on 15/11/20.
//  Copyright © 2020 Wiantech. All rights reserved.
//

import UIKit

class DetailsVC: UIViewController {

    //MARK:- IBOutlet's of the Controler-
    
    @IBOutlet weak var btnb1: UIButton!
    @IBOutlet weak var btnb2: UIButton!
    @IBOutlet weak var btnb3: UIButton!
    @IBOutlet weak var btnb4: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func btnActionB1(_ sender: UIButton) {
      print("btnActionB1")
    }
    
    @IBAction func btnActionB2(_ sender: UIButton) {
        print("btnActionB2")
    }
    
    @IBAction func btnActionB3(_ sender: UIButton) {
        print("btnActionB3")
    }
    
    @IBAction func btnActionB4(_ sender: UIButton) {
        print("btnActionB4")
    }

}
