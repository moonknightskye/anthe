//
//  MainView.swift
//  blackhole
//
//  Created by Mart Civil on 2019/04/15.
//  Copyright © 2019 salesforce.com. All rights reserved.
//
import UIKit

protocol DetailViewDelegate: AnyObject {
    func closedDetailView()
}

class MainView: UIView, DetailViewDelegate {
    private var imageElement        : UIImageView!
    private var descriptionSubView  : UIView!
    private var takenImage          : UIImageView?
    private var tagSubview          : UIView!
    private var titleLabel          : UILabel?
    private var photoRecordId       : String?
    private var userDailyEvent      : String?
    private var tagList             : [String]?
    private var childList           : [NSDictionary]?
    private let normalColor         = UIColor(red: 138/255, green: 255/255, blue: 253/255, alpha: 1.0)
    private let selectedColor       = UIColor(red: 15/255, green: 124/255, blue: 123/255, alpha: 1.0)
    
    override init( frame: CGRect ) {
        super.init( frame: frame )
    }
    
    public func setup() {
        let spacer:CGFloat          = 30.0
        let buttonSize:CGFloat      = 60.0
        let documentWidth           = self.frame.width
        let documentHeight          = self.frame.height
        
        //self.backgroundColor        = UIColor(red: 33/255, green: 33/255, blue: 33/255, alpha: 1.0)
        self.backgroundColor        = UIColor.white
        self.clipsToBounds          = true
        
        self.imageElement           = {() -> UIImageView in
            let imageView           = UIImageView(image: UIImage(named: "back1"))
            imageView.frame         = CGRect(x: 0, y: 0, width: documentWidth, height: documentHeight/2)
            imageView.contentMode   = .scaleAspectFill
            return imageView
        }()
        self.addSubview( self.imageElement )
        
        self.descriptionSubView     = {() -> UIView in
            let view                = UIView( frame:CGRect(x: spacer, y: documentHeight/4.2, width: documentWidth - (spacer*2), height: documentHeight * 0.62) )
            view.backgroundColor    = UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 1.0)
            view.layer.cornerRadius = 24.0
            view.clipsToBounds = true
            view.layer.borderWidth = 6
            view.layer.borderColor  = UIColor(red: 0/255, green: 67/255, blue: 148/255, alpha: 1.0).cgColor
            
            self.titleLabel         = {() -> UILabel in
                let label            = UILabel(frame: CGRect(x: spacer, y: (view.frame.height/2) - 40, width: view.frame.width - (spacer*2), height:46))
                label.textAlignment  = .center
                label.font           = UIFont.systemFont(ofSize: 34 , weight: UIFont.Weight.bold)
                label.textColor      = UIColor(red: 0/255, green: 67/255, blue: 148/255, alpha: 1.0)
                label.text           = "クラウド保育園"
                label.alpha          = 1.0
                return label
            }()
            view.addSubview( self.titleLabel! )

            
            let buttonElement               = {() -> UIButton in
                let button                  = UIButton(frame: CGRect(x: view.frame.width - (spacer + buttonSize), y: view.frame.height - (spacer + buttonSize), width: buttonSize, height: buttonSize))
                button.backgroundColor      = UIColor(red: 255/255, green: 170/255, blue: 187/255, alpha: 1.0)
                button.layer.cornerRadius   = 30.0
                button.alpha                = 1
                button.setImage( UIImage(named:"camera"), for: .normal )
                button.imageEdgeInsets      = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
                button.layer.shadowColor    = UIColor(red: 33/255, green: 33/255, blue: 33/255, alpha: 1.0).cgColor
                button.layer.shadowOffset   = CGSize(width: 0, height: 4)
                button.layer.shadowRadius   = 4.0
                button.layer.shadowOpacity  = 0.4
                button.adjustsImageWhenHighlighted = false

                let tapGestureRecognizer    = UITapGestureRecognizer(target: self, action: #selector(self.uploadImage(withGestureRecognizer:)))
                button.addGestureRecognizer( tapGestureRecognizer )

                return button
            }()
            view.addSubview( buttonElement )
            
            return view
        }()
        self.addSubview( self.descriptionSubView )
        
        //self.addTagView()
        
        let buttonElement               = {() -> UIButton in
            let button                  = UIButton(frame: CGRect(x: (self.frame.width/2)-(buttonSize/2) , y: self.frame.height - 100, width: buttonSize, height: buttonSize))
            button.backgroundColor      = UIColor(red: 255/255, green: 170/255, blue: 187/255, alpha: 1.0)
            button.layer.cornerRadius   = 30.0
            button.alpha                = 1
            button.setImage( UIImage(named:"baby"), for: .normal )
            button.imageEdgeInsets      = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
            button.layer.shadowColor    = UIColor(red: 33/255, green: 33/255, blue: 33/255, alpha: 1.0).cgColor
            button.layer.shadowOffset   = CGSize(width: 0, height: 4)
            button.layer.shadowRadius   = 4.0
            button.layer.shadowOpacity  = 0.4
            button.adjustsImageWhenHighlighted = false
            
            let tapGestureRecognizer    = UITapGestureRecognizer(target: self, action: #selector(self.showDetailPage(withGestureRecognizer:)))
            button.addGestureRecognizer( tapGestureRecognizer )
            
            return button
        }()
        self.addSubview( buttonElement )
        
        //self.addTagView()
    }
    
    func addTagView() {
        let spacer:CGFloat          = 30.0
        let buttonSize:CGFloat      = 60.0
        let documentWidth           = self.frame.width
        let documentHeight          = self.frame.height
        
        self.tagSubview?.removeFromSuperview()
        
        self.tagSubview     = {() -> UIView in
            self.photoRecordId? = ""
            self.tagList        = []
            self.userDailyEvent = nil
            
            let view                = UIView( frame:CGRect(x: 0, y: documentHeight/4.2, width: documentWidth - (spacer*2), height: documentHeight * 0.3) )
            view.backgroundColor    = UIColor(red: 100/255, green: 100/255, blue: 70/255, alpha: 0.0)
            view.layer.cornerRadius = 24.0
            view.clipsToBounds = true
            
//            let labelElement         = {() -> UILabel in
//                let label            = UILabel(frame: CGRect(x: spacer, y: 24, width: view.frame.width - (spacer*2), height:46))
//                label.textAlignment  = .left
//                label.font           = UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.light)
//                label.textColor      = UIColor(red: 220/255, green: 218/255, blue: 226/255, alpha: 1.0)
//                label.text           = "Hello"
//                label.alpha          = 1.0
//                return label
//            }()
//            view.addSubview( labelElement )
            
            let buttonElement               = {() -> UIButton in
                let button                  = UIButton(frame: CGRect(x: 20 , y: view.frame.height - 40, width: 50, height: 30))
                button.backgroundColor      = normalColor
                button.layer.cornerRadius   = 4
                button.setTitle("ご飯", for: .normal)
                button.titleLabel?.font     = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.bold)
                button.setTitleColor(UIColor(red: 0/255, green: 67/255, blue: 148/255, alpha: 1.0), for: .normal)
                button.alpha                = 1
                button.layer.shadowColor    = UIColor(red: 33/255, green: 33/255, blue: 33/255, alpha: 1.0).cgColor
                button.layer.shadowOffset   = CGSize(width: 0, height: 4)
                button.layer.shadowRadius   = 4.0
                button.layer.shadowOpacity  = 0.5
                button.adjustsImageWhenHighlighted = false
                
                let tapGestureRecognizer    = UITapGestureRecognizer(target: self, action: #selector(self.selectButton(withGestureRecognizer:)))
                button.addGestureRecognizer( tapGestureRecognizer )
                
                return button
            }()
            view.addSubview( buttonElement )
            
            let buttonElement2               = {() -> UIButton in
                let button                  = UIButton(frame: CGRect(x: 20 + 50  + (10 * 1 ) , y: view.frame.height - 40, width: 50, height: 30))
                button.backgroundColor      = normalColor
                button.layer.cornerRadius   = 4
                button.setTitle("遊び", for: .normal)
                button.titleLabel?.font     = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.bold)
                button.setTitleColor(UIColor(red: 0/255, green: 67/255, blue: 148/255, alpha: 1.0), for: .normal)
                button.alpha                = 1
                button.layer.shadowColor    = UIColor(red: 33/255, green: 33/255, blue: 33/255, alpha: 1.0).cgColor
                button.layer.shadowOffset   = CGSize(width: 0, height: 4)
                button.layer.shadowRadius   = 4.0
                button.layer.shadowOpacity  = 0.5
                button.adjustsImageWhenHighlighted = false
                
                let tapGestureRecognizer    = UITapGestureRecognizer(target: self, action: #selector(self.selectButton(withGestureRecognizer:)))
                button.addGestureRecognizer( tapGestureRecognizer )
                
                return button
            }()
            view.addSubview( buttonElement2 )
            
            let buttonElement3               = {() -> UIButton in
                let button                  = UIButton(frame: CGRect(x: 20 + (50 * 2)  + 20 , y: view.frame.height - 40, width: 50, height: 30))
                button.backgroundColor      = normalColor
                button.layer.cornerRadius   = 4
                button.setTitle("怪我", for: .normal)
                button.titleLabel?.font     = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.bold)
                button.setTitleColor(UIColor(red: 0/255, green: 67/255, blue: 148/255, alpha: 1.0), for: .normal)
                button.alpha                = 1
                button.layer.shadowColor    = UIColor(red: 33/255, green: 33/255, blue: 33/255, alpha: 1.0).cgColor
                button.layer.shadowOffset   = CGSize(width: 0, height: 4)
                button.layer.shadowRadius   = 4.0
                button.layer.shadowOpacity  = 0.5
                button.adjustsImageWhenHighlighted = false
                
                let tapGestureRecognizer    = UITapGestureRecognizer(target: self, action: #selector(self.selectButton(withGestureRecognizer:)))
                button.addGestureRecognizer( tapGestureRecognizer )
                
                return button
            }()
            view.addSubview( buttonElement3 )
            
            let buttonElementTag1           = {() -> UIButton in
                let button                  = UIButton(frame: CGRect(x: 20 , y: view.frame.height - 80, width: 80, height: 30))
                button.backgroundColor      = normalColor
                button.layer.cornerRadius   = 4
                button.setTitle("タグ", for: .normal)
                button.titleLabel?.font     = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.bold)
                button.setTitleColor(UIColor(red: 0/255, green: 67/255, blue: 148/255, alpha: 1.0), for: .normal)
                button.alpha                = 1
                button.layer.shadowColor    = UIColor(red: 33/255, green: 33/255, blue: 33/255, alpha: 1.0).cgColor
                button.layer.shadowOffset   = CGSize(width: 0, height: 4)
                button.layer.shadowRadius   = 4.0
                button.layer.shadowOpacity  = 0.5
                button.adjustsImageWhenHighlighted = false
                
                let tapGestureRecognizer    = UITapGestureRecognizer(target: self, action: #selector(self.selectButtonTag(withGestureRecognizer:)))
                button.addGestureRecognizer( tapGestureRecognizer )
                
                return button
            }()
            view.addSubview( buttonElementTag1 )
            
            let buttonElementTag2           = {() -> UIButton in
                let button                  = UIButton(frame: CGRect(x: 20 + 80 + 10 , y: view.frame.height - 80, width: 80, height: 30))
                button.backgroundColor      = normalColor
                button.layer.cornerRadius   = 4
                button.setTitle("タグ", for: .normal)
                button.titleLabel?.font     = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.bold)
                button.setTitleColor(UIColor(red: 0/255, green: 67/255, blue: 148/255, alpha: 1.0), for: .normal)
                button.alpha                = 1
                button.layer.shadowColor    = UIColor(red: 33/255, green: 33/255, blue: 33/255, alpha: 1.0).cgColor
                button.layer.shadowOffset   = CGSize(width: 0, height: 4)
                button.layer.shadowRadius   = 4.0
                button.layer.shadowOpacity  = 0.5
                button.adjustsImageWhenHighlighted = false
                
                let tapGestureRecognizer    = UITapGestureRecognizer(target: self, action: #selector(self.selectButtonTag(withGestureRecognizer:)))
                button.addGestureRecognizer( tapGestureRecognizer )
                
                return button
            }()
            view.addSubview( buttonElementTag2 )
            
            let buttonElementTag3           = {() -> UIButton in
                let button                  = UIButton(frame: CGRect(x: 20 + (80 * 2) + (10*2) , y: view.frame.height - 80, width: 80, height: 30))
                button.backgroundColor      = normalColor
                button.layer.cornerRadius   = 4
                button.setTitle("タグ", for: .normal)
                button.titleLabel?.font     = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.bold)
                button.setTitleColor(UIColor(red: 0/255, green: 67/255, blue: 148/255, alpha: 1.0), for: .normal)
                button.alpha                = 1
                button.layer.shadowColor    = UIColor(red: 33/255, green: 33/255, blue: 33/255, alpha: 1.0).cgColor
                button.layer.shadowOffset   = CGSize(width: 0, height: 4)
                button.layer.shadowRadius   = 4.0
                button.layer.shadowOpacity  = 0.5
                button.adjustsImageWhenHighlighted = false
                
                let tapGestureRecognizer    = UITapGestureRecognizer(target: self, action: #selector(self.selectButtonTag(withGestureRecognizer:)))
                button.addGestureRecognizer( tapGestureRecognizer )
                
                return button
            }()
            view.addSubview( buttonElementTag3 )
            
            return view
        }()
        self.descriptionSubView.addSubview( self.tagSubview )
        self.descriptionSubView.sendSubviewToBack(self.tagSubview)
    }
    
    @objc func selectButton( withGestureRecognizer event: UITapGestureRecognizer ) {
        let button                          = event.view as! UIButton
        if button.backgroundColor == self.normalColor {
            button.backgroundColor = self.selectedColor
            
            self.tagList?.append( button.currentTitle! )
        } else {
            button.backgroundColor = self.normalColor
            
            if let index = self.tagList!.firstIndex(of: button.currentTitle!) {
                self.tagList!.remove(at: index)
            } else {
                // not found
            }
        }
        
        ApexRemote.instance.addTag(recordId: self.userDailyEvent!, tags: self.tagList!) { isSuccess, data in
            print( isSuccess, data )
        }
    }
    
    @objc func selectButtonTag( withGestureRecognizer event: UITapGestureRecognizer ) {
        let button                          = event.view as! UIButton
        if button.backgroundColor == self.normalColor {
            NFCReader.instance.scan(message: "園児の名札をスキャン") { results in
                for( _, result ) in results.enumerated() {
                    let payload = result.value(forKey: "payload") as! String
                    let recordId = Utility.shared.DataToString(data: Utility.shared.Base64ToData(base64: payload)).substring(from: 3, to: payload.count)

                    ApexRemote.instance.getChildInfo(childRecordId: recordId) { isSuccess, data in
                        if isSuccess {
                            let record  = data!.value(forKey: "record") as! NSDictionary
                            let recordId = record.value(forKey: "Id") as! String
                            let name    = (record.value(forKey: "Nickname__c") as? String)?.decodingUnicodeCharacters ?? "--"
                            button.setTitle(name, for: .normal)
                            button.backgroundColor = self.selectedColor
                            
                            //ApexRemote.instance.addChildTag(recordId: recordId, photoId: self.photoRecordId!) { isSuccess, data in
                            //    print( isSuccess, data  )
                            //}
//                            let childRec = ["Id": record.value(forKey: "Id" as! String), "name": name] as NSDictionary
//                            for( _, chi ) in self.childList!.enumerated() {
//                                let chidic = chi as NSDictionary
//                                if chidic.value(forKey: "name") as! String == name {
//
//                                }
//                            }
                        }
                    }
                }
            } onFail: { errorMessage in }
            
        } else {
            button.setTitle("タグ", for: .normal)
            button.backgroundColor = self.normalColor
        }
    }
    
    @objc func uploadImage( withGestureRecognizer event: UITapGestureRecognizer ) {
        self.takePhoto { isSuccess, data, imageFile in
            if isSuccess {
                self.addTagView()

                self.photoRecordId = data!.value(forKey: "photorecordId") as! String
                self.userDailyEvent = data!.value(forKey: "ude") as? String
                
                self.takenImage?.removeFromSuperview()
                self.titleLabel?.removeFromSuperview()
                
                self.takenImage                = {() -> UIImageView in
                    let imageView               = UIImageView(image: imageFile?.getUIImage()!)
                    imageView.frame             = CGRect(x: 0, y: 0, width: self.descriptionSubView.frame.width, height: self.descriptionSubView.frame.height)
                    imageView.contentMode       = .scaleAspectFill
                    imageView.backgroundColor   = .black
                    return imageView
                }()
                self.descriptionSubView.addSubview(self.takenImage!)
                self.descriptionSubView.sendSubviewToBack(self.takenImage!)
            }
        }
    }
    
    @objc func showDetailPage( withGestureRecognizer event: UITapGestureRecognizer ) {
        let button                          = event.view as! UIButton
        
        let keyframeAnimationOptions        = UIView.KeyframeAnimationOptions(rawValue: UIView.AnimationOptions.curveEaseInOut.rawValue)
        UIView.animateKeyframes(withDuration: 0.4, delay: 0.0, options: [keyframeAnimationOptions], animations: {
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.2, animations: {
                button.transform            = CGAffineTransform(scaleX: 0.9, y: 0.9)
                button.layer.shadowOpacity  = 0.0
            })
            UIView.addKeyframe(withRelativeStartTime: 0.2, relativeDuration: 0.2, animations: {
                button.transform            = CGAffineTransform(scaleX: 1.0, y: 1.0)
                button.layer.shadowOpacity  = 1.0
            })
        }, completion: {finsihed in self.openDetailView() } )
    }
    
