//
//  ViewController.swift
//  ChoreApp
//
//  Created by Mackenzie Hampel on 7/20/19.
//  Copyright © 2019 Mackenzie Hampel. All rights reserved.
//

import UIKit
import FSCalendar
import SQLite3


struct Chore {
    var choreTitle = String()
    var choreDescription = String()
    var assignedPerson = String()
    var selectedDate = String()
}

class ViewController: UIViewController, FSCalendarDelegate, FSCalendarDataSource,UpdateChoresListDelegate {
   

    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var gradientView: UIView!
    @IBOutlet weak var viewChoresBtn: UIButton!
    @IBOutlet weak var viewChoresLbl: UILabel!
    var selectedDate = Date()
    var db: OpaquePointer?
    let notificationCenter = NotificationCenter.default
  //  @IBOutlet weak var gradientViewBottom: UIView!
    var choreOrange = UIColor()
    var choresMasterList = [Chore]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        calendar.dataSource = self
        calendar.delegate = self
        
        let opaqueBlue = UIColor.init(red: (0/255.0), green: (122.0/255.0), blue: (255.0/255.0), alpha: 0.5)
        let choreBlue = UIColor.init(red: (0/255.0), green: (122.0/255.0), blue: (255.0/255.0), alpha: 1.0)
        choreOrange = viewChoresBtn.backgroundColor!
        
        let textAttributes = [NSAttributedString.Key.foregroundColor:choreBlue]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        
        gradientView.gradientBackground(from: .white, to: opaqueBlue, direction: .bottomToTop)
     //   gradientViewBottom.gradientBackground(from: opaqueBlue, to: .white, direction: .bottomToTop)
        self.viewChoresBtn.isEnabled = false
        self.viewChoresBtn.backgroundColor = .lightGray
        
       // NotificationCenter.default.addObserver(self, selector: #selector(insertIntoDatabase(_:)), name: .didReceiveData, object: nil)
        
        //SQLLITE
        let fileUrl =  try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("Chore.sqlite")
        
        if sqlite3_open(fileUrl.path, &db) != SQLITE_OK {
            print("ERROR OPENING DB")
            return
        }
        
        let createTableQuery = "CREATE TABLE IF NOT EXISTS Chores (id INTEGER PRIMARY KEY AUTOINCREMENT, choreTitle VARCHAR, choreDescription VARCHAR, assignedPerson VARCHAR, selectedDate VARCHAR)"
        if sqlite3_exec(db, createTableQuery, nil, nil, nil) != SQLITE_OK {
            print("Error creating table")
            return
        }
        
