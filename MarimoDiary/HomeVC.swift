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

class HomeVC: UIViewController {
    @IBOutlet var writeBtn: UIButton!
    @IBOutlet var readBtn: UIButton!
    @IBOutlet weak var dDayLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!

    @IBOutlet weak var weatherImgView: UIImageView!
    
    var locationManager: CLLocationManager? // 위치 관련 이벤트 전달
    var currentLocation: CLLocationCoordinate2D! // 위도, 경도 알려줌
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 버튼 디자인
        designBtn()
        
        // 위치 권한 설정
        requestAuthorization()
        
      //  print(WeatherDataManager().setCurrentWeather(lati: Float(LocationService.shared.latitude), longi: Float(LocationService.shared.longitude), completion: <#()#>))
        
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
        
        // 위치 권한 있는지 확인 후 표시
        var locationAuthorizationStatus : CLAuthorizationStatus
        let manager = CLLocationManager()
        
        if #available(iOS 14.0, *) {
            locationAuthorizationStatus = manager.authorizationStatus
            
        } else {
            //Fallback on earlier versions
            locationAuthorizationStatus = CLLocationManager.authorizationStatus()
        }
        
        var weatherImage = UIImage()
        
        if locationAuthorizationStatus == .authorizedWhenInUse {
            var weatherInfo: [String] = []
            
            // data fetch
            WeatherService().getWeather(lati: Float(LocationService.shared.latitude), longi: Float(LocationService.shared.longitude)) { result in
                switch result {
                case .success(let weatherResponse):
                    DispatchQueue.main.async {
                        weatherInfo.append(weatherResponse.weather.first!.description) // 날씨
                        weatherInfo.append(String(weatherResponse.main.temp)) // 온도
                        
                        let weather = weatherInfo[0]
                        print(weather)
                        switch weather {
                            case "clear sky": fallthrough
                            case "mist":
                                weatherImage = UIImage(named: "basic") ?? UIImage(named: "basic")!
                                break
                            case "few clouds": fallthrough
                            case "scattered clouds":
                                weatherImage = UIImage(named: "cloud") ?? UIImage(named: "basic")!
                                break
                            case "broken clouds":
                                weatherImage = UIImage(named: "cloud") ?? UIImage(named: "basic")!
                                break
                            case "shower rain": fallthrough
                            case "rain": fallthrough
                            case "thunderstorm":
                                weatherImage = UIImage(named: "rain") ?? UIImage(named: "basic")!
                                break
                            case "snow":
                                weatherImage = UIImage(named: "snow") ?? UIImage(named: "basic")!
                            default:
                                weatherImage = UIImage(named: "basic") ?? UIImage(named: "basic")!
                        }
                        self.weatherImgView.image = weatherImage
                    }
                case .failure(_ ):
                    print("error")
                }
            }
            
           
        } else { // 없는 경우
            weatherImage = UIImage(named: "basic") ?? UIImage(named: "basic")!
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

//// 날씨값을 반환 하는 데이터 센터
//class WeatherDataManager {
//    static var shread: WeatherDataManager = WeatherDataManager()
//    let baseURL: String = "https://api.openweathermap.org/data/2.5/weather?"
//    let appid: String = "&APPID="
//
//    // apiKey 접근하기
//    private var apiKey: String {
//        get {
//            // 생성한 .plist 파일 경로 불러오기
//            guard let filePath = Bundle.main.path(forResource: "KeyList", ofType: "plist") else {
//                fatalError("Couldn't find file 'KeyList.plist'.")
//            }
//
//            // .plist를 딕셔너리로 받아오기
//            let plist = NSDictionary(contentsOfFile: filePath)
//
//            // 딕셔너리에서 값 찾기
//            guard let value = plist?.object(forKey: "OPENWEATHERMAP_KEY") as? String else {
//                fatalError("Couldn't find key 'OPENWEATHERMAP_KEY' in 'KeyList.plist'.")
//            }
//            return value
//        }
//    }
//
//    func setCurrentWeather(lati: Float, longi: Float) -> [String] {
//        let strLati = "lat=\(Float(lati))&"
//        let strLongi = "lon=\(Float(longi))"
//        var resultArray: [String] = []
//
//        let url = baseURL + strLati + strLongi + appid + apiKey
//        print(url)
//        let semaphore = DispatchSemaphore(value: 0)
//
//        do {
//            AF.request(url, method: .get, encoding: JSONEncoding.default).validate(statusCode: 200..<300).responseJSON { (json) in
//
//                let weatherResponse = try! JSONDecoder().decode(WeatherResponse.self, from: json.data!)
//                resultArray.append(weatherResponse.weather[0].description)
//                resultArray.append(String(weatherResponse.main.temp))
//                print(resultArray)
//                defer {
//                    semaphore.signal() // 네트워킹 끝나면 신호 보내기
//                }
//            }
//        } catch {
//            print("날씨 정보를 받아오는 데 실패했습니다.")
//           // semaphore.signal()
//        }
//
//        semaphore.wait() // 네트워킹 끝날 때 까지 대기
//
//
//        return resultArray
//    }
//
//
//}
//
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
        
            let tempUrl = URL(string:  baseURL + strLati + strLongi + appid + apiKey)
        
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


