//
//  DetailView.swift
//  blackhole
//
//  Created by Mart Civil on 2019/04/15.
//  Copyright © 2019 salesforce.com. All rights reserved.
//
import UIKit

class DetailView: UIView {
    private var detailWrapperElement    : UIView!
    private var blurElement             : UIVisualEffectView!
    private var startFrame              : CGRect!
    private var toFrame                 : CGRect!
    private var endFrame                : CGRect!
    public var delegate                 : DetailViewDelegate?
    
    override init( frame: CGRect ) {
        super.init( frame: frame )
    }
    
    public func setup() {
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
            view.backgroundColor        = UIColor(red: 55/255, green: 50/255, blue: 70/255, alpha: 1.0)
            view.layer.cornerRadius     = 24.0
            view.clipsToBounds          = true
            
            let imageElement                = {() -> UIImageView in
                let imageView               = UIImageView(image: UIImage(named: "redshift"))
                imageView.frame             = CGRect(x: 0, y: 0, width: view.frame.width, height: 200)
                imageView.contentMode       = .scaleAspectFit
                imageView.backgroundColor   = .black
                return imageView
            }()
            view.addSubview( imageElement )
            
            let textViewElement             = {()-> UITextView in
                let textView                = UITextView(frame: CGRect(x: spacer, y: imageElement.frame.height, width: view.frame.width - ( spacer * 2 ), height: view.frame.height - (imageElement.frame.height + (spacer*2)  )))
                textView.isEditable         = false
                textView.backgroundColor    = UIColor(white: 1.0, alpha: 0)
                textView.font               = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.ultraLight)
                textView.textAlignment      = .justified
                textView.textColor          = UIColor(red: 111/255, green: 107/255, blue: 127/255, alpha: 1.0)
                textView.text               = """
                Observations made with ESO's Very Large Telescope have for the first time revealed the effects predicted by Einstein's general relativity on the motion of a star passing through the extreme gravitational field near the supermassive black hole in the centre of the Milky Way. This long-sought result represents the climax of a 26-year-long observation campaign using ESO's telescopes in Chile.
                
                Obscured by thick clouds of absorbing dust, the closest supermassive black hole to the Earth lies 26 000 light-years away at the centre of the Milky Way. This gravitational monster, which has a mass four million times that of the Sun, is surrounded by a small group of stars orbiting around it at high speed. This extreme environment—the strongest gravitational field in our galaxy—makes it the perfect place to explore gravitational physics, and particularly to test Einstein's general theory of relativity.
                
                New infrared observations from the exquisitely sensitive GRAVITY, SINFONI and NACO instruments on ESO's Very Large Telescope (VLT) have now allowed astronomers to follow one of these stars, called S2, as it passed very close to the black hole during May 2018. At the closest point this star was at a distance of less than 20 billion kilometres from the black hole and moving at a speed in excess of 25 million kilometres per hour—almost three percent of the speed of light.
                
                The new measurements clearly reveal an effect called gravitational redshift. Light from the star is stretched to longer wavelengths by the very strong gravitational field of the black hole. And the change in the wavelength of light from S2 agrees precisely with that predicted by Einstein's theory of general relativity. This is the first time that this deviation from the predictions of the simpler Newtonian theory of gravity has been observed in the motion of a star around a supermassive black hole.
                """
                textView.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 500), for: NSLayoutConstraint.Axis.vertical)
                return textView
            }()
            view.addSubview( textViewElement )
            
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
                button.layer.shadowOpacity  = 1.0
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
