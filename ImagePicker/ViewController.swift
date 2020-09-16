//
//  ViewController.swift
//  ImagePicker
//
//  Created by 김현수 on 2020/09/16.
//  Copyright © 2020 Hyun Soo Kim. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController {

    @IBOutlet weak var imgView: UIImageView!
    
    @IBAction func pick(_ sender: Any) {
        //피커 객체 생성
        let picker = UIImagePickerController()
        //소스 선택
        picker.sourceType = .photoLibrary
        //편집 가능 여부 설정
        picker.allowsEditing = true
        //출력
        self.present(picker, animated: true)
        
        picker.delegate = self
    }
    
    @IBAction func upload(_ sender: Any) {
        let insertAlert = UIAlertController(title: "데이터 추가", message: "추가할 데이터를 입력하세요", preferredStyle: .alert)
        
        //텍스트 필드를 추가
        insertAlert.addTextField() {(tf) -> Void in
            tf.placeholder = "아이템 이름을 입력하세요"
        }
        insertAlert.addTextField() {(tf) -> Void in
            tf.placeholder = "가격을 입력하세요"
            tf.keyboardType = .numberPad
        }
        insertAlert.addTextField() {(tf) -> Void in
            tf.placeholder = "설명을 입력하세요"
        }
        
        //대화상자에 버튼을 추가 - 대화상자를 닫는 기본 기능을 내장
        insertAlert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        insertAlert.addAction(UIAlertAction(title: "확인", style: .default) {(_) -> Void in
            //확인 버튼을 눌렀을 때 수행할 내용
            
            //입력한 내용을 가져옴
            let itemname = insertAlert.textFields?[0].text
            let price = insertAlert.textFields?[1].text
            let description = insertAlert.textFields?[2].text
            
            //입력 받은 내용을 웹 서버의 파리미터로 사용하기 위해서
            //딕셔너리로 변환
            let paramDict = ["itemname": itemname, "price": price, "description": description]
            
            //업로드
            AF.upload(multipartFormData: {MultipartFormData in
                //딕셔너리를 읽어서 파라미터로 설정
                for(key, value) in paramDict {
                    if let temp = value as? String {
                        MultipartFormData.append(temp.data(using: .utf8)!, withName: key)
                    }
                }
                
                //파일 전송
                let image = self.imgView.image
                //일반 파일이면 파일 경로를 가지고 읽어서 Data 로 변환해서 사용
                //FileManager를 이용해서 파일 경오를 입력하고 contents 메소드를 호출하면 됨
                if image != nil {
                    MultipartFormData.append(image!.pngData()!, withName: "pictureurl", fileName: "file.png", mimeType: "image/png")
                }
            }, to: "http://cyberadam.cafe24.com/item/insert", method: .post, headers: nil).validate(statusCode: 200..<300).responseJSON {
                response in
                //NSLog("\(response.value)")
                if let jsonObject = response.value as? [String: Any] {
                    let result = (jsonObject["result"] as? NSNumber)!.intValue
                    if result == 1 {
                        NSLog("성공")
                    } else {
                        NSLog("실패")
                    }
                }
            }
        })
        self.present(insertAlert, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    //앨범에서 이미지 선택을 취소한 경우 호출되는 메소드
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        NSLog("이미지 선택을 취소하셨습니다.")
        //picker.dismiss를 호출하지 않으면 이미지 피커가 사라지지 않음
        picker.dismiss(animated: true, completion: nil)
    }
    
    //앨범에서 선택 한 경우 호출되는 메소드
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //이미지 피커를 닫을 때 작업을 수행
        picker.dismiss(animated: true) {() -> Void in
            //편집된 이미지를 가져와서 이미지 뷰에 출력
            let img = info[UIImagePickerController.InfoKey.editedImage] as! UIImage
            self.imgView.image = img
        }
    }
}

