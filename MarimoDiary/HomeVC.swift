//
//  HomeVC.swift
//  MarimoDiary
//
//  Created by 박예빈 on 2021/08/29.
//

import UIKit
import CoreData

class HomeVC: UIViewController {
    @IBOutlet var writeBtn: UIButton!
    @IBOutlet var readBtn: UIButton!
    @IBOutlet weak var dDayLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        // 버튼 디자인
        designBtn()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        
        var tempName : String = ""
        var tempDate : Date = Date()
        do {
            let marimo = try context.fetch(Marimo.fetchRequest()) as! [Marimo]
            marimo.forEach {
                tempName = $0.name!
                tempDate = $0.date!
            } // 마지막에 저장된 것 보여줄 것임
            
            // date to string
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy.MM.dd"

            let dateString: String = dateFormatter.string(from: tempDate)

            self.nameLabel.text = tempName
            self.dateLabel.text = dateString
            
        } catch {
            print(error.localizedDescription)
            
        }

        
    }
    
    // 버튼 디자인
    func designBtn() {
        writeBtn.layer.borderWidth = 1
        writeBtn.layer.borderColor = UIColor(named:"AccentColor")?.cgColor
        writeBtn.layer.cornerRadius = 10
        
        readBtn.layer.borderWidth = 1
        readBtn.layer.borderColor = UIColor(named:"AccentColor")?.cgColor
        readBtn.layer.cornerRadius = 10
        
    }


}


