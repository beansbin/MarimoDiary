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

class HomeVC: UIViewController {
    @IBOutlet var writeBtn: UIButton!
    @IBOutlet var readBtn: UIButton!
    @IBOutlet weak var dDayLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!

    @IBOutlet weak var weatherImgView: UIImageView!
    @IBOutlet weak var weatherLabel: UILabel!
    @IBOutlet weak var weatherDescriptionLabel: UILabel!
    
    var locationManager: CLLocationManager? // 위치 관련 이벤트 전달
    var currentLocation: CLLocationCoordinate2D! // 위도, 경도 알려줌
    
    let userNotificationCenter = UNUserNotificationCenter.current()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 위치 권한 설정
        requestAuthorization()
        
        // 알림 권한 설정
        requestNotificationAuthorization()
        
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
            let dateString: String = dateFormatter.string(from: Date())
            let todayDate: Date = dateFormatter.date(from:dateString)! // 오늘 날짜의 시간을 0으로 바꾸는 작업
            
            // D+Day 구하기
            let dDay = Int(Date().timeIntervalSince(todayDate) / 86400 + 1)

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
                        weatherInfo.append(weatherResponse.weather.first!.description) // 날씨
                        weatherInfo.append(String(weatherResponse.main.temp) + "°C") // 온도
                        weatherTemp = weatherInfo[1]
                        print(weatherTemp)
                        
                        let weather = weatherInfo[0]
                        print(weather)
                        switch weather {
                            case "clear sky": fallthrough
                            case "mist":
                                weatherImage = UIImage(named: "basic") ?? UIImage(named: "basic")!
                                weatherDescription = "광합성하기 좋은 날이에요"
                                break
                            case "few clouds": fallthrough
                            case "scattered clouds": fallthrough
                            case "broken clouds":
                                weatherImage = UIImage(named: "cloud") ?? UIImage(named: "basic")!
                                weatherDescription = "비가 올 것 같아요"
                                break
                            case "shower rain": fallthrough
                            case "rain": fallthrough
                            case "thunderstorm":
                                weatherImage = UIImage(named: "rain") ?? UIImage(named: "basic")!
                                weatherDescription = "비가 와요"
                                break
                            case "snow":
                                weatherImage = UIImage(named: "snow") ?? UIImage(named: "basic")!
                                weatherDescription = "눈이 와요"
                            default:
                                weatherImage = UIImage(named: "basic") ?? UIImage(named: "basic")!
                        }
                        self.weatherImgView.image = weatherImage
                        self.weatherLabel.text = weatherTemp
                        self.weatherDescriptionLabel.text = weatherDescription
                    }
                case .failure(_ ):
                    print("error")
                }
            }
            
           
        } else { // 없는 경우
            weatherImage = UIImage(named: "basic") ?? UIImage(named: "basic")!
            self.weatherLabel.text = "날씨 없음"
            self.weatherDescriptionLabel.text = "위치 권한 아이콘을 눌러 허용해 주세요."
        }
    }

    @IBAction func waterBtn(_ sender: Any) {
        let center = UNUserNotificationCenter.current()
        
        center.getNotificationSettings { (settings) in
            if(settings.authorizationStatus == .authorized)
            {
                print("Push authorized")
            }
            else
            {
                print("Push not authorized")
            }
        }
        
        sendNotification(day: 14)
        
    }
    @IBAction func foodBtn(_ sender: Any) {
        requestNotificationAuthorization()
        sendNotification(day: 14)
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
    func sendNotification(day: Int) {
        let notificationContent = UNMutableNotificationContent()

        notificationContent.title = "알림 테스트"
        notificationContent.body = "이것은 알림을 테스트 하는 것이다"
        
        let now = Date()
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd-hh"
        let day = DateComponents(day: day)
        if let dDay = calendar.date(byAdding: day, to: now)
        {
            print(dateFormatter.string(from: dDay))
            
            let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour], from: dDay)
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            let request = UNNotificationRequest(identifier: "testNotification",
                                                content: notificationContent,
                                                trigger: trigger)

            userNotificationCenter.add(request) { error in
                if let error = error {
                    print("Notification Error: ", error)
                }
            }
            
            UserDefaults.standard.set(dDay, forKey: "waterDay")
        }
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


