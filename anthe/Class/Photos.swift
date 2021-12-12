//
//  Photos.swift
//  Luna
//
//  Created by Mart Civil on 2017/03/14.
//  Copyright © 2017年 salesforce.com. All rights reserved.
//

import Foundation
import Photos
import MobileCoreServices
import UIKit

enum PHAssetMediaType : Int {
    case Unknown
    case Image
    case Video
    case Audio
}

enum PickerType: String {
    case PHOTO_LIBRARY      = "PHOTO_LIBRARY"
    case CAMERA             = "CAMERA"
    case VIDEO_LIBRARY      = "VIDEO_LIBRARY"
    case CAMCORDER          = "CAMCORDER"
}

class Photos {
    
    private static var photoAssets = [PHAsset]()
    
    public static var checkSaveToPhotos:((Bool, String)->())?
    public static var savePhoto:((ImageFile)->())?
    public static var savePhotoError:((String)->())?
    public static var photoType:PickerType?
    
    public class func getMediaPickerController( view: UIViewController?, type:PickerType?=PickerType.PHOTO_LIBRARY ) -> Bool {
        let mediaPickerController = UIImagePickerController()
        mediaPickerController.allowsEditing = false
        
        if( type == PickerType.PHOTO_LIBRARY && UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary) ) {
            mediaPickerController.sourceType = .photoLibrary
            mediaPickerController.mediaTypes = [kUTTypeImage as String] //kUTTypeMovie kUTTypeImage
        } else if( type == PickerType.CAMERA && UIImagePickerController.isSourceTypeAvailable(.camera) ) {
            mediaPickerController.sourceType = .camera
            mediaPickerController.cameraCaptureMode = .photo
            mediaPickerController.modalPresentationStyle = .fullScreen
        } else if( type == PickerType.VIDEO_LIBRARY && UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary) ) {
            mediaPickerController.sourceType = .photoLibrary
            mediaPickerController.videoQuality = .typeHigh
            mediaPickerController.mediaTypes = [kUTTypeMovie as String] //kUTTypeMovie kUTTypeImage
        }  else if( type == PickerType.CAMCORDER && UIImagePickerController.isSourceTypeAvailable(.camera) ) {
            mediaPickerController.mediaTypes = [kUTTypeMovie as String]
            mediaPickerController.sourceType = .camera
            mediaPickerController.cameraCaptureMode = .video
            mediaPickerController.modalPresentationStyle = .fullScreen
            mediaPickerController.videoQuality = .typeHigh
            mediaPickerController.videoMaximumDuration = 10
        } else {
            return false;
        }
        mediaPickerController.delegate = view as! (UIImagePickerControllerDelegate & UINavigationControllerDelegate)?
        view?.present( mediaPickerController, animated: true, completion: nil )
        return true;
    }
    
    public class func takePicture( type:String, onSuccess:( @escaping (ImageFile)->()), onFail: @escaping ((String)->()) ) {
        savePhoto       = onSuccess
        savePhotoError  = onFail
        
        savePhoto = { (result:ImageFile) -> () in
            onSuccess( result )
            savePhoto = nil
        }
        
        savePhotoError = { (errorMessage:String) -> () in
            onFail( errorMessage )
            savePhotoError = nil
        }
        
        if let pickerType = PickerType(rawValue: type) {
            photoType = pickerType
            
            let getPickerController = { () -> () in
                DispatchQueue.main.async {
                    if !Photos.getMediaPickerController(view: Shared.shared.ViewController, type: pickerType) {
                        Photos.savePhotoError?( "[ERROR] Photos.app is not available" )
                    }
                }
            }
            let requestAuthorization = { (isRequestAuth: Bool) -> () in
                if( isRequestAuth ) {
                    PHPhotoLibrary.requestAuthorization({(newStatus) in
                        if newStatus ==  PHAuthorizationStatus.authorized {
                            getPickerController()
                        } else {
                            Photos.savePhotoError?( "[ERROR] Photos.app is not available" )
                        }
                    })
                } else {
                    getPickerController()
                }
            }
            if pickerType == .PHOTO_LIBRARY || pickerType == .VIDEO_LIBRARY {
                requestAuthorization( true)
            } else {
                requestAuthorization( false)
            }
        }
    }
    
    public class func process( media:[String: Any]?=nil ) {
        if media != nil {
            guard let photoType = Photos.photoType else {
                return
            }
            
            switch photoType {
            case .PHOTO_LIBRARY:
                do {
                    if let imageURL = media![convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.imageURL)] as? URL,
                       let phasset = media![convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.phAsset)] as? PHAsset {
                        let imageFile = try ImageFile( fileId:File.generateID(), localIdentifier:phasset.localIdentifier, assetURL: imageURL)
                        Photos.savePhoto?( imageFile )
                    }
                } catch let error as NSError {
                    Photos.savePhotoError?( error.localizedDescription )
                }
                break
            case .CAMERA:
                let exifData = NSMutableDictionary(dictionary: media![convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.mediaMetadata)] as! NSDictionary )
                if let takenImage = media![convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage {
                    do {
                        let imageFile = try ImageFile( fileId:File.generateID(), uiimage:takenImage, exif:exifData, savePath:"CACHE" )
                        Photos.savePhoto?( imageFile )
                    } catch let error as NSError {
                        Photos.savePhotoError?( error.localizedDescription )
                    }
                } else {
                    Photos.savePhotoError?( "Cannot obtain photo" )
                }
                break
            case .VIDEO_LIBRARY:
                break
            case .CAMCORDER:
                break
            }
        } else {
            Photos.savePhotoError?( "User cancelled operation" )
        }

