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
    
    var sentInitialData = false
    
    var wde: WatchDataExtension {
        return delegate.watchDataExtension
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //let nib = UINib(nibName: "header", bundle: nil)
        //collectionView.registerNib(nib, forSupplementaryViewOfKind: "header", withReuseIdentifier: "header")
        self.automaticallyAdjustsScrollViewInsets = false
        
        collectionView.reloadData()
        
        scrollToCurrentDay()
        
        let userFetch: NSFetchRequest<User> = NSFetchRequest(entityName: "User")
        
        
        do {
            let users = try managedObjectContext.fetch(userFetch)
            if users.count != 1 {
                let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "User")
                let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                try! managedObjectContext.execute(deleteRequest)
                
                user = User(entity: NSEntityDescription.entity(forEntityName: "User", in: managedObjectContext)! , insertInto: managedObjectContext)
                self.performSegue(withIdentifier: "settingsSegue", sender: nil)
                return
            }else{
                user = users[0]
                if user?.school!.id == nil{
                    self.performSegue(withIdentifier: "settingsSegue", sender: nil)
                }else{
                    self.reloadAll()
                }
            }
        } catch {
            fatalError("User could not be fetched/created: \(error)")
        }
        

        let color = UIColor.colorFromHex(c)
        self.navigationController?.navigationBar.barTintColor = color
        
        //reloadAll()
        loadImage()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        reloadAll()
    }
    
    func loadImage(){
        let url = "https://fahrradcenter-bernburg.de/wp-content/themes/design/img/schloss_saale.jpg"
        
        let task = URLSession(configuration: .default).dataTask(with: URLRequest(url: URL(string: url)!), completionHandler: {
            data,error,_ in
            
            DispatchQueue.main.async {
                if let imageData = data{
                    let image = UIImage(data: imageData)
                    self.imageView = UIImageView(frame: self.view.frame)
                    
                    let effect = UIBlurEffect(style: .light)
                    let effectView = UIVisualEffectView(effect: effect)
                    effectView.frame = self.view.frame
                    
                    self.imageView?.image = image
                    
                    self.imageView?.contentMode = .scaleAspectFill
                    
                    DispatchQueue.main.async{
                        self.view.addSubview(effectView)
                        self.view.sendSubview(toBack: effectView)
                        self.view.insertSubview(self.imageView!, belowSubview: effectView)
                        self.scrollViewDidScroll(self.collectionView)
                    }
                }
            }

        })
        task.resume()
    }
    
    func reloadAll(){
        
        
        user?.school!.loadProperties({
            notification in
            DispatchQueue.main.async{
                
                self.loadAllColors()

                if let n = notification{
                    self.lastChangedLabel.text = n
                    return
                }
                            
                self.changedTimetable.load(){
                    DispatchQueue.main.async{
                        self.collectionView.reloadData()
                        self.lastChangedLabel.text = self.changedTimetable.data?.lastRefreshed
                        if (!self.sentInitialData){
                            self.wde.sendWatchData()
                            self.sentInitialData = true
                        }
                    }
                }
            }
        })
    }
    
    func loadAllColors(){
        UIView.animate(withDuration: 0.5, animations: {
            self.navigationController?.navigationBar.barTintColor = self.user?.school!.colorPrimary
            self.navigationController?.navigationBar.tintColor = self.user?.school!.colorText
            self.navigationController?.navigationBar.titleTextAttributes?[NSAttributedStringKey.foregroundColor] = self.user?.school!.colorText
            self.view.backgroundColor = self.user?.school!.colorSecondary
            self.lastChangedLabel.textColor = self.user?.school!.colorTextSecondary
            self.lastChangedWrapperView.backgroundColor = self.user?.school!.colorSecondary
        })
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return timetable.numberOfDays
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (timetable.dayForNumber(section)?.lessons.count ?? 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "lesson", for: indexPath)
        
        let lesson = timetable.getLessonForIndexPath(IndexPath(row: indexPath.row+1, section: indexPath.section))!
        
        let change = changedTimetable.getChange(lesson)
        
        
        (cell.viewWithTag(1) as! UILabel).text = String((indexPath as NSIndexPath).row+1)
        (cell.viewWithTag(2) as! UILabel).text = lesson.subject
        (cell.viewWithTag(3) as! UILabel).text = lesson.teacher
        (cell.viewWithTag(4) as! UILabel).text = lesson.room
        (cell.viewWithTag(5) as! UILabel).text = ""
        
        for i in 1...5{
            (cell.viewWithTag(i) as! UILabel).textColor = UIColor.black
        }
        
        cell.viewWithTag(111)?.removeFromSuperview()

        
        if let c = change{
            if (c.subject != lesson.subject){
                (cell.viewWithTag(2) as! UILabel).text = c.subject
                (cell.viewWithTag(2) as! UILabel).textColor = UIColor.red
            }
            if (c.teacher != lesson.teacher){
                (cell.viewWithTag(3) as! UILabel).text = c.teacher
                (cell.viewWithTag(3) as! UILabel).textColor = UIColor.red
            }
            if (c.room != lesson.room){
                (cell.viewWithTag(4) as! UILabel).text = c.room
                (cell.viewWithTag(4) as! UILabel).textColor = UIColor.red
            }
            
            (cell.viewWithTag(5) as! UILabel).text = c.info
            (cell.viewWithTag(5) as! UILabel).textColor = UIColor.red
            
            let scheme = user?.school!.getTimeScheme(for: (indexPath as NSIndexPath).row)
            
            let no = ChangedView(frame: CGRect(x: 0, y: 0, width: cell.viewWithTag(1)!.frame.origin.x*0.6, height: cell.frame.height), top: scheme?.connectedToPrevious ?? false, bottom: scheme?.connectedToNext ?? false)
            no.tag = 111
            no.backgroundColor = UIColor.clear
            cell.addSubview(no)
        }
        /*cell.layoutIfNeeded()
        if let constVis = (cell.viewWithTag(5) as! UILabel).superview!.constraints.first(where: { $0.identifier == "ewInfoVis" }) {
            constVis.isActive = (change?.info) != nil
        }
        
        for con in (cell.viewWithTag(5) as! UILabel).superview!.constraints {
            print(con.identifier)
        }*/
        
        //let constInVis = (cell.viewWithTag(5) as! UILabel).superview!.constraints.first(where: { $0.identifier == "ewInfoInVis" })!
        
        
        
        //constInVis.isActive = (change?.info) == nil
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        showEditView(indexPath)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = Float(scrollView.contentOffset.x)
        let width = Float(((scrollView as! UICollectionView).collectionViewLayout as! TimeTableLayout).cellWidth)
        let index = Int(round(offset/width))
        let names = ["Montag","Dienstag","Mittwoch","Donnerstag","Freitag","Samstag"]
        self.navigationItem.title = names[index]
        
        let offsetUnit = CGFloat(offset)/scrollView.contentSize.width*5/4
        let parallaxSpeed: CGFloat = 0.5
        
        imageView?.layer.contentsRect = CGRect(x: offsetUnit*parallaxSpeed, y: 0, width: 1-parallaxSpeed, height: 1)
    }
    
    func showEditView(_ indexPath: IndexPath) {
        
        let view = UINib(nibName: "editView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! EditView
        
        guard let startView = collectionView.cellForItem(at: indexPath) else {return}
        
        view.fadeIn(from: startView,size: self.view.frame.size)
        let dbIndexPath = IndexPath(row: (indexPath as NSIndexPath).row+1, section: (indexPath as NSIndexPath).section)
        view.sLesson(timetable.getLessonForIndexPath(dbIndexPath)!)
        
        view.descriptionLabel.textColor = user?.school!.colorSecondary
        view.backgroundColor = user?.school!.colorPrimary
        view.finishButton.setTitleColor(user?.school!.colorSecondary, for: UIControlState())
        view.editButton.setTitleColor(user?.school!.colorSecondary, for: UIControlState())
        
        view.actualRoom.textColor = user?.school!.colorText
        view.actualSubject.textColor = user?.school!.colorText
        view.actualTeacher.textColor = user?.school!.colorText
        view.infoTextLabel.textColor = user?.school!.colorText
        
        self.view.addSubview(view)
        self.collectionView.isUserInteractionEnabled = false
    }
    
    func dismissEditor(){
        
        self.collectionView.isUserInteractionEnabled = true
        self.changedTimetable.refreshChanged()
        self.collectionView.reloadData()
        
    }
    
    func scrollToCurrentDay(){
        self.collectionView.layoutIfNeeded()

        let cal = Calendar.init(identifier: Calendar.Identifier.gregorian)
        let components = (cal as NSCalendar).components([.weekday,.hour], from: Date())
        var w = components.weekday!
        let hour = components.hour!
        
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
        
        self.collectionView.scrollToItem(at: IndexPath(row: 1, section: w), at: .centeredHorizontally, animated: true)
    }
    
    @IBAction func refreshButtonClicked(_ sender: AnyObject) {
        reloadAll()
    }
}

