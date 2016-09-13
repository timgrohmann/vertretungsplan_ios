//
//  SettingsViweController.swift
//  Vertretungsplan
//
//  Created by Tim Grohmann on 04.09.16.
//  Copyright © 2016 Tim Grohmann. All rights reserved.
//

import UIKit
import Foundation
import CoreData


class SettingsViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate{
    
    @IBOutlet weak var schoolNameLabel: UILabel!
    
    @IBOutlet weak var pickerView: UIPickerView!
    
    @IBOutlet weak var klassenStufe: UITextField!
    
    @IBOutlet weak var klasse: UITextField!
    
    var schools: [School] = []
    var user: User?
    let fetcher = SchoolFetcher()
    
    override func viewDidLoad() {
        do{
            let users = try managedObjectContext.executeFetchRequest(NSFetchRequest(entityName: "User")) as! [User]
            user = users[0]
        }catch{
            print(error)
        }
        
        klasse.text = user?.klasse
        klassenStufe.text = user?.klassenstufe
        
        fetcher.fetch(){
            ret, notification in
            
            if let n = notification{
                self.navigationController?.popViewControllerAnimated(true)
                
                let alert = UIAlertController(title: "Verbindungsfehler", message: n, preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "Okay", style: .Default, handler: nil))
                self.navigationController?.presentViewController(alert, animated: true, completion: nil)
                
                return
            }
            
            
            
            self.schools = ret
            self.pickerView.reloadAllComponents()
            let usersSchoolId = self.user?.schoolid
            
            for (i,s) in self.schools.enumerate() {
                if (s.id == usersSchoolId){
                    self.pickerView.selectRow(i, inComponent: 0, animated: true)
                    self.schoolNameLabel.text = "Schule:  \n"+s.name
                }
            }
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        if (schools.count == 0){
            return
        }
        let selected = schools[pickerView.selectedRowInComponent(0)]
        user?.schoolid = selected.id
        user?.schoollink = selected.link
        user?.schoolname = selected.name
        user?.klasse = klasse.text!
        user?.klassenstufe = klassenStufe.text!
        delegate.saveContext()
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return schools.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return schools[row].name
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print(row)
        
        schoolNameLabel.text = "Schule:  \n"+schools[row].name
        
        delegate.saveContext()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.navigationItem.hidesBackButton = !textFieldsOkay()

        
        if (Int(textField.text!) != nil && Int(textField.text!) != 0){
            textField.resignFirstResponder()
            return true
        }else{
            textField.text = ""
            
            //Fade color in and out
            UIView.animateWithDuration(0.1, animations: {
                textField.backgroundColor = UIColor.colorFromHex("D05000", alpha: 0.1)
                }, completion: {
                    bool in
                    UIView.animateWithDuration(0.1){
                        textField.backgroundColor = UIColor.clearColor()
                    }
                })
            return false
        }
    }
    
    func textFieldsOkay() -> Bool{
        return (Int(klassenStufe.text!) != nil && Int(klassenStufe.text!) != 0) && (Int(klasse.text!) != nil && Int(klasse.text!) != 0)
    }
}