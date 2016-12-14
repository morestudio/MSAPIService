//
//  ViewController.swift
//  MSAPIServiceExample
//
//  Created by Tum on 12/2/16.
//  Copyright © 2016 Morestudio. All rights reserved.
//

import UIKit
import MSAPIService
import PromiseKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let worker = MSAPIWorker(endpoint: "/products.json", params: nil, method: .get)
        worker.responseArray(keypath: "data").then { (products: [Product]) -> Void in
            print("products", products)
        }.catch { error in
            print("error", error)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

