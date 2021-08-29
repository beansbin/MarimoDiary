//
//  RegisterVC.swift
//  MarimoDiary
//
//  Created by 박예빈 on 2021/08/29.
//
import UIKit

class RegisterVC: UIViewController {

    @IBOutlet var registerBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        registerBtn.layer.borderWidth = 1
        registerBtn.layer.borderColor = UIColor(named:"AccentColor")?.cgColor
        registerBtn.layer.cornerRadius = 10
    }


}



