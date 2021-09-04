//
//  WriteVC.swift
//  MarimoDiary
//
//  Created by 박예빈 on 2021/08/29.
//

import UIKit
import PhotosUI

class WriteVC: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    let picker = UIImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self
    }
    
    @IBAction func imageBtn(_ sender: Any) {

        
        let alert =  UIAlertController(title: "원하는 타이틀", message: "원하는 메세지", preferredStyle: .actionSheet)

        let library =  UIAlertAction(title: "사진앨범", style: .default) { (action) in self.openLibrary()
        }

        let camera =  UIAlertAction(title: "카메라", style: .default) { (action) in

        self.openCamera()
        }

        let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)

        alert.addAction(library)
        alert.addAction(camera)
        alert.addAction(cancel)

        present(alert, animated: true, completion: nil)
    }
    
    func openLibrary() {
        // 사진, 카메라 권한 (최초 요청)
        PHPhotoLibrary.requestAuthorization { status in
            return
        }
        let photoAuthorization = PHPhotoLibrary.authorizationStatus()
        switch photoAuthorization {
        case .authorized:
            picker.sourceType = .photoLibrary
            present(picker, animated: false, completion: nil)
            break
        default:
            self.alert("설정에서 사진, 카메라 권한을 허용해 주세요.")
        }
       

    }

    func openCamera(){
        // 사진, 카메라 권한 (최초 요청)
        PHPhotoLibrary.requestAuthorization { status in
            return
        }
        let photoAuthorization = PHPhotoLibrary.authorizationStatus()
        switch photoAuthorization {
        case .authorized:
            picker.sourceType = .camera
            present(picker, animated: false, completion: nil)
            break
        default:
            self.alert("설정에서 사진, 카메라 권한을 허용해 주세요.")
        }
    }



    // 화면 터치해서 키보드 내리기
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){

        self.view.endEditing(true)
    }

}

extension ViewController : UIImagePickerControllerDelegate,

UINavigationControllerDelegate {



}



