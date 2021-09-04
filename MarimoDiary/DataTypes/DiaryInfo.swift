//
//  DiaryInfo.swift
//  MarimoDiary
//
//  Created by 박예빈 on 2021/09/04.
//

import UIKit

struct DiaryInfo {
    var date: String
    var image: UIImage
    var contents: String
    
    init(date: String, image: UIImage, contents: String) {
        self.date = date
        self.image = image
        self.contents = contents
    }
}