//    case PickerType.PHOTO_LIBRARY:
//        if( isAllowed == true ) {
//            do {
//                if let imageURL = media![convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.imageURL)] as? URL, let phasset = media![convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.phAsset)] as? PHAsset {
//                    let imageFile = try ImageFile( fileId:File.generateID(), localIdentifier:phasset.localIdentifier, assetURL: imageURL)
//                    command.resolve(value: imageFile.toDictionary(), raw: imageFile)
//                }
//            } catch let error as NSError {
//                command.reject(errorMessage: error.localizedDescription)
//            }
//        } else {
//            command.reject(errorMessage: "Not authorized to access Photos App")
//        }
//        break
//    case PickerType.CAMERA:
//        let exifData = NSMutableDictionary(dictionary: media![convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.mediaMetadata)] as! NSDictionary )
//        if let takenImage = media![convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage {
//            do {
//                let imageFile = try ImageFile( fileId:File.generateID(), uiimage:takenImage, exif:exifData, savePath:"CACHE" )
//                command.resolve(value: imageFile.toDictionary(), raw: imageFile)
//            } catch let error as NSError {
//                command.reject( errorMessage: error.localizedDescription )
//            }
//            command.resolve(value: true)
//        } else {
//            command.reject( errorMessage: "Cannot obtain photo" )
//        }
//        break
    }
    
    
    
    public class func appendEXIFtoImageBinary( uiimage:UIImage, exif:NSDictionary ) -> NSData {
        let imageData = uiimage.pngData()
        
        let imageRef:CGImageSource = CGImageSourceCreateWithData((imageData! as CFData), nil)!
        let uti: CFString = CGImageSourceGetType(imageRef)!
        let dataWithEXIF: NSMutableData = NSMutableData(data: imageData!)
        
        
        let destination: CGImageDestination = CGImageDestinationCreateWithData((dataWithEXIF as CFMutableData), uti, 1, nil)!
        CGImageDestinationAddImageFromSource(destination, imageRef, 0, (exif as CFDictionary))
        CGImageDestinationFinalize(destination)
        
        return dataWithEXIF
    }
    
    public class func appendEXIF( uiimage:UIImage ) {
        //https://stackoverflow.com/questions/5125323/problem-setting-exif-data-for-an-image/43376828#43376828
        // create filename
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd-HH.mm.ss"
        let now = Date()
        let date_time = dateFormatter.string(from: now)
        let fileName:String = "your_image_"+date_time+".jpg" // name your file the way you want
        //let temporaryFolder:URL = FileManager.default.temporaryDirectory
        let temporaryFolder:URL = FileManager.getDocumentsDirectoryPath(pathType: .DOCUMENT_TYPE, relative: "")!
        let temporaryFileURL:URL = temporaryFolder.appendingPathComponent(fileName)
        
        // save the image to chosen path
        //let jpeg = uiimage.jpegData(compressionQuality: 1.0)! // set JPG quality here (1.0 is best)
        let png = uiimage.pngData()!
        
        let src = CGImageSourceCreateWithData(png as CFData, nil)!
        let uti = CGImageSourceGetType(src)!
        let cfPath = CFURLCreateWithFileSystemPath(nil, temporaryFileURL.path as CFString, CFURLPathStyle.cfurlposixPathStyle, false)
        let dest = CGImageDestinationCreateWithURL(cfPath!, uti, 1, nil)
        
        // create GPS metadata from current location
        let dummyLoc = CLLocation(latitude: 35.000, longitude: 125.000)
        let gpsMeta = dummyLoc.exifMetadata() // gCurrentLocation is your CLLocation (exifMetadata is an extension)
        let tiffProperties = [
            kCGImagePropertyTIFFMake as String: "Camera vendor",
            kCGImagePropertyTIFFModel as String: "Camera model",
            kCGImagePropertyTIFFImageDescription as String: "LYNX",
            "custom":"A quick brown fox jumped over a lazy dog"
            // --(insert other properties here if required)--
            ] as CFDictionary
        
        let properties = [
            kCGImagePropertyTIFFDictionary as String: tiffProperties,
            kCGImagePropertyGPSDictionary: gpsMeta as Any
            // --(insert other dictionaries here if required)--
            ] as CFDictionary
        
        CGImageDestinationAddImageFromSource(dest!, src, 0, properties)
        if (CGImageDestinationFinalize(dest!)) {
            print("Saved image with metadata!", temporaryFileURL.path)
        } else {
            print("Error saving image with metadata")
        }
    }
    
