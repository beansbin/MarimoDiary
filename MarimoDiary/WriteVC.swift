//
//  WriteVC.swift
//  MarimoDiary
//
//  Created by 박예빈 on 2021/08/29.
//

import UIKit
import PhotosUI
import AVFoundation

class WriteVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let picker = UIImagePickerController()
    @IBOutlet weak var imageButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // 사진 권한 요청 (최초 요청)
        PHPhotoLibrary.requestAuthorization { status in
            return
        }
        
        // 카메라 권한 요청 (최초 요청)
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { response in
            return
        }
        
    }
    
    @IBAction func imageBtn(_ sender: Any) {

        let alert =  UIAlertController(title: "원하는 타이틀", message: "원하는 메세지", preferredStyle: .actionSheet)

        let library =  UIAlertAction(title: "사진앨범", style: .default) { (action) in
            self.openLibrary()
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
        
        let photoAuthorization = PHPhotoLibrary.authorizationStatus()
        switch photoAuthorization {
        case .authorized:
            picker.sourceType = .photoLibrary
            present(picker, animated: false, completion: nil)
            break
        default:
            self.alert("설정에서 사진 권한을 허용해 주세요.")
        }
       

    }

    func openCamera(){
        let cameraAuthorization = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        switch cameraAuthorization {
        case .authorized:
            picker.sourceType = .camera
            present(picker, animated: false, completion: nil)
            break
        default:
            self.alert("설정에서 카메라 권한을 허용해 주세요.")
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            imageButton.setBackgroundImage(image, for: .normal)
            //imageButton.setImage(image, for: .normal)
                   print("&&")
                }

        dismiss(animated: true, completion: nil)

    }

    // 화면 터치해서 키보드 내리기
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){

        self.view.endEditing(true)
    }

}




