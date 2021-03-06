//
//  HomeVC.swift
//  MarimoDiary
//
//  Created by 박예빈 on 2021/08/29.
//

import UIKit
import CoreData
import CoreLocation
import Foundation
import UserNotifications
import Gifu

class HomeVC: UIViewController {
    @IBOutlet var writeBtn: UIButton!
    @IBOutlet var readBtn: UIButton!
    @IBOutlet weak var dDayLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var waterBtn: UIButton!
    
    @IBOutlet weak var foodTitle: UILabel!
    @IBOutlet weak var waterTitle: UILabel!
    @IBOutlet weak var weatherImgView: GIFImageView!
    @IBOutlet weak var weatherLabel: UILabel!
    @IBOutlet weak var weatherDescriptionLabel: UILabel!
    
    var locationManager: CLLocationManager? // 위치 관련 이벤트 전달
    var currentLocation: CLLocationCoordinate2D! // 위도, 경도 알려줌
    
    let userNotificationCenter = UNUserNotificationCenter.current()
    
    var firstDay: String = ""
    
    var locationService: LocationService.Type!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 위치 권한 요청
        requestAuthorization()
        while CLLocationManager.authorizationStatus() == .restricted || CLLocationManager.authorizationStatus() == .notDetermined {
            
        }
        locationManager!.delegate = self
        locationManagerDidChangeAuthorization(locationManager!)
        
        requestNotificationAuthorization()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        DispatchQueue.main.async {
            self.weatherImgView.animate(withGIFNamed: "loading", animationBlock:  {
                print("It's animating!")
            })
        }
        