//    public class func getAsset( fileURL: URL ) -> PHAsset? {
//        let result = PHAsset.fetchAssets(withALAssetURLs: [fileURL], options: nil)
//        return result.firstObject
//    }
    
    public class func getVideoAsset( fileURL: URL ) -> PHAsset? {
        let result = PHAsset.fetchAssets(with: .video, options: nil)
        return result.firstObject
    }
    
    public class func goToSettings() {
        let url = NSURL(string: UIApplication.openSettingsURLString)
        UIApplication.shared.open(url! as URL) { (result) in
            print( result )
        }
    }
    
    public class func getAllPhotosInfo() {
        photoAssets = []
        
        // 画像をすべて取得
        let assets: PHFetchResult = PHAsset.fetchAssets(with: .image, options: nil)
        assets.enumerateObjects({ (asset, index, stop) -> Void in
            self.photoAssets.append(asset as PHAsset)
        })
        print(photoAssets)
    }
    
    public class func getAllSortedPhotosInfo() {
        
        // ソート条件を指定
        let options = PHFetchOptions()
        options.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: false)
        ]
        
        let assets: PHFetchResult = PHAsset.fetchAssets(with: .image, options: options)
        assets.enumerateObjects({ (asset, index, stop) -> Void in
            self.photoAssets.append(asset as PHAsset)
        })
        print(photoAssets)
    }
    
    public class func getPhotoAt( index:Int) -> PHAsset?{
        // ソート条件を指定
        let options = PHFetchOptions()
        options.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: false)
        ]
        
        let assets: PHFetchResult = PHAsset.fetchAssets(with: .image, options: options)
        if( index < assets.count ) {
            return assets[ index ]
        }
        return nil
    }
    
    public class func getBinaryVideo( asset: PHAsset, onSuccess:@escaping ((Data)->()), onFail: @escaping((String)->())  ) {
        let manager: PHImageManager = PHImageManager()
        manager.requestAVAsset(forVideo: asset, options: nil) { (videoAsset, avaudio, _: [AnyHashable : Any]?) in
            
            if videoAsset != nil {
                if let vasset = videoAsset as? AVURLAsset {
                    if let binaryData = NSData(contentsOf: vasset.url) {
                        onSuccess( binaryData as Data )
                        return
                    }
                }
            }
            onFail( FileError.INEXISTENT.localizedDescription )
        }
    }
    
    public class func getBinaryImage( asset: PHAsset, onSuccess:@escaping ((Data)->()), onFail: @escaping((String)->())  ) {
        let manager: PHImageManager = PHImageManager()
        
        manager.requestImageDataAndOrientation(for: asset, options: nil) { (binaryImage, info, orient, _: [AnyHashable : Any]?) in
            if binaryImage != nil {
                onSuccess( binaryImage! )
            } else {
                onFail( FileError.INEXISTENT.localizedDescription )
            }
        }
//        manager.requestImageData(for: asset, options: nil) { (binaryImage, info, orient, _: [AnyHashable : Any]?) in
//            if binaryImage != nil {
//                onSuccess( binaryImage! )
//            } else {
//                onFail( FileError.INEXISTENT.localizedDescription )
//            }
//        }
    }
    
    public class func getImage( asset: PHAsset, onSuccess:@escaping ((UIImage)->()), onFail: @escaping((String)->()) ) {
        Photos.getBinaryImage(asset: asset, onSuccess: { (binaryImage) in
            if let uiimage = ImageFile.binaryToUIImage(binary: binaryImage) {
                onSuccess( uiimage )
                return
            }
        }) { (error) in
            onFail( error )
        }
    }
}


