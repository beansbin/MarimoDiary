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
        // 등록뷰로 이동
        guard let viewController = self.storyboard?.instantiateViewController(identifier: "RegisterVC") else { return }
        
        viewController.modalPresentationStyle = .fullScreen
        self.present(viewController, animated: true)
    }


}

