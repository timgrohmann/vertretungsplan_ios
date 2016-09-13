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
    
    @IBAction func classTextFieldEditingDidEnd(sender: AnyObject) {
        
    }
    
    func pickerView(pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 100.0
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return schools.count
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 50.0
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return schools[row].name
    }
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView {
        if let v = view as? UILabel{
            v.text = schools[row].name
            return v
        } else {
            let view = UILabel()
            view.bounds = CGRectMake(0, 0, 200, 50)
            return view
        }
    }
}
