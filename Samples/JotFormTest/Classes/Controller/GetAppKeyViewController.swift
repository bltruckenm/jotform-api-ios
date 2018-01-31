//
//  GetAppKeyViewController.swift
//  JotFormTest
//
//  Created by Curtis Stilwell on 1/31/18.
//  Copyright © 2018 wang. All rights reserved.
//

import UIKit
import Foundation
import JotForm_iOS


class GetAppKeyViewController: UIViewController {
    var apiClient: JotForm?
    
    @IBOutlet weak var usernameTextField: UITextField?
    @IBOutlet weak var passwordTextField: UITextField?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
        apiClient = JotForm(apiKey: "", debugMode: false, euApi: false)
      
        title = "Get App Key"
        showAlertView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        usernameTextField?.text = ""
        passwordTextField?.text = ""
    }
    
    func showSampleListViewController() {
       /* let sampleListVc = SampleListViewController(nibName: "SampleListViewController", bundle: nil)
        navigationController?.pushViewController(sampleListVc as? UIViewController ?? UIViewController(), animated: true) */
    }
    
    func showAlertView() {
        let alertView = UIAlertController(title: "JotFormAPISample", message: "Do you have an API key?", preferredStyle: .alert)
        
        let yesButton = UIAlertAction(title: "Yes", style: .default, handler: {(_ action: UIAlertAction) -> Void in
            if (API_KEY == "") {
                let alertViewCancel = UIAlertController(title: "JotFormAPISample", message: "Please put your API key in Common.h.", preferredStyle: .alert)
                
                let cancelButton = UIAlertAction(title: "Ok", style: .default, handler: {(_ action: UIAlertAction) -> Void in
                })
                
                alertViewCancel.addAction(cancelButton)
                self.present(alertViewCancel, animated: true, completion: nil)
            } else {
                SharedData().initAPIClient(API_KEY, euApi: EU_API)
                self.showSampleListViewController()
            }
        })
        
        let noButton = UIAlertAction(title: "No", style: .default, handler: {(_ action: UIAlertAction) -> Void in
        })
        
        alertView.addAction(yesButton)
        alertView.addAction(noButton)
        self.present(alertView, animated: true, completion: nil)
    }
    
    @IBAction func getAppKeyButtonClicked(_ sender: Any) {
        let storage = HTTPCookieStorage.shared
        for cookie: HTTPCookie in (storage.cookies)! {
            storage.deleteCookie(cookie)
        }
        
        usernameTextField?.resignFirstResponder()
        passwordTextField?.resignFirstResponder()
        
      //  SVProgressHUD.show(withStatus: "Getting app key...")
        var userInfo = [String: Any]()
        userInfo["username"] = usernameTextField?.text
        userInfo["password"] = passwordTextField?.text
        userInfo["appName"] = "JotFormAPISample"
        userInfo["access"] = "full"

        apiClient?.login(userInfo, onSuccess: {(_ result: AnyObject) -> Void in
            let responseCode: Int = result["responseCode"]  as! Int
            if responseCode == 200 || responseCode == 206 {
                let content = result["content"] as AnyObject
                let appKey = content["appKey"] as! String
                self.checkEuServer(appKey)
            }
        }, onFailure: {(_ error: Any) -> Void in
            // SVProgressHUD.dismiss()
        })
    }
    
    func checkEuServer(_ appKey: String) {
        apiClient?.checkEUserver(appKey, onSuccess: {(_ result: AnyObject) -> Void in
           // var isEuServer: Bool = result["content"]["euOnly"] != 0
            //  [[SharedData sharedData] initAPIClient:appKey euApi:isEuServer];
           // self.showSampleListViewController()
           // SVProgressHUD.dismiss()
        }, onFailure: {(_ error: Error?) -> Void in
           // SVProgressHUD.dismiss()
        })
    }
}
