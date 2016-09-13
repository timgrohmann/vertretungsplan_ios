//
//  ViewController.swift
//  Vertretungsplan
//
//  Created by Tim Grohmann on 11.06.16.
//  Copyright © 2016 Tim Grohmann. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var lastChangedLabel: UILabel!
    @IBOutlet weak var lastChangedWrapperView: UIView!
    
    var imageView: UIImageView?
    
    var days: [Day] = []
    var timetable = Timetable()
    var changedTimetable = ChangedTimetable()
    var c = "CCCCCC"
    var user: User?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //let nib = UINib(nibName: "header", bundle: nil)
        //collectionView.registerNib(nib, forSupplementaryViewOfKind: "header", withReuseIdentifier: "header")
        self.automaticallyAdjustsScrollViewInsets = false
        
        collectionView.reloadData()
        
        scrollToCurrentDay()
        
        print("viewDidLoad:")
        
        let userFetch = NSFetchRequest(entityName: "User")
        

        
        do {
            let users = try managedObjectContext.executeFetchRequest(userFetch) as! [User]
            if users.count != 1 {
                let fetchRequest = NSFetchRequest(entityName: "User")
                let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                try! managedObjectContext.executeRequest(deleteRequest)
                
                user = User(entity: NSEntityDescription.entityForName("User", inManagedObjectContext: managedObjectContext)! , insertIntoManagedObjectContext: managedObjectContext)
                self.performSegueWithIdentifier("settingsSegue", sender: nil)
            }else{
                user = users[0]
                if user?.schoolid == nil{
                    self.performSegueWithIdentifier("settingsSegue", sender: nil)
                }else{
                    self.reloadAll()
                }
            }
        } catch {
            fatalError("User could not be fetched/created: \(error)")
        }
        
        reloadAll()

        
        
        let color = UIColor.colorFromHex(c)
        print(color)
        self.navigationController?.navigationBar.barTintColor = color
        
        loadImage()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        reloadAll()
    }
    
    func loadImage(){
        let url = "https://fahrradcenter-bernburg.de/wp-content/themes/design/img/schloss_saale.jpg"
        
        let task = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration()).dataTaskWithRequest(NSURLRequest(URL: NSURL(string: url)!)){
            data,error,_ in
            
            if let imageData = data{
                let image = UIImage(data: imageData)
                self.imageView = UIImageView(frame: self.view.frame)
                
                let effect = UIBlurEffect(style: .Light)
                let effectView = UIVisualEffectView(effect: effect)
                effectView.frame = self.view.frame
                
                self.imageView?.image = image
                
                self.imageView?.contentMode = .ScaleAspectFill
                
                dispatch_async(dispatch_get_main_queue()){
                    self.view.addSubview(effectView)
                    self.view.sendSubviewToBack(effectView)
                    self.view.insertSubview(self.imageView!, belowSubview: effectView)
                    self.scrollViewDidScroll(self.collectionView)
                }
            }
        }
        
        task.resume()
        
    }
    
    func reloadAll(){
        
        
        user?.loadSchoolProperties({
            notification in
            dispatch_async(dispatch_get_main_queue()){
                
                self.loadAllColors()

                if let n = notification{
                    self.lastChangedLabel.text = n
                    return
                }
                
                print("loaded school properties")
            
                self.changedTimetable.load(){
                    print("loaded")
                    dispatch_async(dispatch_get_main_queue()){
                        self.collectionView.reloadData()
                        self.lastChangedLabel.text = self.changedTimetable.data?.lastRefreshed
                    }
                }
            }
        })
    }
    
    func loadAllColors(){
        UIView.animateWithDuration(0.5){
            self.navigationController?.navigationBar.barTintColor = self.user?.colorPrimary
            self.navigationController?.navigationBar.tintColor = self.user?.colorText
            self.navigationController?.navigationBar.titleTextAttributes?[NSForegroundColorAttributeName] = self.user?.colorText
            self.view.backgroundColor = self.user?.colorSecondary
            self.lastChangedLabel.textColor = self.user?.colorTextSecondary
            self.lastChangedWrapperView.backgroundColor = self.user?.colorSecondary
        }
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return timetable.numberOfDays
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (timetable.dayForNumber(section)?.lessons.count ?? 0)
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("lesson", forIndexPath: indexPath)
        
        let lesson = timetable.getLessonForIndexPath(NSIndexPath(forRow: indexPath.row+1, inSection: indexPath.section))!
        
        let change = changedTimetable.getChange(lesson)
        
        
        (cell.viewWithTag(1) as! UILabel).text = String(indexPath.row+1)
        (cell.viewWithTag(2) as! UILabel).text = lesson.subject
        (cell.viewWithTag(3) as! UILabel).text = lesson.teacher
        (cell.viewWithTag(4) as! UILabel).text = lesson.room
        (cell.viewWithTag(5) as! UILabel).text = lesson.info
        
        for i in 1...5{
            (cell.viewWithTag(i) as! UILabel).textColor = UIColor.blackColor()
        }
        
        cell.viewWithTag(111)?.removeFromSuperview()

        
        if let c = change{
            if (c.subject != lesson.subject){
                (cell.viewWithTag(2) as! UILabel).text = c.subject
                (cell.viewWithTag(2) as! UILabel).textColor = UIColor.redColor()
            }
            if (c.teacher != lesson.teacher){
                (cell.viewWithTag(3) as! UILabel).text = c.teacher
                (cell.viewWithTag(3) as! UILabel).textColor = UIColor.redColor()
            }
            if (c.room != lesson.room){
                (cell.viewWithTag(4) as! UILabel).text = c.room
                (cell.viewWithTag(4) as! UILabel).textColor = UIColor.redColor()
            }
            if (c.info != lesson.info){
                (cell.viewWithTag(5) as! UILabel).text = c.info
                (cell.viewWithTag(5) as! UILabel).textColor = UIColor.redColor()
            }
            
            let no = ChangedView(frame: CGRectMake(0, 0, cell.viewWithTag(1)!.frame.origin.x*0.6, cell.frame.height))
            no.tag = 111
            no.backgroundColor = UIColor.clearColor()
            cell.addSubview(no)
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        showEditView(indexPath)
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let offset = Float(scrollView.contentOffset.x)
        let width = Float(((scrollView as! UICollectionView).collectionViewLayout as! TimeTableLayout).cellWidth)
        let index = Int(round(offset/width))
        let names = ["Montag","Dienstag","Mittwoch","Donnerstag","Freitag","Samstag"]
        self.navigationItem.title = names[index]
        
        let offsetUnit = CGFloat(offset)/scrollView.contentSize.width*5/4
        let parallaxSpeed: CGFloat = 0.5
        
        imageView?.layer.contentsRect = CGRectMake(offsetUnit*parallaxSpeed, 0, 1-parallaxSpeed, 1)
    }
    
    func showEditView(indexPath: NSIndexPath) {
        
        let view = UINib(nibName: "editView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! EditView
        
        guard let startView = collectionView.cellForItemAtIndexPath(indexPath) else {return}
        
        view.fadeIn(startView,size: self.view.frame.size)
        let dbIndexPath = NSIndexPath(forRow: indexPath.row+1, inSection: indexPath.section)
        view.sLesson(timetable.getLessonForIndexPath(dbIndexPath)!)
        
        view.descriptionLabel.textColor = user?.colorSecondary
        view.backgroundColor = user?.colorPrimary
        view.finishButton.setTitleColor(user?.colorSecondary, forState: .Normal)
        view.editButton.setTitleColor(user?.colorSecondary, forState: .Normal)
        
        view.actualRoom.textColor = user?.colorText
        view.actualSubject.textColor = user?.colorText
        view.actualTeacher.textColor = user?.colorText
        view.infoTextLabel.textColor = user?.colorText
        
        self.view.addSubview(view)
        self.collectionView.userInteractionEnabled = false
    }
    
    func dismissEditor(){
        
        self.collectionView.reloadData()
        self.collectionView.userInteractionEnabled = true
        self.changedTimetable.refreshChanged()
    }
    
    func scrollToCurrentDay(){
        self.collectionView.layoutIfNeeded()

        let cal = NSCalendar.init(calendarIdentifier: NSCalendarIdentifierGregorian)
        let components = cal!.components([.Weekday,.Hour], fromDate: NSDate())
        var w = components.weekday
        let hour = components.hour
        print("Weekday:")
        
        if (2 <= w && w <= 5){
            w -= 2
            if (hour > 14 && w != 5){
                w += 1
            }
            if (hour > 14 && w == 5) {
                w = 0
            }
        }else{
            w = 0
        }
        print(w)
        
        
        self.collectionView.scrollToItemAtIndexPath(NSIndexPath(forRow: 1, inSection: w), atScrollPosition: .CenteredHorizontally, animated: true)
    }
    
    @IBAction func refreshButtonClicked(sender: AnyObject) {
        reloadAll()
    }
}

