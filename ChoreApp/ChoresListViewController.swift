//
//  ChoresListViewController.swift
//  ChoreApp
//
//  Created by Mackenzie Hampel on 7/27/19.
//  Copyright © 2019 Mackenzie Hampel. All rights reserved.
//

import Foundation
import UIKit

protocol UpdateChoresListDelegate {
    func updateChoresList(choresList: [Chore])
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
        
        firstNames = chores.map{ $0.assignedPerson }
        uniqueFirstNames = Array(Set(firstNames))
        sortedFirstName = uniqueFirstNames.sorted()
        
        sections = sortedFirstName.map{firstName in return self.chores
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
        let myString = formatter.string(from: Date())
        let yourDate = formatter.date(from: myString)
        formatter.dateFormat = "dd-MMM-yyyy"
        let myStringafd = formatter.string(from: yourDate!)
        chores.append(Chore(choreTitle: title, choreDescription: desc, assignedPerson: name, selectedDate: myStringafd ))
        self.tableView.reloadData()
        
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
  
}