    private func openDetailView() {
        Utility.shared.execute(after: 0.3) {
            Utility.shared.showloading()
        }

        showChildCard { isSuccess, childData in
            if isSuccess {
                let record  = childData!.value(forKey: "record") as! NSDictionary

                let Icon__r = record.value(forKey: "Icon__r") as! NSDictionary
                let ImageFileID__c = Icon__r.value(forKey: "ImageFileID__c") as! String

                ApexRemote.instance.getImage(recordId: ImageFileID__c) { isSuccess, base64data in
                    if isSuccess {
                        let base64 = base64data!.value(forKey: "base64") as! String
                        let data = Utility.shared.Base64ToData(base64: base64)
                        do {
                            Utility.shared.hideLoading()

                            let imageFile = try ImageFile( fileId: File.generateID(), uiimage: UIImage(data: data)!)
                            let studentView      = StudentView( frame: self.superview!.frame )
                            studentView.delegate = self //MainView: DetailViewDelegate
                            studentView.setup(info: record, imageFile: imageFile)

                            self.superview!.addSubview( studentView )

                            UIView.animate(withDuration: 1.0, delay: 0, options: [.curveEaseInOut], animations: {
                                self.descriptionSubView.transform   = CGAffineTransform(scaleX: 0.9, y: 0.9)
                            }, completion: { finished in })

                            UIView.animate(withDuration: 1.5, delay: 0, options: [.curveEaseInOut], animations: {
                                self.imageElement.transform         = CGAffineTransform(scaleX: 1.5, y: 1.5)
                            }, completion: { finished in })
                        } catch _ as NSError {

                        }
                    }
                }
            }
        }
    }
    
