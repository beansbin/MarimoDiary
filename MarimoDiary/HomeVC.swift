//
//  HomeVC.swift
//  MarimoDiary
//
//  Created by 박예빈 on 2021/08/29.
//

import UIKit
import CoreData
import CoreLocation

class HomeVC: UIViewController, CLLocationManagerDelegate {
    @IBOutlet var writeBtn: UIButton!
    @IBOutlet var readBtn: UIButton!
    @IBOutlet weak var dDayLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    var locationManager: CLLocationManager? // 위치 관련 이벤트 전달
    var currentLocation: CLLocationCoordinate2D! // 위도, 경도 알려줌
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 버튼 디자인
        designBtn()
        
        // 위치 권한 설정
        requestAuthorization()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        var tempName : String = ""
        var tempDate : Date = Date()
        
        do {
            let marimo = try context.fetch(Marimo.fetchRequest()) as! [Marimo]
            marimo.forEach {
                tempName = $0.name!
                tempDate = $0.date!
                // print(tempName)
                // print(tempDate)
            } // 마지막에 저장된 것 보여줄 것임
            
            // date to string
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy.MM.dd"
            let dateString: String = dateFormatter.string(from: tempDate)
            
            // D+Day 구하기
            let dDay = Int(Date().timeIntervalSince(tempDate)) / 86400 + 1

            // 레이블에 표시
            self.nameLabel.text = tempName
            self.dateLabel.text = dateString
            self.dDayLabel.text = "D + " + String(dDay)
            
            
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
    
    // 위치 권한 요청
    private func requestAuthorization() {
           if locationManager == nil {
               locationManager = CLLocationManager()
               //정확도를 검사한다.
               locationManager!.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
               //앱을 사용할때 권한요청
               locationManager!.requestWhenInUseAuthorization()
               locationManager!.delegate = self
               locationManagerDidChangeAuthorization(locationManager!)
           }else{
               //사용자의 위치가 바뀌고 있는지 확인하는 메소드
               locationManager!.startMonitoringSignificantLocationChanges()
           }
       }
    
    // 위도, 경도 알아내기
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        var locationAuthorizationStatus : CLAuthorizationStatus
        if #available(iOS 14.0, *) {
            locationAuthorizationStatus = manager.authorizationStatus
            
        } else {
            //Fallback on earlier versions
            locationAuthorizationStatus = CLLocationManager.authorizationStatus()
        }
        
        if locationAuthorizationStatus == .authorizedWhenInUse {
           currentLocation = locationManager!.location?.coordinate
           LocationService.shared.longitude = currentLocation.longitude
           LocationService.shared.latitude = currentLocation.latitude
        }
    }
    
    class LocationService {
        
        static var shared = LocationService()
        var longitude:Double!
        var latitude:Double!
      
    }
    
    // apiKey 접근하기
    private var apiKey: String {
        get {
            // 생성한 .plist 파일 경로 불러오기
            guard let filePath = Bundle.main.path(forResource: "KeyList", ofType: "plist") else {
                fatalError("Couldn't find file 'KeyList.plist'.")
            }
            
            // .plist를 딕셔너리로 받아오기
            let plist = NSDictionary(contentsOfFile: filePath)
            
            // 딕셔너리에서 값 찾기
            guard let value = plist?.object(forKey: "OPENWEATHERMAP_KEY") as? String else {
                fatalError("Couldn't find key 'OPENWEATHERMAP_KEY' in 'KeyList.plist'.")
            }
            return value
        }
    }


}


class WeatherService {
    // .plist에서 API Key 가져오기
    private var apiKey: String {
        get {
            // 생성한 .plist 파일 경로 불러오기
            guard let filePath = Bundle.main.path(forResource: "KeyList", ofType: "plist") else {
                fatalError("Couldn't find file 'KeyList.plist'.")
            }
            
            // .plist를 딕셔너리로 받아오기
            let plist = NSDictionary(contentsOfFile: filePath)
            
            // 딕셔너리에서 값 찾기
            guard let value = plist?.object(forKey: "OPENWEATHERMAP_KEY") as? String else {
                fatalError("Couldn't find key 'OPENWEATHERMAP_KEY' in 'KeyList.plist'.")
            }
            return value
        }
    }

}


