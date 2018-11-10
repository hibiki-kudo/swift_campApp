//
//  ViewController.swift
//  SwiftCampApp
//
//  Created by 工藤 響 on 2018/11/09.
//  Copyright © 2018 工藤 響. All rights reserved.
//

import UIKit

class memberViewController1: UIViewController,UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var picker: UIPickerView!
    let dataList = ["1","2","3","4"]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        picker.delegate = self
        picker.dataSource = self
        
        let userDefaults = UserDefaults.standard
        userDefaults.set(Int(dataList[0]),forKey:"players1")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadView()
        viewDidLoad()
    }
    
    // UIPickerViewの列の数
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // UIPickerViewの行数、要素の全数
    func pickerView(_ pickerView: UIPickerView,
                    numberOfRowsInComponent component: Int) -> Int {
        return dataList.count
    }
    
    // UIPickerViewに表示する配列
    func pickerView(_ pickerView: UIPickerView,
                    titleForRow row: Int,
                    forComponent component: Int) -> String? {
        
        return dataList[row]
    }
    
    // UIPickerViewのRowが選択された時の挙動
    func pickerView(_ pickerView: UIPickerView,
                    didSelectRow row: Int,
                    inComponent component: Int) {
        
        let userDefault = UserDefaults.standard
        userDefault.set(Int(dataList[row]),forKey:"players1")
        print(userDefault.object(forKey: "players1"))
    }

    
    @IBAction func Back(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}