    func showChildCard( callback: ((Bool, NSDictionary?)->())?=nil ) {
        NFCReader.instance.scan(message: "園児の名札をスキャン") { results in
            for( _, result ) in results.enumerated() {
                let payload = result.value(forKey: "payload") as! String
                let recordId = Utility.shared.DataToString(data: Utility.shared.Base64ToData(base64: payload)).substring(from: 3, to: payload.count)

                ApexRemote.instance.getChildInfo(childRecordId: recordId) { isSuccess, data in
                    if isSuccess {
                        callback?( true, data )
                    }
                }
            }
        } onFail: { errorMessage in
            print( "XXXX", errorMessage )
            Utility.shared.hideLoading()
        }
    }
    
    func takePhoto( callback: ((Bool, NSDictionary?, ImageFile?)->())?=nil ) {
        Utility.shared.execute(after: 0.3) {
            Utility.shared.showloading()
        }
        
        Photos.takePicture(type: "CAMERA") { imageFile in
            //let option = ["quality": 99, "width":1080, "height":1920] as! NSObject
            let option = ["quality": 50, "width":1080/4, "height":1920/4] as! NSObject
            imageFile.resize(option: option) { resized in
                imageFile.uploadFile(base64: Utility.shared.DataToBase64(data: resized)) { isSuccess, data in
                    if isSuccess {
                        let contentvid    = data!
                        ApexRemote.instance.attachImage(contentvid: contentvid) { isSuccess, _data in
                            if isSuccess {
                                callback?( true, _data, imageFile )
                                Utility.shared.hideLoading()
                            }
                        }
                    }
                }
            } onFail: { errorMessage in
                print(errorMessage)
                Utility.shared.hideLoading()
            }
        } onFail: { errorMessage in
            print( errorMessage )
            callback?( false, nil, nil )
            Utility.shared.hideLoading()
        }
    }
    
    func closedDetailView() {
        UIView.animate(withDuration: 1.0, delay: 0, options: [.curveEaseInOut], animations: {
            self.descriptionSubView.transform    = CGAffineTransform(scaleX: 1.0, y: 1.0)
        }, completion: { finished in })
        
        UIView.animate(withDuration: 1.5, delay: 0, options: [.curveEaseInOut], animations: {
            self.imageElement.transform          = CGAffineTransform(scaleX: 1.0, y: 1.0)
        }, completion: { finished in })
    }
    
    
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
