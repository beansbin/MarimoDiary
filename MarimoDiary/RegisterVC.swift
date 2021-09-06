//
//  RegisterVC.swift
//  MarimoDiary
//
//  Created by 박예빈 on 2021/08/29.
//
import UIKit
import CoreData

class RegisterVC: UIViewController {

    @IBOutlet var registerBtn: UIButton!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var dateString: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        registerBtn.layer.borderWidth = 1
        registerBtn.layer.borderColor = UIColor(named:"AccentColor")?.cgColor
        registerBtn.layer.cornerRadius = 13
    }
    
    override func viewDidLayoutSubviews() {
        // 텍스트필드 언더라인
        
        let border = CALayer()
        border.frame = CGRect(x: 0, y: name.frame.size.height-1, width: name.frame.width, height: 1)
        border.backgroundColor = UIColor.lightGray.cgColor
        name.layer.addSublayer(border)
        name.textAlignment = .center
        name.textColor = UIColor.white
        
        let border2 = CALayer()
        border2.frame = CGRect(x: 0, y: name.frame.size.height-1, width: dateString.frame.width, height: 1)
        border2.backgroundColor = UIColor.lightGray.cgColor
        dateString.layer.addSublayer(border2)
        dateString.textAlignment = .center
        dateString.textColor = UIColor.white
    }
    
    // 등록하기 버튼을 눌렀을 때
    @IBAction func registerBtn(_ sender: Any) {
        
        if self.name.text == "" || self.dateString.text == "" {
            self.alert("값을 다시 입력해주세요")
        } else {
            // string to date
            let dateFormatter = DateFormatter()

            dateFormatter.dateFormat = "yyyyMMdd"
            dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?

            guard let date :Date = dateFormatter.date(from: self.dateString.text!) else {
                self.alert("날짜를 다시 입력해주세요")
                return
            }
            
            // 오늘 날짜의 시간을 0으로 바꾸는 작업
            let dateString: String = dateFormatter.string(from: Date())
            let todayDate: Date = dateFormatter.date(from:dateString)!

            
            if (Int(todayDate.timeIntervalSince(date)) / 86400)  < 0 {
                self.alert("날짜를 다시 입력해주세요")
                return
            }
            
            let marimoInfo = MarimoInfo(name: self.name.text!, date: date)
            
            // coreData에 마리모 정보 저장
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let entity = NSEntityDescription.entity(forEntityName: "Marimo", in: context)
            if let entity = entity { let marimo = NSManagedObject(entity: entity, insertInto: context)
                marimo.setValue(marimoInfo.name, forKey: "name")
                marimo.setValue(marimoInfo.date, forKey: "date")
                
                do {
                    try context.save()
                    
                } catch {
                    print(error.localizedDescription)
                    
                }
            }

            // 홈으로 이동
            guard let viewController = self.storyboard?.instantiateViewController(identifier: "HomeVC") else { return }
            
            viewController.modalPresentationStyle = .fullScreen
            self.present(viewController, animated: false)
        }
       


        
    }
    
    // 화면 터치해서 키보드 내리기
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        
        self.view.endEditing(true)
    }

}