import CoreLocation

extension CLLocation {
    func exifMetadata(heading:CLHeading? = nil) -> NSMutableDictionary {
        let GPSMetadata = NSMutableDictionary()
        let altitudeRef = Int(self.altitude < 0.0 ? 1 : 0)
        let latitudeRef = self.coordinate.latitude < 0.0 ? "S" : "N"
        let longitudeRef = self.coordinate.longitude < 0.0 ? "W" : "E"
        
        // GPS metadata
        GPSMetadata[(kCGImagePropertyGPSLatitude as String)] = abs(self.coordinate.latitude)
        GPSMetadata[(kCGImagePropertyGPSLongitude as String)] = abs(self.coordinate.longitude)
        GPSMetadata[(kCGImagePropertyGPSLatitudeRef as String)] = latitudeRef
        GPSMetadata[(kCGImagePropertyGPSLongitudeRef as String)] = longitudeRef
        GPSMetadata[(kCGImagePropertyGPSAltitude as String)] = Int(abs(self.altitude))
        GPSMetadata[(kCGImagePropertyGPSAltitudeRef as String)] = altitudeRef
        GPSMetadata[(kCGImagePropertyGPSTimeStamp as String)] = self.timestamp.isoTime()
        GPSMetadata[(kCGImagePropertyGPSDateStamp as String)] = self.timestamp.isoDate()
        GPSMetadata[(kCGImagePropertyGPSVersion as String)] = "2.2.0.0"
        
        if let heading = heading {
            GPSMetadata[(kCGImagePropertyGPSImgDirection as String)] = heading.trueHeading
            GPSMetadata[(kCGImagePropertyGPSImgDirectionRef as String)] = "T"
        }
        
        return GPSMetadata
    }
}

extension Date {
    func isoDate() -> String {
        let f = DateFormatter()
        f.timeZone = TimeZone(abbreviation: "UTC")
        f.dateFormat = "yyyy:MM:dd"
        return f.string(from: self)
    }
    
    func isoTime() -> String {
        let f = DateFormatter()
        f.timeZone = TimeZone(abbreviation: "UTC")
        f.dateFormat = "HH:mm:ss.SSSSSS"
        return f.string(from: self)
    }
}


extension ViewController: UIImagePickerControllerDelegate {

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        //CommandProcessor.processMediaPicker()
        //print( "[MEDIA] processMediaPicker" )
        Photos.process()
        self.dismiss(animated: true, completion: nil);
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        //print( "[MEDIA]", info )
        Photos.process(media: info)
        //CommandProcessor.processMediaPicker( media: info  )
        self.dismiss(animated: true, completion: nil);
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
    return input.rawValue
}
