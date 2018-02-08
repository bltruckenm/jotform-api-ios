//
//  GetAllSubmissionsViewController.swift
//  JotFormTest
//
//  Created by Curtis Stilwell on 2/1/18.
//  Copyright © 2018 wang. All rights reserved.
//

import Foundation

class GetAllSubmissionsViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource  {
    @IBOutlet weak var offsetTextField: UITextField!
    @IBOutlet weak var limitTextField: UITextField!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var filterTextField: UITextField!
    @IBOutlet weak var getBarButtonItem: UIBarButtonItem!

    var orderbyList = [Any]()
    
    override func viewDidLoad() {
        initData()
        initUI()
    }
    
    func initUI() {
        title = "Get all submissions"
        navigationItem.rightBarButtonItem = getBarButtonItem
    }
    
    func initData() {
        orderbyList = SharedData().getFormOrderbyList()
    }
    
    func loadSubmissions() {
        SVProgressHUD.show(withStatus: "Loading submissions...")
        
        var offset: Int = 0
        var limit: Int = 0
        var order = ""
      
        if let offSetTextString = offsetTextField.text, let count = Int(offSetTextString) {
            offset = count
        }
        
        if let limitTextString =  limitTextField.text, let count = Int(limitTextString) {
            limit = count
        }
        
        if let orderString = orderbyList[pickerView.selectedRow(inComponent: 0)] as? String {
            order = orderString
        }
        
        SharedData.sharedData.apiClient?.getSubmissions(offset, limit: limit, orderBy: order, filter:nil, onSuccess: {(_ result: AnyObject) -> Void in
            
            SVProgressHUD.dismiss()
            let responseCode = result["responseCode"] as? Int
            
            if responseCode == 200 || responseCode == 206 {
                 let submissionArray = result["content"] as? [AnyObject]
                 self.startDataListViewController(submissionArray!)
            }
        }, onFailure: {(_ error: Any) -> Void in
            SVProgressHUD.dismiss()
        })
    }

    func startDataListViewController(_ datalist: [Any]) {
        let dataListVc = DataListViewController(nibName: "DataListViewController", bundle: nil)
        navigationController?.pushViewController(dataListVc, animated: true)
        dataListVc.setList(datalist as [AnyObject], type:DataListType.submissionList)
    }
    
    @IBAction func getSubmissionsButtonClicked(_ sender: Any) {
        loadSubmissions()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return orderbyList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let rowStr: String = orderbyList[row] as! String
        return rowStr
    }
}