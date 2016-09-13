//
//  SettingsView.swift
//  Vertretungsplan
//
//  Created by Tim Grohmann on 16.08.16.
//  Copyright © 2016 Tim Grohmann. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class SettingsView: UIView, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var schools: [School] = []
    
    @IBOutlet weak var classTextField: UITextField!
    @IBOutlet weak var schoolPickerView: UIPickerView!
    
    func load(){
        /*let schoolsFetch = NSFetchRequest(entityName: "School")
        do {
            //schools = try moc.executeFetchRequest(schoolsFetch) as! [School]
        } catch {
            fatalError("Failed to fetch days: \(error)")
        }*/
    }
    
    @IBAction func classTextFieldEditingDidEnd(_ sender: AnyObject) {
        
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 100.0
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return schools.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 50.0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return schools[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        if let v = view as? UILabel{
            v.text = schools[row].name
            return v
        } else {
            let view = UILabel()
            view.bounds = CGRect(x: 0, y: 0, width: 200, height: 50)
            return view
        }
    }
}
