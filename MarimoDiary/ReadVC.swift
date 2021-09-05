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
    @IBOutlet weak var valueLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 데이터 로드하기
        fetchContact()
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
        cell.imgView?.image = diaryArray[index].image
        cell.textField?.text = diaryArray[index].contents
        cell.dateLabel.text = diaryArray[index].date
        
        return cell
    }
    
    public func pagerView(_ pagerView: FSPagerView, willDisplay cell: FSPagerViewCell, forItemAt index: Int) {
        self.pageSlider.maximumValue = Float(diaryArray.count-1)
        self.pageSlider.value = Float(index)
        print(pageSlider.value)
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