        print("EVERYTHING IS FINE")
        selectQuerry()
        self.saveToDatabase()
        //notificationCenter.addObserver(self, selector: #selector(saveToDatabase(_:)), name: UIApplication.willResignActiveNotification, object: nil)
     //   notificationCenter.removeObserver(self, name: UIApplication.willResignActiveNotification , object: nil)
    
    }
    override func viewDidAppear(_ animated: Bool) {
        print("made it")
    }
    
    @objc func insertIntoDatabase(_ notification: NSNotification){
        selectQuerry()
        self.saveToDatabase()
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
        self.viewChoresLbl.isHidden = true
        self.viewChoresBtn.isEnabled = true
        self.viewChoresBtn.backgroundColor = choreOrange
        selectedDate = date
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! ChoresListViewController
        //vc.dateLabel!.text = selectedDate.description
        vc.selectedDate = selectedDate
        vc.delegate = self
        vc.chores = filterChoresByDate()
    }
    
    func filterChoresByDate() -> [Chore]{
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let myString = formatter.string(from: self.selectedDate)
        let yourDate = formatter.date(from: myString)
        formatter.dateFormat = "dd-MMM-yyyy"
        let selectedDateFromCalendar = formatter.string(from: yourDate!)
        
        
        var tempArray = [Chore]()
        
        for chore in choresMasterList {
            if selectedDateFromCalendar == chore.selectedDate {
                tempArray.append(chore)
            }
        }
        return tempArray
    }
    
    func filterChoresListToDate(date: Date, choreList: [Chore]) -> [Chore] {
        var tempArray = [Chore]()
        
        for chore in choreList {
            let tempDate = chore.selectedDate.convertStringToDate()
            if Calendar.current.startOfDay(for: tempDate) == Calendar.current.startOfDay(for: date){
                tempArray.append(chore)
                
            }
        }
        
        return tempArray
    }
    
    @IBAction func didSelectViewChoresForDay(_ sender: Any) {
        
    }
    
    func updateChoresList(choresList: [Chore]) {
        for c in choresList {
            if !choresMasterList.contains(where: {$0.choreTitle == c.choreTitle}) {
                choresMasterList.append(c)
            }
        }
        
        self.saveToDatabase()
        
    }
    
    func removeChoreFromMasterList(chore: Chore) {
        var index = 0
        for c in choresMasterList {
            if c.choreTitle == chore.choreTitle{
                choresMasterList.remove(at: index)
            }
            index += 1
        }
        saveToDatabase()
    }
    
    func selectQuerry() -> Void{
        //inventoryInfo.removeAll()
        choresMasterList.removeAll()
        let queryString = "SELECT * FROM Chores;"
        var stmt:OpaquePointer?
        
        
        if sqlite3_prepare_v2(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return
        }
        
        //traversing through all the records
        while(sqlite3_step(stmt) == SQLITE_ROW){
            let id = sqlite3_column_int(stmt, 0)
            let choreTitle = String(cString: sqlite3_column_text(stmt, 1))
            let choreDescription = String(cString: sqlite3_column_text(stmt, 2))
            let assignedPerson = String(cString: sqlite3_column_text(stmt, 3))
            let selectedD = String(cString: sqlite3_column_text(stmt, 4))
            
            let serverItem = Chore(choreTitle: choreTitle, choreDescription: choreDescription, assignedPerson: assignedPerson, selectedDate: selectedD)
            
            choresMasterList.append(serverItem)

        }
    }
    
    //@objc func saveToDatabase(_ notification:Notification)  {
    func saveToDatabase() {
        let querryStmt = "DELETE FROM Chores;"
        var deletePtr: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, querryStmt, -1, &deletePtr, nil) == SQLITE_OK {
            if sqlite3_step(deletePtr) == SQLITE_DONE {
                print("was deleted")
            } else {
                print("deletion failed")
            }
        }
        
        sqlite3_close(deletePtr)
        
        if !choresMasterList.isEmpty {
            for l in choresMasterList{
                
                let insertQuery = "INSERT INTO Chores (choreTitle, choreDescription, assignedPerson, selectedDate) VALUES (?, ?, ?, ?);"
                var stmt: OpaquePointer?
                
                if sqlite3_prepare_v2(db, insertQuery, -1, &stmt, nil) != SQLITE_OK {
                    let errmsg = String(cString: sqlite3_errmsg(db)!)
                    print("error preparing insert: \(errmsg)")
                    return
                }
                let title = l.choreTitle as NSString
                if sqlite3_bind_text(stmt, 1, title.utf8String, -1, nil) != SQLITE_OK{
                    let errmsg = String(cString: sqlite3_errmsg(db)!)
                    print("failure binding subtitle: \(errmsg)")
                    return
                }
                let choreDesc = l.choreDescription as NSString
                if sqlite3_bind_text(stmt, 2, choreDesc.utf8String, -1, nil) != SQLITE_OK{
                    let errmsg = String(cString: sqlite3_errmsg(db)!)
                    print("failure binding title: \(errmsg)")
                    return
                }
                let assingedPerson = l.assignedPerson as NSString
                if sqlite3_bind_text(stmt, 3, assingedPerson.utf8String, -1, nil) != SQLITE_OK{
                    let errmsg = String(cString: sqlite3_errmsg(db)!)
                    print("failure binding title: \(errmsg)")
                    return
                }
               
               let selected = l.selectedDate as NSString
               if sqlite3_bind_text(stmt, 4, selected.utf8String, -1, nil) != SQLITE_OK{
                    let errmsg = String(cString: sqlite3_errmsg(db)!)
                    print("failure binding title: \(errmsg)")
                    return
                }
                
                if sqlite3_step(stmt) == SQLITE_DONE{
                    print("Item inserted successfully")
                }
                sqlite3_close(stmt)
            }
        }
    }
}




