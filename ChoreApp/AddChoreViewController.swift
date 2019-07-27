//
//  AddChoreViewController.swift
//  ChoreApp
//
//  Created by Mackenzie Hampel on 7/27/19.
//  Copyright © 2019 Mackenzie Hampel. All rights reserved.
//

import Foundation
import UIKit


class AddChoreViewController: UIViewController, UITextViewDelegate {
   
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var choreTitle: UITextField!
    @IBOutlet weak var choreDescription: UITextView!
    var choreGreen = UIColor()
    var choreOrange = UIColor()
    
    override func viewDidLoad() {
        super.viewDidLoad()
       choreOrange = UIColor.init(red: (255.0/255.0), green: (102.0/255.0), blue: (51.0/255.0), alpha: 1.0)
        
        choreGreen = UIColor.init(red: (102.0/255.0), green: (153.0/255.0), blue: (102.0/255.0), alpha: 1.0)
        
        contentView.gradientBackground(from: .white, to: choreOrange, direction: .bottomToTop)
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
    }
}
