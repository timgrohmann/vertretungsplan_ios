//
//  editView.swift
//  Vertretungsplan
//
//  Created by Tim Grohmann on 14.08.16.
//  Copyright © 2016 Tim Grohmann. All rights reserved.
//

import UIKit

class EditView: UIView {

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
    
    var fadingView: UICollectionViewCell?
    
    func sLesson(lesson: Lesson){
        self.lesson = lesson
        actualSubject.text = lesson.subject ?? ""
        actualTeacher.text = lesson.teacher ?? ""
        actualRoom.text = lesson.room ?? ""
        
        subjectTextField.text = lesson.subject ?? ""
        teacherTextField.text = lesson.teacher ?? ""
        roomTextField.text = lesson.room ?? ""
        
        descriptionLabel.text = String(lesson.hour) + ". Stunde " + lesson.day.names[lesson.day.number]
        
        
        if let change = changedTimetable.getChange(lesson){
            UIView.animateWithDuration(0.5){
                self.backgroundColor = self.attentionColor
            }
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
    
    func fadeIn(start: UICollectionViewCell, size: CGSize){
        
        self.fadingView = start
        
        self.center = start.center
        self.center.x -= ((start.superview as? UIScrollView)?.contentOffset.x ?? 0)
        
        self.bounds = start.bounds
        self.clipsToBounds = true
        self.layoutIfNeeded()
        self.alpha = 0
        self.layer.cornerRadius = 10
        
        UIView.animateWithDuration(0.2){
            self.alpha = 1
            self.center = CGPoint(x: size.width*0.5, y: size.height*0.5)
            self.bounds = CGRectMake(0,0, size.width - 40, size.height*0.4)
            self.layoutIfNeeded()
        }
    }
    
    func fadeOut(completion: ()->()){
        
        guard let end = fadingView else {return}
        
        UIView.animateWithDuration(0.2, animations: {
            self.center = end.center
            self.center.x -= ((end.superview as? UIScrollView)?.contentOffset.x ?? 0)
            self.bounds = end.bounds
            self.alpha = 0.0
            self.layoutIfNeeded()
        }){
            finished in
            completion()
        }
    }
    
    @IBAction func subjectEdited(sender: UITextField) {
        lesson?.subject = sender.text ?? ""
        save()
    }
    
    @IBAction func teacherEdited(sender: UITextField) {
        lesson?.teacher = sender.text ?? ""
        save()
    }
    
    @IBAction func roomEdited(sender: UITextField) {
        lesson?.room = sender.text ?? ""
        save()
    }
    
    func save(){
        delegate.saveContext()
    }
    
    @IBAction func dismissView(sender: UIButton) {
        ((delegate.window?.rootViewController as! UINavigationController).viewControllers.first as! ViewController).dismissEditor()
        
        self.fadeOut(){
            self.removeFromSuperview()
        }
    }

    @IBAction func editToggle(sender: UIButton) {
        
        subjectTextField.hidden = false
        teacherTextField.hidden = false
        roomTextField.hidden = false
        
        sender.removeFromSuperview()
    }
    
    @IBAction func focus(){
        UIView.animateWithDuration(0.2){
            self.center.y = UIScreen.mainScreen().bounds.size.height*0.3
        }
        
    }
    
}
