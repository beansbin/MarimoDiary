//
//  RegisterVC.swift
//  MarimoDiary
//
//  Created by 박예빈 on 2021/08/29.
//
import UIKit
import CoreData
import CoreLocation

class RegisterVC: UIViewController, UITextFieldDelegate{

    @IBOutlet var registerBtn: UIButton!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var dateString: UITextField!
    
    var locationManager: CLLocationManager? // 위치 관련 이벤트 전달
    var currentLocation: CLLocationCoordinate2D! // 위도, 경도 알려줌
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        registerBtn.layer.borderWidth = 1
        registerBtn.layer.borderColor = UIColor(named:"AccentColor")?.cgColor
        registerBtn.layer.cornerRadius = 20
    
    }
    
    override func viewDidLayoutSubviews() {
        // 텍스트필드 언더라인
        let border = CALayer()
        let width = CGFloat(1.0)
        border.borderColor = UIColor.lightGray.cgColor
        border.frame = CGRect(x: 0, y: name.frame.size.height - width, width:  name.frame.size.width, height: name.frame.size.height)

        border.borderWidth = width
        name.layer.addSublayer(border)
        name.layer.masksToBounds = true
        
        let border2 = CALayer()
        border2.borderColor = UIColor.lightGray.cgColor
        border2.frame = CGRect(x: 0, y: dateString.frame.size.height - width, width:  dateString.frame.size.width, height: dateString.frame.size.height)

        border2.borderWidth = width
        dateString.layer.addSublayer(border2)
        dateString.layer.masksToBounds = true

        
    }

    // 등록하기 버튼을 눌렀을 때
    @IBAction func registerBtn(_ sender: Any) {
        
        if self.name.text == "" || self.dateString.text == "" {
            self.alert("값을 다시 입력해주세요")
        } else {
            // string to date
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyyMMdd"
            dateFormatter.locale = Locale(identifier: "ko_KR")
            dateFormatter.timeZone = TimeZone(abbreviation: "KST")

            guard let date :Date = dateFormatter.date(from: self.dateString.text!) else {
                self.alert("날짜를 다시 입력해주세요")
                return
            }
            
            // 오늘 날짜의 시간을 0으로 바꾸는 작업
            let dateString: String = dateFormatter.string(from: Date())
            let todayDate: Date = dateFormatter.date(from:dateString)!
            print(Date())
            print(dateString)
            print(todayDate)
            print(date)

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
            let viewController = (self.storyboard?.instantiateViewController(identifier: "HomeVC"))! as HomeVC
            
            viewController.modalPresentationStyle = .fullScreen
            self.present(viewController, animated: false)
        }
        
    }
    
    // 화면 터치해서 키보드 내리기
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        self.view.endEditing(true)
    }


}
