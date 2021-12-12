//
//  DetailView.swift
//  blackhole
//
//  Created by Mart Civil on 2019/04/15.
//  Copyright © 2019 salesforce.com. All rights reserved.
//
import UIKit

class StudentView: UIView {
    private var detailWrapperElement    : UIView!
    private var blurElement             : UIVisualEffectView!
    private var startFrame              : CGRect!
    private var toFrame                 : CGRect!
    private var endFrame                : CGRect!
    public var delegate                 : DetailViewDelegate?
    
    override init( frame: CGRect ) {
        super.init( frame: frame )
    }
    
    public func setup( info:NSDictionary, imageFile: ImageFile ) {
        let spacer:CGFloat      = 30.0
        let buttonSize:CGFloat  = 60.0
        let documentWidth       = self.frame.width
        let documentHeight      = self.frame.height
        self.toFrame            = CGRect(x: spacer, y: (documentHeight/2) - ((documentHeight * 0.8)/2), width: documentWidth - (spacer*2), height: documentHeight * 0.8)
        self.startFrame         = CGRect(x: self.toFrame.origin.x, y: documentHeight, width: self.toFrame.size.width, height: self.toFrame.size.height)
        self.endFrame           = CGRect(x: self.toFrame.origin.x, y: -documentHeight, width: self.toFrame.size.width, height: self.toFrame.size.height)
        
        self.blurElement        = {() -> UIVisualEffectView in
            let blur            = UIVisualEffectView( frame:self.frame )
            blur.effect         = UIBlurEffect( style: .dark )
            blur.alpha          = 0.0
            return blur
        }()
        self.addSubview( self.blurElement )
        DispatchQueue.main.asyncAfter(deadline: .now())  {
            UIView.animate(withDuration: 0.7, delay: 0, options: [.curveEaseInOut], animations: {
                self.blurElement.alpha = 1.0
            }, completion: { finished in })
        }
        
        self.detailWrapperElement       = {() -> UIView in
            let view                    = UIView( frame: self.startFrame )
            view.backgroundColor        = UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 1.0)
            view.layer.cornerRadius     = 24.0
            view.clipsToBounds          = true
            
            let imageElement                = {() -> UIImageView in
                let imageView               = UIImageView(image: imageFile.getUIImage()!)
                imageView.frame             = CGRect(x: 0, y: 0, width: view.frame.width, height: 200)
                imageView.contentMode       = .scaleAspectFit
                imageView.backgroundColor   = .black
                return imageView
            }()
            view.addSubview( imageElement )
            
            let labelElement         = {() -> UILabel in
                let label            = UILabel(frame: CGRect(x: spacer, y: imageElement.frame.height, width: view.frame.width - (spacer*2), height:46))
                label.textAlignment  = .left
                label.font           = UIFont.systemFont(ofSize: 32, weight: UIFont.Weight.bold)
                label.textColor      = UIColor(red: 0/255, green: 67/255, blue: 148/255, alpha: 1.0)
                label.text           = (info.value(forKey: "Nickname__c") as? String)?.decodingUnicodeCharacters ?? "--"
                label.alpha          = 1.0
                return label
            }()
            view.addSubview( labelElement )
            
            let nicknameLabelElement = {() -> UILabel in
                let label            = UILabel(frame: CGRect(x: spacer, y: labelElement.frame.origin.y + (labelElement.frame.height/2) + 6, width: view.frame.width - (spacer*2), height:46))
                label.textAlignment  = .left
                label.font           = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.semibold)
                label.textColor      = UIColor(red: 0/255, green: 67/255, blue: 148/255, alpha: 1.0)
                label.text           = (info.value(forKey: "Name") as? String)?.decodingUnicodeCharacters ?? "--"
                label.alpha          = 1.0
                return label
            }()
            view.addSubview( nicknameLabelElement )
            
