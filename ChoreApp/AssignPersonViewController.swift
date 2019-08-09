//
//  AssignPersonViewController.swift
//  ChoreApp
//
//  Created by Mackenzie Hampel on 7/27/19.
//  Copyright © 2019 Mackenzie Hampel. All rights reserved.
//

import Foundation
import UIKit
import SQLite3

protocol NameDelegate {
    func passBackName(name:String)
}

struct Person {
    var name = String()
}

class AssignPersonViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var contentView: UIView!
    var choreBlue = UIColor()
    var delegate: NameDelegate!
    var textField: UITextField?
    var persons = [Person]()
    var db: OpaquePointer?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        choreBlue = contentView.backgroundColor!
        
        contentView.gradientBackground(from: choreBlue, to: .white, direction: .topToBottom)
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        
        //SQLLITE
        let fileUrl =  try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("Chore.sqlite")
        
        if sqlite3_open(fileUrl.path, &db) != SQLITE_OK {
            print("ERROR OPENING DB")
            return
        }
        
        let createTableQuery = "CREATE TABLE IF NOT EXISTS Persons (id INTEGER PRIMARY KEY AUTOINCREMENT, name VARCHAR)"
        if sqlite3_exec(db, createTableQuery, nil, nil, nil) != SQLITE_OK {
            print("Error creating table")
            return
        }
        
        print("EVERYTHING IS FINE")
        selectQuerry()
        self.saveToDatabase()
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return persons.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for:indexPath) as UITableViewCell
        
        cell.textLabel!.text = persons[indexPath.row].name
      
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegate.passBackName(name: persons[indexPath.row].name)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didSelectBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addPerson(_ sender: Any){
        
        let alert = UIAlertController(title: "Add Person", message: "create a new person to add to chores", preferredStyle: UIAlertController.Style.alert)
        alert.addTextField(configurationHandler: configurationTextField)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:nil))
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler:{ (UIAlertAction) in
            self.persons.append(Person(name: self.textField!.text!))
            self.tableView.reloadData()
            self.saveToDatabase()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func configurationTextField(textField: UITextField!) {
        if (textField) != nil {
            self.textField = textField!
            self.textField?.placeholder = "name";
        }
    }
    
    
    func selectQuerry() -> Void{
        //inventoryInfo.removeAll()
        persons.removeAll()
        let queryString = "SELECT * FROM Persons;"
        var stmt:OpaquePointer?
        
        
        if sqlite3_prepare_v2(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return
        }
        
        //traversing through all the records
        while(sqlite3_step(stmt) == SQLITE_ROW){
            let id = sqlite3_column_int(stmt, 0)
            let name = String(cString: sqlite3_column_text(stmt, 1))
            let serverItem = Person(name: name)
            persons.append(serverItem)
            
        }
    }
    
    func saveToDatabase() {
        let querryStmt = "DELETE FROM Persons;"
        var deletePtr: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, querryStmt, -1, &deletePtr, nil) == SQLITE_OK {
            if sqlite3_step(deletePtr) == SQLITE_DONE {
                print("was deleted")
            } else {
                print("deletion failed")
            }
        }
        
        sqlite3_close(deletePtr)
        
        if !persons.isEmpty {
            for l in persons{

                let insertQuery = "INSERT INTO Persons (name) VALUES (?);"
                var stmt: OpaquePointer?
                
                if sqlite3_prepare_v2(db, insertQuery, -1, &stmt, nil) != SQLITE_OK {
                    let errmsg = String(cString: sqlite3_errmsg(db)!)
                    print("error preparing insert: \(errmsg)")
                    return
                }
                let n = l.name as NSString
                if sqlite3_bind_text(stmt, 1, n.utf8String, -1, nil) != SQLITE_OK{
                    let errmsg = String(cString: sqlite3_errmsg(db)!)
                    print("failure binding subtitle: \(errmsg)")
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
