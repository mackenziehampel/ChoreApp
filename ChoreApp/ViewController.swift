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
        
        let lightBlue = UIColor.init(red: (0/255.0), green: (122.0/255.0), blue: (255.0/255.0), alpha: 0.5)
        
        let textAttributes = [NSAttributedString.Key.foregroundColor:lightBlue]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        
        gradientView.gradientBackground(from: .white, to: lightBlue, direction: .bottomToTop)
        gradientViewBottom.gradientBackground(from: lightBlue, to: .white, direction: .bottomToTop)
    }

    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
    }
}

enum GradientDirection {
    case leftToRight
    case rightToLeft
    case topToBottom
    case bottomToTop
}

extension UIView {
    func gradientBackground(from color1: UIColor, to color2: UIColor, direction: GradientDirection) {
        let gradient = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = [color1.cgColor, color2.cgColor]
        
        switch direction {
        case .leftToRight:
            gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
            gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
        case .rightToLeft:
            gradient.startPoint = CGPoint(x: 1.0, y: 0.5)
            gradient.endPoint = CGPoint(x: 0.0, y: 0.5)
        case .bottomToTop:
            gradient.startPoint = CGPoint(x: 0.5, y: 1.0)
            gradient.endPoint = CGPoint(x: 0.5, y: 0.0)
        case .topToBottom:
            gradient.startPoint = CGPoint(x: 1.0, y: 0.3)
            gradient.endPoint = CGPoint(x: 0.0, y: 0.3)
        default:
            break
        }
        
        self.layer.insertSublayer(gradient, at: 0)
    }
}