        // 데이터 패치
        OperationQueue.main.addOperation {
            self.fetchData()
        }
        
        
    }
    
    // 데이터 패치 함수
    func fetchData() {
        
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
            
            // 오늘 날짜 포맷 맞추기(date to string)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy.MM.dd"
            dateFormatter.locale = Locale(identifier: "ko_KR")
            dateFormatter.timeZone = TimeZone(abbreviation: "KST")

            let dateString: String = dateFormatter.string(from: Date())
            self.firstDay = dateFormatter.string(from:tempDate)
            UserDefaults.standard.setValue(self.firstDay, forKey: "firstDay")
            
            // D+Day 구하기
            let todayDate: Date = dateFormatter.date(from:dateString)! // 오늘 날짜의 시간을 0으로 바꾸는 작업
            let dDay = Int(todayDate.timeIntervalSince(tempDate) / 86400 + 1)
            
            // 물주기, 먹이 주기 날짜
            dateFormatter.dateFormat = "yyyy-MM-dd"
            if UserDefaults.standard.string(forKey: "waterDay") != nil {
                let waterDate = dateFormatter.date(from: UserDefaults.standard.string(forKey: "waterDay")!)!
                let dWaterDate = Int(waterDate.timeIntervalSince(todayDate) / 86400)
        
                if dWaterDate == 0 {
                    self.waterTitle.text = "오늘"
                } else if dWaterDate < 0 {
                    self.waterTitle.text = "필요!"
                } else {
                    self.waterTitle.text = String(dWaterDate) + "일 후"
                }
            }
            
            if UserDefaults.standard.string(forKey: "foodDay") != nil {
                let foodDate  = dateFormatter.date(from: UserDefaults.standard.string(forKey: "foodDay")!)
                let dFoodDate = Int(foodDate!.timeIntervalSince(todayDate) / 86400)
                
                if dFoodDate == 0 {
                    self.waterTitle.text = "오늘"
                } else if dFoodDate < 0 {
                    self.waterTitle.text = "필요!"
                } else {
                    self.foodTitle.text = String(dFoodDate) + "일 후"
                }
            }
            
              // 레이블에 표시
              self.nameLabel.text = tempName
              self.dateLabel.text = dateString
              self.dDayLabel.text = "D + " + String(dDay)
            
            
        } catch {
            print(error.localizedDescription)
            
        }
        
        // 위치 권한 있는지 확인 후 표시
        var locationAuthorizationStatus : CLAuthorizationStatus
        let manager = CLLocationManager()
        
        if #available(iOS 14.0, *) {
            locationAuthorizationStatus = manager.authorizationStatus
            
        } else {
            //Fallback on earlier versions
            locationAuthorizationStatus = CLLocationManager.authorizationStatus()
        }
        
        // 위치 권한 있으면 날씨 표시
        var weatherImage = UIImage()
        var weatherTemp = ""
        var weatherDescription = ""
        
        if locationAuthorizationStatus == .authorizedWhenInUse {
            var weatherInfo: [String] = []
            
            // data fetch
            WeatherService().getWeather(lati: Float(LocationService.shared.latitude), longi: Float(LocationService.shared.longitude)) { result in
                switch result {
                case .success(let weatherResponse):
                    DispatchQueue.main.async {
                        weatherInfo.append(weatherResponse.weather.first!.main) // 날씨
                        weatherInfo.append(String(weatherResponse.main.temp) + " °C") // 온도
                        weatherTemp = weatherInfo[1]
                        print(weatherTemp)
                        
                        let weather = weatherInfo[0]
                        print(weather)
                        switch weather {
                            case "Clear":
                                weatherImage = UIImage(named: "basic") ?? UIImage(named: "basic")!
                                weatherDescription = "광합성하기 좋은 날이에요"
                                break
                            case "Mist": fallthrough
                            case "Smoke": fallthrough
                            case "Haze": fallthrough
                            case "Dust": fallthrough
                            case "Fog": fallthrough
                            case "Sand": fallthrough
                            case "Ash": fallthrough
                            case "Squall": fallthrough
                            case "Tornado":
                                weatherImage = UIImage(named: "cloud") ?? UIImage(named: "basic")!
                                weatherDescription = "흐려요"
                            case "Clouds":
                                weatherImage = UIImage(named: "cloud") ?? UIImage(named: "basic")!
                                weatherDescription = "비가 올 것 같아요"
                                break
                            case "Rain": fallthrough
                            case "Drizzle": fallthrough
                            case "Thunderstorm":
                                weatherImage = UIImage(named: "rain") ?? UIImage(named: "basic")!
                                weatherDescription = "비가 와요"
                                break
                            case "Snow":
                                weatherImage = UIImage(named: "snow") ?? UIImage(named: "basic")!
                                weatherDescription = "눈이 와요"
                            default:
                                weatherImage = UIImage(named: "basic") ?? UIImage(named: "basic")!
                        }
                        self.weatherImgView.stopAnimatingGIF()
                        self.weatherImgView.image = weatherImage
                        self.weatherLabel.text = weatherTemp
                        self.weatherDescriptionLabel.text = weatherDescription
                    }
                case .failure(_ ):
                    self.alert("날씨 정보를 가져올 수 없습니다.")
                }
            }
        } else { // 없는 경우
            print("알림 없음")
            self.weatherImgView.stopAnimatingGIF()
            self.weatherLabel.text = "날씨 없음"
            self.weatherDescriptionLabel.text = "위치 설정을 눌러 허용해 주세요."
            self.weatherImgView.image = UIImage(named: "basic")
        }
        
    }
    
    @IBAction func writeBtn(_ sender: Any) {
        let viewController = (self.storyboard?.instantiateViewController(identifier: "WriteVC"))! as WriteVC
        viewController.tempDate = self.firstDay
        present(viewController, animated: true)
}
    
    @IBAction func waterBtn(_ sender: Any) {
        requestNotificationAuthorization()
        
        let center = UNUserNotificationCenter.current()
        
        center.getNotificationSettings { [self] (settings) in
            if(settings.authorizationStatus == .authorized)
            {
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "물주기", message: "오늘 마리모에게 물을 줬나요?", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "네", style: .default) { action in
                        self.sendNotification(day: 14, type: "water")
                    })
                    alert.addAction(UIAlertAction(title: "아니요", style: .default) { action in
                        //self.dismiss(animated: true)
                    })
                    self.present(alert, animated: true, completion: nil)
                    }
            }
            else
            {
                self.alert("설정 > 알림 권한을 허용해 주세요.")
            }
        }
    }
    
    @IBAction func foodBtn(_ sender: Any) {
        let center = UNUserNotificationCenter.current()
        
        center.getNotificationSettings { (settings) in
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "먹이 주기", message: "오늘 마리모에게 먹이를 줬나요?", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "네", style: .default) { action in
                    self.sendNotification(day: 14, type: "food")
                })
                alert.addAction(UIAlertAction(title: "아니요", style: .default) { action in
                    //self.dismiss(animated: true)
                })
                self.present(alert, animated: true, completion: nil)
                }
        }
    }
    
    // 알림 권한 요청
    func requestNotificationAuthorization() {
        let authOptions = UNAuthorizationOptions(arrayLiteral: .alert, .badge, .sound)

        userNotificationCenter.requestAuthorization(options: authOptions) { success, error in
            if let error = error {
                print("Error: \(error)")
            }
        }
    }
    
    // 로컬 푸시 설정하기
    func sendNotification(day: Int, type: String) {
        let notificationContent = UNMutableNotificationContent()
        
        if type == "water" {
            notificationContent.title = "물주기 알림"
            notificationContent.body = "오늘은 마리모에게 물을 주는 날이에요!"
        } else if type == "food" {
            notificationContent.title = "먹이주기 알림"
            notificationContent.body = "오늘은 마리모에게 먹이를 주는 날이에요!"
        }
        
        let now = Date()
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd-hh"
        let day = DateComponents(day: day)
        let dDay = calendar.date(byAdding: day, to: now)
        print(dateFormatter.string(from: dDay!))
            
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour], from: dDay!)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: "testNotification",
                                            content: notificationContent,
                                            trigger: trigger)

        userNotificationCenter.add(request) { error in
            if let error = error {
                print("Notification Error: ", error)
            }
        }
        
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let day2: String = dateFormatter.string(from: dDay!)
        switch type {
        case "water":
            UserDefaults.standard.set(day2, forKey: "waterDay")
            self.alert("다음 물주기 날짜까지 \(day.day!)일 남았어요.")
            break
        case "food":
            UserDefaults.standard.set(day2, forKey: "foodDay")
            self.alert("다음 먹이 주기 날짜까지 \(day.day!)일 남았어요.")
            break
        default:
            print("default")
        }
        
        viewWillAppear(true)
    }
}


