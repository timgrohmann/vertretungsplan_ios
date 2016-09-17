//
//  editView.swift
//  Vertretungsplan
//
//  Created by Tim Grohmann on 14.08.16.
//  Copyright © 2016 Tim Grohmann. All rights reserved.
//

import UIKit

class EditView: UIView, Fadable {

    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var subjectTextField: UITextField!
    
    @IBOutlet weak var teacherTextField: UITextField!
    
    @IBOutlet weak var roomTextField: UITextField!
    
    @IBOutlet weak var infoTextLabel: UILabel!
    @IBOutlet weak var actualSubject: UILabel!
    @IBOutlet weak var actualTeacher: UILabel!
    @IBOutlet weak var actualRoom: UILabel!
    @IBOutlet weak var finishButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    
    @IBInspectable var attentionColor: UIColor!
    
    var lesson: Lesson?
    
    var edit = false
    
    let changedTimetable = ((delegate.window?.rootViewController as! UINavigationController).viewControllers.first as! ViewController).changedTimetable
    
    var fadingView: UIView = UIView()
    
    func sLesson(_ lesson: Lesson){
        self.lesson = lesson
        actualSubject.text = lesson.subject
        actualTeacher.text = lesson.teacher
        actualRoom.text = lesson.room
        
        subjectTextField.text = lesson.subject
        teacherTextField.text = lesson.teacher
        roomTextField.text = lesson.room
        
        descriptionLabel.text = String(lesson.hour) + ". Stunde " + lesson.day.names[lesson.day.number]
        
        
        if let change = changedTimetable.getChange(lesson){
            UIView.animate(withDuration: 0.5, animations: {
                self.backgroundColor = self.attentionColor
            })
            infoTextLabel.text = change.info
            if(change.subject != lesson.subject){
                actualSubject.text = change.subject
            }
            if(change.teacher != lesson.teacher){
                actualTeacher.text = change.teacher
            }
            if(change.room != lesson.room){
                actualRoom.text = change.room
            }
        }
    }
    
    func save(){
        lesson?.subject = subjectTextField.text ?? ""
        lesson?.teacher = teacherTextField.text ?? ""
        lesson?.room = roomTextField.text ?? ""
        delegate.saveContext()
    }
    
    @IBAction func dismissView(_ sender: UIButton) {
        ((delegate.window?.rootViewController as! UINavigationController).viewControllers.first as! ViewController).dismissEditor()
        save()
        
        self.fadeOut(){
            self.removeFromSuperview()
        }
    }

    @IBAction func editToggle(_ sender: UIButton) {
        
        subjectTextField.isHidden = false
        teacherTextField.isHidden = false
        roomTextField.isHidden = false
        
        sender.removeFromSuperview()
    }
    
    @IBAction func focus(){
        UIView.animate(withDuration: 0.2, animations: {
            self.center.y = UIScreen.main.bounds.size.height*0.3
        })
        
    }
    
}
