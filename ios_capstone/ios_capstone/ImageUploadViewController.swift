//
//  ViewController.swift
//  ios_capstone
//
//  Created by zhoufeng on 2022/8/11.
//

import UIKit
import PhotosUI

class ImageUploadViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var position: UITextField!
    @IBOutlet weak var infoShow: UILabel!
    @IBOutlet weak var itemTitle: UITextField!
    @IBOutlet weak var keywords: UITextField!
    @IBOutlet weak var itemDescribe: UITextField!
    var latitude = "0.0000"
    var longitude = "0.0000"
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    // image interaction tap
    @IBAction func tapImageView(_ sender: UITapGestureRecognizer) {
        let photoLibrary = PHPhotoLibrary.shared()
        let configuration = PHPickerConfiguration(photoLibrary: photoLibrary)
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
    // dict transfor json
    func convertDictionaryToJSONString(dict:NSDictionary?)->String {
        let data = try? JSONSerialization.data(withJSONObject: dict!, options: JSONSerialization.WritingOptions.init(rawValue: 0))
        let jsonStr = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
        return jsonStr! as String
    }
    
//    func getUrlFromS3() {
//        let session = URLSession(configuration: .default)
//        let url = "https://capstone.freeyeti.net/api/photos/upload"
//        var request = URLRequest(url: URL(string: url)!)
//        request.setValue("multipart/form-data", forHTTPHeaderField: "Content-Type")
//        request.httpMethod = "POST"
//        // post dict
//        let postData = ["photo": imageView] as [String : Any]
//
//        let postString = convertDictionaryToJSONString(dict: postData as NSDictionary)
//        request.httpBody = postString.data(using: .utf8)
//        // task for post
//        let task = session.dataTask(with: request) {(data, response, error) in
//            do {
//                let r = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
//                if r.allKeys.count > 2 {
//                    self.infoShow.text = "Successfully!"
//                }
//            } catch {
//                print("network error")
//                return
//            }
//        }
//        task.resume()
//    }
    
    // upload file start
    @IBAction func uploadImage(_ sender: Any) {
        
        if itemTitle.text == "" || keywords.text == "" || itemDescribe.text == "" {
            infoShow.text = "please fill in all field"
            return
        }
        // create a URLSession
        let session = URLSession(configuration: .default)
       
        
        // step2 upload info to database
        
        // set url
        let url = "https://capstone.freeyeti.net/api/photos/"
        var request = URLRequest(url: URL(string: url)!)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        // post dict
        let postData = ["title":itemTitle.text!,"description":itemDescribe.text!,"keywords": keywords.text!,"url": "https://capstone.freeyeti.net/media/9c412b24-fc91-44e1-b87a-fdb439994b2b.jpg",
                        "thumb_url": "https://capstone.freeyeti.net/media/9c412b24-fc91-44e1-b87a-fdb439994b2b_thumb.jpg","position": [
                            "latitude": latitude,
                            "longitude": longitude
                        ]] as [String : Any]

        let postString = convertDictionaryToJSONString(dict: postData as NSDictionary)
        request.httpBody = postString.data(using: .utf8)
        // task for post
        let task = session.dataTask(with: request) { (data, response, error) in
            do {
                let r = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                print(r)
            } catch {
                print("network error")
                return
            }
        }
        task.resume()
    }
    
}

// set delegate for picker
extension ImageUploadViewController : PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard !results.isEmpty else {
            return
          }

          let imageResult = results[0]
            // change imageVIew
            imageResult.itemProvider.loadObject(ofClass: UIImage.self, completionHandler: { (object, error) in
               if let image = object as? UIImage {
                  DispatchQueue.main.async {
                     // Use UIImage
                    self.imageView.image = image
                  }
               }
            })
          // get image Assets info
          if let assetId = imageResult.assetIdentifier {
            let assetResults = PHAsset.fetchAssets(withLocalIdentifiers: [assetId], options: nil)
            position.text = "\(String(describing: assetResults.firstObject?.location?.coordinate.latitude ?? 0.0000))   \(String(describing: assetResults.firstObject?.location?.coordinate.longitude ?? 0.0000))"
            latitude = "\(String(describing: assetResults.firstObject?.location?.coordinate.latitude ?? 0.0000))"
            longitude = "\(String(describing: assetResults.firstObject?.location?.coordinate.longitude ?? 0.0000))"
            
            print(assetResults.firstObject?.description ?? "No date")
//            print(assetResults.firstObject?.creationDate ?? "No date")
//            print(assetResults.firstObject?.location?.coordinate.latitude ?? "No location")
          }
                    
    }
    
//    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//        // dismiss photo library
//        picker.dismiss(animated: false, completion: nil)
//        // set imageView the selected image
//        imageView.image = info[.originalImage] as? UIImage
//
//        // get selected image's metaData: Asset, creation Data, Location
//
//    }
}
