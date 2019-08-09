//
//  ChoresListViewController.swift
//  ChoreApp
//
//  Created by Mackenzie Hampel on 7/27/19.
//  Copyright © 2019 Mackenzie Hampel. All rights reserved.
//

import Foundation
import SQLite3
import UIKit


protocol UpdateChoresListDelegate {
    func updateChoresList(choresList: [Chore])
    func removeChoreFromMasterList(chore: Chore)
}

class ChoresListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,ChoreListDelegate{
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var dateLabel: UILabel!
    var chores = [Chore]()
    var selectedDate = Date()
    var personsList = [Person]()
    var delegate : UpdateChoresListDelegate!
    var sortedFirstName = [String]()
    var uniqueFirstNames = [String]()
    var firstNames = [String]()
    var sections = [[Chore]]()
    
     var db: OpaquePointer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.register(UINib(nibName: "ChoreCell", bundle: nil), forCellReuseIdentifier: "ChoreCell")
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        dateFormatter.locale = Locale(identifier: "en_US")
        self.dateLabel.text = dateFormatter.string(from: selectedDate)
    
        refilterRowsAndSections()
        
        let fileUrl =  try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("Chore.sqlite")
        
        if sqlite3_open(fileUrl.path, &db) != SQLITE_OK {
            print("ERROR OPENING DB")
            return
        }
        
    }
    func refilterRowsAndSections(){
        
        let tempChores = filterChoresByDate()
        firstNames = tempChores.map{ $0.assignedPerson }
        uniqueFirstNames = Array(Set(firstNames))
        sortedFirstName = uniqueFirstNames.sorted()
        
        sections = sortedFirstName.map{firstName in return tempChores
            .filter { $0.assignedPerson == firstName}
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let currentChore = sections[indexPath.section][indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChoreCell", for: indexPath) as! ChoreCell
        cell.choreDescription?.text =  currentChore.choreDescription
        cell.choreTitle?.text =  currentChore.choreTitle
        return cell
        
    }
    
    @IBAction func didSelectBack(_ sender: Any) {
        
        self.delegate.updateChoresList(choresList: chores)
        self.dismiss(animated: true, completion: nil)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let vc = segue.destination as! AddChoreViewController
        vc.delegate = self
        
    }
 
    func addToChoreList(title: String, desc: String, name: String) {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let myString = formatter.string(from: selectedDate)
        let yourDate = formatter.date(from: myString)
        formatter.dateFormat = "dd-MMM-yyyy"
        let myStringafd = formatter.string(from: yourDate!)
        
        chores.append(Chore(choreTitle: title, choreDescription: desc, assignedPerson: name, selectedDate: myStringafd ))
        self.delegate.updateChoresList(choresList: chores)
        
        selectQuerry()
        refilterRowsAndSections()
        self.tableView.reloadData()
        
    }
    
    func filterChoresByDate() -> [Chore]{
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let myString = formatter.string(from: self.selectedDate)
        let yourDate = formatter.date(from: myString)
        formatter.dateFormat = "dd-MMM-yyyy"
        let selectedDateFromCalendar = formatter.string(from: yourDate!)
        
        var tempArray = [Chore]()
        
        for chore in chores {
            if selectedDateFromCalendar == chore.selectedDate {
                tempArray.append(chore)
            }
        }
        return tempArray
    }
    
    func selectQuerry() -> Void{
        //inventoryInfo.removeAll()
        chores.removeAll()
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
            
            chores.append(serverItem)
            
        }
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    private func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let vw = UIView()
        vw.backgroundColor = UIColor.lightGray
        return vw
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sortedFirstName[section]
    }
  
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let ct =  chores[indexPath.row].choreTitle
            self.delegate.removeChoreFromMasterList(chore: chores[indexPath.row])
            chores.remove(at: indexPath.row)
            deleteFromChoresTable(title: ct)
            selectQuerry()
            refilterRowsAndSections()
           
            tableView.reloadData()
    
        }
    }
    
    func deleteFromChoresTable(title: String){
        let deleteStatementStirng = "DELETE FROM Chores WHERE choreTitle = ?;"
        
        var deleteStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, deleteStatementStirng, -1, &deleteStatement, nil) == SQLITE_OK {
            
            let t = title as NSString
            if sqlite3_bind_text(deleteStatement, 1, t.utf8String, -1, nil) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure binding title: \(errmsg)")
                return
            }
            
            
            if sqlite3_step(deleteStatement) == SQLITE_DONE {
                print("Successfully deleted row.")
            } else {
                print("Could not delete row.")
            }
            
        } else {
            print("DELETE statement could not be prepared")
        }
        
        sqlite3_finalize(deleteStatement)
    
    }
    
}
