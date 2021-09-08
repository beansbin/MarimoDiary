//
//  ReadVC.swift
//  MarimoDiary
//
//  Created by 박예빈 on 2021/08/29.
//

import UIKit
import FSPagerView
import CoreData

class ReadVC: UIViewController {
    var diaryArray: [DiaryInfo] = []
    @IBOutlet weak var pageSlider: UISlider!
    @IBOutlet weak var emptyImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 데이터 로드하기
        fetchContact()
        
        if diaryArray.count != 0 {
            self.emptyImage.alpha = 0
        }
    }
    
    // 슬라이더 값 변경되면 호출됨
    @IBAction func changeSlider(_ sender: UISlider) {
        self.pageSlider.maximumValue = Float(diaryArray.count-1)
        self.pagerView.scrollToItem(at: Int(sender.value), animated: true)
    }
    
    // 다이어리 데이터 가져오기
    func fetchContact() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        do {
            let contact = try context.fetch(Diary.fetchRequest()) as! [Diary]
            contact.forEach {
                let diary = DiaryInfo(date: $0.date!, image: UIImage(data: $0.image!, scale:1.0)!, contents: $0.contents!)
                diaryArray.append(diary)
                //print(diaryArray)
                
            }
        } catch {
            print(error.localizedDescription)
            
        }
        
    }
    
    // 사진 돌아가는 오류 보정하는 함수
    func fixOrientation(img: UIImage) -> UIImage {
        if (img.imageOrientation == .up) {
            return img
        }

        UIGraphicsBeginImageContextWithOptions(img.size, false, img.scale)

        let rect = CGRect(x: 0, y: 0, width: img.size.width, height: img.size.height)

        img.draw(in: rect)

        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()!

        UIGraphicsEndImageContext()

        return normalizedImage
    }
    
    @IBOutlet weak var pagerView: FSPagerView! {
        didSet {
            // 페이저뷰에 셀 등록
            self.pagerView.register(UINib(nibName:"customPagerCell", bundle: Bundle.main), forCellWithReuseIdentifier: "cell")
            // 아이템 크기 설정
            self.pagerView.itemSize = FSPagerView.automaticSize
            // 무한 스크롤
            self.pagerView.isInfinite = true
            // 자동 스크롤
            self.pagerView.automaticSlidingInterval = 0
            // 스타일
            self.pagerView.transformer = FSPagerViewTransformer(type: .linear)

        }
    }
    
}

class CustomPagerCell : FSPagerViewCell {
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var textField: UITextView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var dDayLabel: UILabel!
    
    
}

extension ReadVC : FSPagerViewDelegate, FSPagerViewDataSource {
    
    // 셀 개수
    public func numberOfItems(in pagerView: FSPagerView) -> Int {
        print(diaryArray.count)
        return diaryArray.count
    }
        
    // 각 셀 설정
    public func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "cell", at: index) as! CustomPagerCell
        cell.imgView?.image = fixOrientation(img: diaryArray[index].image)
        cell.textField?.text = diaryArray[index].contents
        cell.dateLabel.text = diaryArray[index].date
        
        // dDay 구하기
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        dateFormatter.locale = Locale(identifier: Locale.current.identifier)
        dateFormatter.timeZone = TimeZone(identifier: TimeZone.current.identifier)
        
        let dateString: String = dateFormatter.string(from: Date())
        let todayDate: Date = dateFormatter.date(from:dateString)! // 오늘 날짜의 시간을 0으로 바꾸는 작업
        let realDate: Date = dateFormatter.date(from:UserDefaults.standard.string(forKey: "firstDay")!)!
        let dDay = Int(todayDate.timeIntervalSince(realDate) / 86400 + 1)
        cell.dDayLabel.text = "D + " + String(dDay)

        
        return cell
    }
    
    public func pagerView(_ pagerView: FSPagerView, willDisplay cell: FSPagerViewCell, forItemAt index: Int) {
        self.pageSlider.maximumValue = Float(diaryArray.count-1)
        self.pageSlider.value = Float(index)
    }
    
}

class PageSlider: UISlider {
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
            let width = self.frame.size.width
            let tapPoint = touch.location(in: self)
            let fPercent = tapPoint.x/width
            let nNewValue = self.maximumValue * Float(fPercent)
            if nNewValue != self.value {
                self.value = nNewValue
            }
            return true
        }
}


