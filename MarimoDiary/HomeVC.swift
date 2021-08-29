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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        writeBtn.layer.borderWidth = 1
        writeBtn.layer.borderColor = UIColor(named:"AccentColor")?.cgColor
        writeBtn.layer.cornerRadius = 10
        
        readBtn.layer.borderWidth = 1
        readBtn.layer.borderColor = UIColor(named:"AccentColor")?.cgColor
        readBtn.layer.cornerRadius = 10
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        do {
            let marimo = try context.fetch(Marimo.fetchRequest()) as! [Marimo]
            marimo.forEach {
                print($0.name)
                print($0.date)
            }
            
        } catch {
            print(error.localizedDescription)
            
        }

        
    }


}


