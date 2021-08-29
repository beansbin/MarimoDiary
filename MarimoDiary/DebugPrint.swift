//
//  DebugPrint.swift
//  MarimoDiary
//
//  Created by 박예빈 on 2021/08/29.
//

import Foundation

func dPrint(_ index:String, _ msg:String){
    
    // 사용방법
    // dPrint("CouponList TEST", "사용 가능한 쿠폰 \(userCouponList.count) 개")
    
    #if DEBUG
    print("#", index, "# msg: ", msg)
    #endif
}