// 위치 관련 코드
extension HomeVC : CLLocationManagerDelegate {
    // 위치 권한 요청
    private func requestAuthorization() {
           if locationManager == nil {
               locationManager = CLLocationManager()
               //정확도를 검사한다.
               locationManager!.desiredAccuracy = kCLLocationAccuracyBest
               //앱을 사용할때 권한요청
               locationManager!.requestWhenInUseAuthorization()
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
}

// 에러 정의
enum NetworkError: Error {
    case badUrl
    case noData
    case decodingError
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
    
    func getWeather(lati: Float, longi: Float, completion: @escaping (Result<WeatherResponse, NetworkError>) -> Void) {
            let baseURL: String = "https://api.openweathermap.org/data/2.5/weather?"
            let appid: String = "&APPID="
            let strLati = "lat=\(Float(lati))&"
            let strLongi = "lon=\(Float(longi))"
            let celsius = "&units=metric"
        
            let tempUrl = URL(string:  baseURL + strLati + strLongi + appid + apiKey + celsius)
        
            guard let url = tempUrl else {
                       return completion(.failure(.badUrl))
                   }
        
            URLSession.shared.dataTask(with: url) { data, response, error in
                guard let data = data, error == nil else {
                    return completion(.failure(.noData))
                }
                
                // Data 타입으로 받은 리턴을 디코드
                let weatherResponse = try? JSONDecoder().decode(WeatherResponse.self, from: data)

                // 성공
                if let weatherResponse = weatherResponse {
                    print(weatherResponse)
                    completion(.success(weatherResponse)) // 성공한 데이터 저장
                } else {
                    completion(.failure(.decodingError))
                }
            }.resume() // 이 dataTask 시작
        }
}


