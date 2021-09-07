//
//  SplashVC.swift
//  MarimoDiary
//
//  Created by 박예빈 on 2021/08/29.
//

import UIKit

class SplashVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // 첫 실행 여부
        if UserDefaults.standard.object(forKey: "isFirst") == nil {
            firstLaunch() // 실행했음을 저장
            // 등록뷰로 이동
            guard let viewController = self.storyboard?.instantiateViewController(identifier: "RegisterVC") else { return }
            
            viewController.modalPresentationStyle = .fullScreen
            self.present(viewController, animated: false)
        } else {
            // 홈으로 이동
            guard let viewController = self.storyboard?.instantiateViewController(identifier: "HomeVC") else { return }
            
            viewController.modalPresentationStyle = .fullScreen
            self.present(viewController, animated: false)
        }
       
    }
    
    // 첫 실행일 때
    func firstLaunch() {
        let isFirstLaunch = true
        let isFirstKey = "isFirst"
        
        UserDefaults.standard.set(isFirstLaunch, forKey : isFirstKey)
        
    }
    
    


}

