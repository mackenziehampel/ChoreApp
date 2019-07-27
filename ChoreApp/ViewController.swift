//
//  ViewController.swift
//  ChoreApp
//
//  Created by Mackenzie Hampel on 7/20/19.
//  Copyright © 2019 Mackenzie Hampel. All rights reserved.
//

import UIKit
import FSCalendar

class ViewController: UIViewController, FSCalendarDelegate, FSCalendarDataSource {

    @IBOutlet weak var calendar: FSCalendar!
    // fileprivate weak var calendar: FSCalendar!
    @IBOutlet weak var gradientView: UIView!
    @IBOutlet weak var gradientViewBottom: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        calendar.dataSource = self
        calendar.delegate = self
        
        let opaqueBlue = UIColor.init(red: (0/255.0), green: (122.0/255.0), blue: (255.0/255.0), alpha: 0.5)
        let choreBlue = UIColor.init(red: (0/255.0), green: (122.0/255.0), blue: (255.0/255.0), alpha: 1.0)
        
        let textAttributes = [NSAttributedString.Key.foregroundColor:choreBlue]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        
        gradientView.gradientBackground(from: .white, to: opaqueBlue, direction: .bottomToTop)
        gradientViewBottom.gradientBackground(from: opaqueBlue, to: .white, direction: .bottomToTop)

        
    }
    
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
    }
    
    
    @IBAction func didSelectViewChoresForDay(_ sender: Any) {
        
    }
    
}




