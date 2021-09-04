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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 데이터 로드하기
        
    }
    
    func fetchContact() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        do {
            let contact = try context.fetch(Diary.fetchRequest()) as! [Diary]
            contact.forEach {
                let unencodedData = Data(base64Encoded: $0.image!)
                let image = UIImage(data: unencodedData!)
                let diary = DiaryInfo(date: $0.date!, image: image!, contents: $0.contents!)
                diaryArray.append(diary)
                
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
            self.pagerView.automaticSlidingInterval = 4.0
            // 스타일
            self.pagerView.transformer = FSPagerViewTransformer(type: .linear)

        }
    }
    
}

class CustomPagerCell : FSPagerViewCell {
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var textField: UITextView!
    
    
}

extension ReadVC : FSPagerViewDelegate, FSPagerViewDataSource {
    
    // 셀 개수
    public func numberOfItems(in pagerView: FSPagerView) -> Int {
        return 3
    }
        
    // 각 셀 설정
    public func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "cell", at: index) as! CustomPagerCell
        cell.imgView?.image = UIImage(named : "basic")
        cell.textField?.text = "text!"
        
        return cell
    }
}


