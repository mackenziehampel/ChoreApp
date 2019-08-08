//
//  AddChoreViewController.swift
//  ChoreApp
//
//  Created by Mackenzie Hampel on 7/27/19.
//  Copyright © 2019 Mackenzie Hampel. All rights reserved.
//

import Foundation
import UIKit
protocol ChoreListDelegate {
    func addToChoreList(title: String, desc: String, name: String)
}

class AddChoreViewController: UIViewController, UITextViewDelegate, NameDelegate {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var choreTitle: UITextField!
    @IBOutlet weak var choreDescription: UITextView!
    @IBOutlet weak var personName: UILabel!
    var choreGreen = UIColor()
    var choreOrange = UIColor()
    var delegate: ChoreListDelegate!
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
     //  choreOrange = UIColor.init(red: (255.0/255.0), green: (102.0/255.0), blue: (51.0/255.0), alpha: 1.0)
        
        choreGreen = UIColor.init(red: (102.0/255.0), green: (153.0/255.0), blue: (102.0/255.0), alpha: 1.0)
        
        contentView.gradientBackground(from: .white, to: choreGreen, direction: .bottomToTop)
        self.hideKeyboardWhenTappedAround()
        
        
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        choreTitle.resignFirstResponder()
        choreDescription.resignFirstResponder()
        
        return true
    }
    
    @IBAction func didSelectBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didSelectCreate(_ sender: Any) {
        
        self.delegate.addToChoreList(title: choreTitle.text!, desc: choreDescription.text!, name: self.personName.text!)
        self.dismiss(animated: true, completion: nil)
        
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! AssignPersonViewController
        vc.delegate = self
    }
    
    func passBackName(name: String) {
        self.personName.text = name
    }
}
