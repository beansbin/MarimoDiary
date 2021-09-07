//
//  WriteVC.swift
//  MarimoDiary
//
//  Created by 박예빈 on 2021/08/29.
//

import UIKit
import PhotosUI
import AVFoundation
import CoreData

class WriteVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let picker = UIImagePickerController()
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var dDayLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    
    var tempDate: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self
        
        textView.delegate = self
        textView.text =  "일기 내용을 입력해주세요."
        textView.textColor = UIColor.darkGray
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapPhotoView))
        imgView.isUserInteractionEnabled = true
        imgView.addGestureRecognizer(tapGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // 오늘 날짜 포맷 맞추기(date to string)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        dateFormatter.locale = Locale(identifier: Locale.current.identifier)
        dateFormatter.timeZone = TimeZone(identifier: TimeZone.current.identifier)

        let dateString: String = dateFormatter.string(from: Date())
        self.dateLabel.text = dateString
        
        // D+Day 구하기
        let todayDate: Date = dateFormatter.date(from:dateString)! // 오늘 날짜의 시간을 0으로 바꾸는 작업
        print(todayDate)
        let realDate: Date = dateFormatter.date(from: tempDate)!
        let dDay = Int(todayDate.timeIntervalSince(realDate) / 86400 + 1)
        self.dDayLabel.text = "D + " + String(dDay)

    }
    
    @IBAction func writeBtn(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let diaryInfo = DiaryInfo(date: self.dateLabel.text!,
                                  image: (self.imgView.image ?? UIImage(named: "basic"))!,
                              contents: self.textView.text)
        
        let entity = NSEntityDescription.entity(forEntityName: "Diary", in: context)
        
        if let entity = entity {
            let diary = NSManagedObject(entity: entity, insertInto: context)
            diary.setValue(diaryInfo.date, forKey: "date")
            diary.setValue(diaryInfo.image.pngData(), forKey: "image")
            diary.setValue(diaryInfo.contents, forKey: "contents")
            print(diary)
            
            do {
                try context.save()
                
            } catch {
                print(error.localizedDescription)
                
            }
            
            let alert = UIAlertController(title: "일기가 저장되었습니다.", message: "일기에서 확인할 수 있어요", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default) { action in
                self.dismiss(animated: true)
            })
            self.present(alert, animated: true, completion: nil)

           
        }
        
        do {
            try context.save()
            
        } catch {
            print(error.localizedDescription)
            
        }

    }
    
    
    @objc func tapPhotoView() {
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
    
    // 사진첩 열기
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

    // 카메라 열기
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
    
    // 사진 정해졌을 때 호출됨
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            //imageButton.setBackgroundImage(image, for: .normal)
            //imageButton.setImage(image, for: .normal)
            imgView.image = image
                   print("&&")
                }

        dismiss(animated: true, completion: nil)
    }

    // 화면 터치해서 키보드 내리기
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){

        self.view.endEditing(true)
    }

}

// TextView 관련 코드
extension WriteVC: UITextViewDelegate {
  func textViewDidBeginEditing(_ textView: UITextView) {
    if textView.textColor == UIColor.lightGray {
      textView.text = nil
      textView.textColor = UIColor.black
    }
  }

  func textViewDidEndEditing(_ textView: UITextView) {
    if textView.text.isEmpty {
      textView.text = "내용을 입력해주세요."
      textView.textColor = UIColor.lightGray
    }
  }
}




