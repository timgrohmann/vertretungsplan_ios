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
    
    @IBOutlet weak var klasse: UITextField!
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    var schools: [SchoolFetchResult] = []
    var user: User?
    let fetcher = SchoolFetcher()
    
    override func viewDidLoad() {
        do{
            let r: NSFetchRequest<User> = NSFetchRequest(entityName: "User")
            let users = try managedObjectContext.fetch(r)
            user = users[0]
        }catch{
            print(error)
        }
        
        klasse.text = user?.klasse
        usernameTextField.text = user?.username
        passwordTextField.text = user?.password
        
        fetcher.fetch(){
            ret, notification in
            
            if let n = notification{
                _ = self.navigationController?.popViewController(animated:true)
                
                let alert = UIAlertController(title: "Verbindungsfehler", message: n, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                self.navigationController?.present(alert, animated: true, completion: nil)
                
                return
            }
            
            
            
            self.schools = ret
            self.pickerView.reloadAllComponents()
            
            for (i,s) in self.schools.enumerated() {
                if (s.name == self.user?.school!.name){
                    self.pickerView.selectRow(i, inComponent: 0, animated: true)
                    self.schoolNameLabel.text = "Schule:  \n"+s.name
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if (schools.count == 0){
            return
        }
        let selected = schools[pickerView.selectedRow(inComponent: 0)]
        
        user?.klasse = klasse.text!
        user?.username = usernameTextField.text ?? ""
        user?.password = passwordTextField.text ?? ""
        
        user?.school?.use(fetchResult: selected)
        delegate.saveContext()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return schools.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return schools[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print(row)
        
        schoolNameLabel.text = "Schule:  \n"+schools[row].name
        
        delegate.saveContext()
    }
}