            let infoPos = nicknameLabelElement.frame.origin.y + 60
            let infoLabelElement1 = {() -> UILabel in
                let label            = UILabel(frame: CGRect(x: spacer, y: infoPos, width: view.frame.width - (spacer*2), height:46))
                label.textAlignment  = .left
                label.font           = UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.medium)
                label.textColor      = UIColor(red: 0/255, green: 67/255, blue: 148/255, alpha: 1.0)
                label.text           = "生年月日"
                label.alpha          = 1.0
                return label
            }()
            view.addSubview( infoLabelElement1 )
            
            let infoLabelElement2 = {() -> UILabel in
                let label            = UILabel(frame: CGRect(x: spacer, y: infoPos + (30 * 1), width: view.frame.width - (spacer*2), height:46))
                label.textAlignment  = .left
                label.font           = UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.medium)
                label.textColor      = UIColor(red: 0/255, green: 67/255, blue: 148/255, alpha: 1.0)
                label.text           = "性別"
                label.alpha          = 1.0
                return label
            }()
            view.addSubview( infoLabelElement2 )
            
            let infoLabelElement3 = {() -> UILabel in
                let label            = UILabel(frame: CGRect(x: spacer, y: infoPos + (30 * 2), width: view.frame.width - (spacer*2), height:46))
                label.textAlignment  = .left
                label.font           = UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.medium)
                label.textColor      = UIColor(red: 0/255, green: 67/255, blue: 148/255, alpha: 1.0)
                label.text           = "入園日"
                label.alpha          = 1.0
                return label
            }()
            view.addSubview( infoLabelElement3 )
            
            let infoLabelElement4 = {() -> UILabel in
                let label            = UILabel(frame: CGRect(x: spacer, y: infoPos + (30 * 3), width: view.frame.width - (spacer*2), height:46))
                label.textAlignment  = .left
                label.font           = UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.medium)
                label.textColor      = UIColor(red: 0/255, green: 67/255, blue: 148/255, alpha: 1.0)
                label.text           = "血液型"
                label.alpha          = 1.0
                return label
            }()
            view.addSubview( infoLabelElement4 )
            
            let infoLabelElement5 = {() -> UILabel in
                let label            = UILabel(frame: CGRect(x: spacer, y: infoPos + (30 * 4), width: view.frame.width - (spacer*2), height:46))
                label.textAlignment  = .left
                label.font           = UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.medium)
                label.textColor      = UIColor(red: 0/255, green: 67/255, blue: 148/255, alpha: 1.0)
                label.text           = "アレルギー"
                label.alpha          = 1.0
                return label
            }()
            view.addSubview( infoLabelElement5 )
            
            let infoLabelElement6 = {() -> UILabel in
                let label            = UILabel(frame: CGRect(x: spacer, y: infoPos + (30 * 5), width: view.frame.width - (spacer*2), height:46))
                label.textAlignment  = .left
                label.font           = UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.medium)
                label.textColor      = UIColor(red: 0/255, green: 67/255, blue: 148/255, alpha: 1.0)
                label.text           = "寝付き"
                label.alpha          = 1.0
                return label
            }()
            view.addSubview( infoLabelElement6 )
            
            let infoLabelElement7 = {() -> UILabel in
                let label            = UILabel(frame: CGRect(x: spacer, y: infoPos + (30 * 6), width: view.frame.width - (spacer*2), height:46))
                label.textAlignment  = .left
                label.font           = UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.medium)
                label.textColor      = UIColor(red: 0/255, green: 67/255, blue: 148/255, alpha: 1.0)
                label.text           = "排便回数"
                label.alpha          = 1.0
                return label
            }()
            view.addSubview( infoLabelElement7 )
            
            let infoLabelElement8 = {() -> UILabel in
                let label            = UILabel(frame: CGRect(x: spacer, y: infoPos + (30 * 7), width: view.frame.width - (spacer*2), height:46))
                label.textAlignment  = .left
                label.font           = UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.medium)
                label.textColor      = UIColor(red: 0/255, green: 67/255, blue: 148/255, alpha: 1.0)
                label.text           = "起床時間"
                label.alpha          = 1.0
                return label
            }()
            view.addSubview( infoLabelElement8 )
            
            let infoLabelElement9 = {() -> UILabel in
                let label            = UILabel(frame: CGRect(x: spacer, y: infoPos + (30 * 8), width: view.frame.width - (spacer*2), height:46))
                label.textAlignment  = .left
                label.font           = UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.medium)
                label.textColor      = UIColor(red: 0/255, green: 67/255, blue: 148/255, alpha: 1.0)
                label.text           = "持病歴"
                label.alpha          = 1.0
                return label
            }()
            view.addSubview( infoLabelElement9 )
            
            
            
            let valpos = spacer + (view.frame.width/2)
            let valLabelElement1 = {() -> UILabel in
                let label            = UILabel(frame: CGRect(x: valpos, y: infoPos, width: view.frame.width - (spacer*2), height:46))
                label.textAlignment  = .left
                label.font           = UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.light)
                label.textColor      = UIColor(red: 0/255, green: 67/255, blue: 148/255, alpha: 1.0)
                label.text           = info.value(forKey: "DateOfBirth__c") as? String ?? "--"
                label.alpha          = 1.0
                return label
            }()
            view.addSubview( valLabelElement1 )
            
            let valLabelElement2 = {() -> UILabel in
                let label            = UILabel(frame: CGRect(x: valpos, y: infoPos + (30 * 1), width: view.frame.width - (spacer*2), height:46))
                label.textAlignment  = .left
                label.font           = UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.light)
                label.textColor      = UIColor(red: 0/255, green: 67/255, blue: 148/255, alpha: 1.0)
                label.text           = (info.value(forKey: "Gender__c") as? String)?.decodingUnicodeCharacters ?? "--"
                label.alpha          = 1.0
                return label
            }()
            view.addSubview( valLabelElement2 )
            
            let valLabelElement3 = {() -> UILabel in
                let label            = UILabel(frame: CGRect(x: valpos, y: infoPos + (30 * 2), width: view.frame.width - (spacer*2), height:46))
                label.textAlignment  = .left
                label.font           = UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.light)
                label.textColor      = UIColor(red: 0/255, green: 67/255, blue: 148/255, alpha: 1.0)
                label.text           = (info.value(forKey: "JoinDate__c") as? String) ?? "--"
                label.alpha          = 1.0
                return label
            }()
            view.addSubview( valLabelElement3 )
            
            let valLabelElement4 = {() -> UILabel in
                let label            = UILabel(frame: CGRect(x: valpos, y: infoPos + (30 * 3), width: view.frame.width - (spacer*2), height:46))
                label.textAlignment  = .left
                label.font           = UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.light)
                label.textColor      = UIColor(red: 0/255, green: 67/255, blue: 148/255, alpha: 1.0)
                label.text           = (info.value(forKey: "BloodType__c") as? String) ?? "--"
                label.alpha          = 1.0
                return label
            }()
            view.addSubview( valLabelElement4 )
            
            let valLabelElement5 = {() -> UILabel in
                let label            = UILabel(frame: CGRect(x: valpos, y: infoPos + (30 * 4), width: view.frame.width - (spacer*2), height:46))
                label.textAlignment  = .left
                label.font           = UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.light)
                label.textColor      = UIColor(red: 0/255, green: 67/255, blue: 148/255, alpha: 1.0)
                label.text           = (info.value(forKey: "Allergies__c") as? String)?.decodingUnicodeCharacters ?? "--"
                label.alpha          = 1.0
                return label
            }()
            view.addSubview( valLabelElement5 )
            
            let valLabelElement6 = {() -> UILabel in
                let label            = UILabel(frame: CGRect(x: valpos, y: infoPos + (30 * 5), width: view.frame.width - (spacer*2), height:46))
                label.textAlignment  = .left
                label.font           = UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.light)
                label.textColor      = UIColor(red: 0/255, green: 67/255, blue: 148/255, alpha: 1.0)
                label.text           = (info.value(forKey: "SleepQuality__c") as? String)?.decodingUnicodeCharacters ?? "--"
                label.alpha          = 1.0
                return label
            }()
            view.addSubview( valLabelElement6 )
            
            let valLabelElement7 = {() -> UILabel in
                let label            = UILabel(frame: CGRect(x: valpos, y: infoPos + (30 * 6), width: view.frame.width - (spacer*2), height:46))
                label.textAlignment  = .left
                label.font           = UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.light)
                label.textColor      = UIColor(red: 0/255, green: 67/255, blue: 148/255, alpha: 1.0)
                label.text           = String(info.value(forKey: "DefecationFrequency__c") as? Int ?? 0)
                label.alpha          = 1.0
                return label
            }()
            view.addSubview( valLabelElement7 )
            
            let valLabelElement8 = {() -> UILabel in
                let label            = UILabel(frame: CGRect(x: valpos, y: infoPos + (30 * 7), width: view.frame.width - (spacer*2), height:46))
                label.textAlignment  = .left
                label.font           = UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.light)
                label.textColor      = UIColor(red: 0/255, green: 67/255, blue: 148/255, alpha: 1.0)
                label.text           = (info.value(forKey: "WakeupTime__c") as? String)?.replacingOccurrences(of: ".000Z", with: "") ?? "--"
                label.alpha          = 1.0
                return label
            }()
            view.addSubview( valLabelElement8 )
            
            let valLabelElement9 = {() -> UILabel in
                let label            = UILabel(frame: CGRect(x: valpos, y: infoPos + (30 * 8), width: view.frame.width - (spacer*2), height:46))
                label.textAlignment  = .left
                label.font           = UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.light)
                label.textColor      = UIColor(red: 0/255, green: 67/255, blue: 148/255, alpha: 1.0)
                label.text           = "あり"
                label.alpha          = 1.0
                return label
            }()
            view.addSubview( valLabelElement9 )
            
            
            
            let buttonElement               = {() -> UIButton in
                let button                  = UIButton(frame: CGRect(x: view.frame.width - (spacer + buttonSize), y: view.frame.height - (spacer + buttonSize), width: buttonSize, height: buttonSize))
                button.backgroundColor      = UIColor(red: 244/255, green: 67/255, blue: 54/255, alpha: 1.0)
                button.layer.cornerRadius   = 30.0
                button.alpha                = 1
                button.setImage(UIImage(named:"close"), for: .normal)
                button.imageEdgeInsets      = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
                button.layer.shadowColor    = UIColor(red: 33/255, green: 33/255, blue: 33/255, alpha: 1.0).cgColor
                button.layer.shadowOffset   = CGSize(width: 0, height: 4)
                button.layer.shadowRadius   = 4.0
                button.layer.shadowOpacity  = 0.4
                button.adjustsImageWhenHighlighted = false
                
                let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.closeDetailPage(withGestureRecognizer:)))
                button.addGestureRecognizer( tapGestureRecognizer )
                
                return button
            }()
            view.addSubview( buttonElement )
            
            return view
        }()
        self.addSubview( self.detailWrapperElement )
        
        DispatchQueue.main.asyncAfter(deadline: .now())  {
            UIView.animate(withDuration: 0.3, delay: 0.2, options: [.curveEaseInOut], animations: {
                self.detailWrapperElement.frame = self.toFrame
            }, completion: { finished in })
        }
    }
    
    @objc func closeDetailPage(withGestureRecognizer event: UITapGestureRecognizer ) {
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
        }, completion: closeDetailViewPage)
    }
    
    public func closeDetailViewPage(finished: Bool) {
        let keyframeAnimationOptions            = UIView.KeyframeAnimationOptions(rawValue: UIView.AnimationOptions.curveEaseInOut.rawValue)
        UIView.animateKeyframes(withDuration: 0.7, delay: 0.0, options: [keyframeAnimationOptions], animations: {
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.7, animations: {
                self.blurElement.alpha          = 0.0
            })
            UIView.addKeyframe(withRelativeStartTime: 0.2, relativeDuration: 0.3, animations: {
                self.detailWrapperElement.frame = self.endFrame
            })
        }, completion: { finished in
            self.removeFromSuperview()
        })

        self.delegate?.closedDetailView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
