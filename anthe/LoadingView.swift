//
//  LoadingView.swift
//  anthe
//
//  Created by Mart Ryan Civil on 2021/12/12.
//

import Foundation
import UIKit

class LoadingView: UIView {

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
        let documentWidth       = self.frame.width
        let documentHeight      = self.frame.height
        self.toFrame            = CGRect(x: spacer, y: (documentHeight/2) - ((documentHeight * 0.8)/2), width: documentWidth - (spacer*2), height: documentHeight * 0.8)
        //self.startFrame         = CGRect(x: self.toFrame.origin.x, y: documentHeight, width: self.toFrame.size.width, height: self.toFrame.size.height)
        //self.endFrame           = CGRect(x: self.toFrame.origin.x, y: -documentHeight, width: self.toFrame.size.width, height: self.toFrame.size.height)
        
        self.blurElement        = {() -> UIVisualEffectView in
            let blur            = UIVisualEffectView( frame:self.frame )
            blur.effect         = UIBlurEffect( style: .dark )
            blur.alpha          = 0.0
            return blur
        }()
        self.addSubview( self.blurElement )
        DispatchQueue.main.asyncAfter(deadline: .now())  {
            UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut], animations: {
                self.blurElement.alpha = 1.0
            }, completion: { finished in })
        }
        
        self.detailWrapperElement       = {() -> UIView in
            let view                    = UIView( frame: self.toFrame )
            view.backgroundColor        = UIColor(red: 55/255, green: 50/255, blue: 70/255, alpha: 0.0)
            view.layer.cornerRadius     = 24.0
            view.clipsToBounds          = true
            view.alpha                  = 0.0
            
            let labelElement         = {() -> UILabel in
                let label            = UILabel(frame: CGRect(x: 0, y: (view.frame.height/2) - 23, width: view.frame.width, height:46))
                label.textAlignment  = .center
                label.font           = UIFont.systemFont(ofSize: 32, weight: UIFont.Weight.light)
                label.textColor      = UIColor(red: 220/255, green: 218/255, blue: 226/255, alpha: 1.0)
                label.text           = "処理中"
                label.alpha          = 1.0
                return label
            }()
            view.addSubview( labelElement )
            
            return view
        }()
        self.addSubview( self.detailWrapperElement )
        
        
        DispatchQueue.main.asyncAfter(deadline: .now())  {
            UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut], animations: {
                self.detailWrapperElement.alpha = 1.0
            }, completion: { finished in })
        }
    }
    
    public func closeDetailViewPage(finished: Bool) {
        let keyframeAnimationOptions            = UIView.KeyframeAnimationOptions(rawValue: UIView.AnimationOptions.curveEaseInOut.rawValue)
        UIView.animateKeyframes(withDuration: 0.3, delay: 0.0, options: [keyframeAnimationOptions], animations: {
            self.blurElement.alpha          = 0.0
            self.detailWrapperElement.alpha = 0.0
        }, completion: { finished in
            self.removeFromSuperview()
        })

        self.delegate?.closedDetailView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//extension UIViewController {
//
//    static let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
//
//    func startLoading() {
//        let activityIndicator = UIViewController.activityIndicator
//        activityIndicator.center = self.view.center
//        activityIndicator.hidesWhenStopped = true
//        activityIndicator.style = .gray
//        DispatchQueue.main.async {
//            self.view.addSubview(activityIndicator)
//        }
//        activityIndicator.startAnimating()
//        UIApplication.shared.beginIgnoringInteractionEvents()
//    }
//
//    func stopLoading() {
//        let activityIndicator = UIViewController.activityIndicator
//        DispatchQueue.main.async {
//            activityIndicator.stopAnimating()
//            activityIndicator.removeFromSuperview()
//        }
//        UIApplication.shared.endIgnoringInteractionEvents()
//    }
//}
