//
//  PhotoEditingViewController.swift
//  MyPhotoExt
//
//  Created by 김현수 on 2020/09/16.
//  Copyright © 2020 Hyun Soo Kim. All rights reserved.
//

import UIKit
import Photos
import PhotosUI

class PhotoEditingViewController: UIViewController, PHContentEditingController {

    var input: PHContentEditingInput?
    
    //이미지와 이미지 방향을 저장할 변수
    var displayedImage: UIImage?
    var imageOrientation: Int32?
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBAction func sepia(_ sender: Any) {
        currentFilter = "CISepiaTone"
        if let image = displayedImage {
            imageView.image = performFilter(image, orientation: nil)
        }
    }
    @IBAction func mono(_ sender: Any) {
        currentFilter = "CIPhotoEffectMono"
        if let image = displayedImage{
            imageView.image = performFilter(image, orientation: nil)
        }
    }
    @IBAction func invert(_ sender: Any) {
        currentFilter = "CIColorInvert"
        if let image = displayedImage{
            imageView.image = performFilter(image, orientation: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
        
    //기본 필터의 문자열
    var currentFilter = "CIColorInvert"
    
    //필터 적용을 위한 사용자 정의 메소드
    func performFilter(_ inputImage:UIImage, orientation:Int32?) -> UIImage?{
        var resultImage:UIImage?
        var cimage: CIImage
        
        //원본 이미지를 가지고 필터를 적용할 CIImage를 생성
        cimage = CIImage(image: inputImage)!
        
        if let orientation = orientation{
            cimage = cimage.oriented(forExifOrientation: orientation)
        }
        
        //필터 적용
        if let filter = CIFilter(name:currentFilter){
            filter.setDefaults()
            filter.setValue(cimage, forKey: "inputImage")
            
            switch currentFilter{
            case "CISepiaTone", "CIEdges":
                filter.setValue(0.8, forKey: "inputIntensity")
            case "CIMotionBlur":
                filter.setValue(25.00, forKey:"inputRadius")
                filter.setValue(0.00, forKey:"inputAngle")
            default:
                break
            }
            
            if let ciFilteredImage = filter.outputImage{
                let context = CIContext(options:nil)
                if let cgimage = context.createCGImage(ciFilteredImage, from: ciFilteredImage.extent){
                    resultImage = UIImage(cgImage:cgimage)
                }
            }
        }
        return resultImage
    }
    
    // MARK: - PHContentEditingController
    
    func canHandle(_ adjustmentData: PHAdjustmentData) -> Bool {
        // Inspect the adjustmentData to determine whether your extension can work with past edits.
        // (Typically, you use its formatIdentifier and formatVersion properties to do this.)
        return false
    }
    
    //사진 앱에서 편집을 눌렀을 때 호출되는 메소드
    func startContentEditing(with contentEditingInput: PHContentEditingInput, placeholderImage: UIImage) {
        //선택한 이미지 정보를 저장한 객체
        input = contentEditingInput
        
        //선택한 이미지를 이미지 뷰에 출력
        if let input = input{
            displayedImage = input.displaySizeImage
            imageOrientation = input.fullSizeImageOrientation
            imageView.image = displayedImage
        }
    }
    
    func finishContentEditing(completionHandler: @escaping ((PHContentEditingOutput?) -> Void)) {
        // Update UI to reflect that editing has finished and output is being rendered.
        
        // Render and provide output on a background queue.
        DispatchQueue.global().async {
            // Create editing output from the editing input.
            let output = PHContentEditingOutput(contentEditingInput: self.input!)
            
            // Provide new adjustments and render output to given location.
            // output.adjustmentData = <#new adjustment data#>
            // let renderedJPEGData = <#output JPEG#>
            // renderedJPEGData.writeToURL(output.renderedContentURL, atomically: true)
            
            // Call completion handler to commit edit to Photos.
            completionHandler(output)
            
            // Clean up temporary files, etc.
        }
    }
    
    var shouldShowCancelConfirmation: Bool {
        // Determines whether a confirmation to discard changes should be shown to the user on cancel.
        // (Typically, this should be "true" if there are any unsaved changes.)
        return false
    }
    
    func cancelContentEditing() {
        // Clean up temporary files, etc.
        // May be called after finishContentEditingWithCompletionHandler: while you prepare output.
    }

}
