//
//  Shared.swift
//  Salesforce Hybrid
//
//  Created by Mart Civil on 2016/12/27.
//  Copyright © 2016年 salesforce.com. All rights reserved.
//

import UIKit

final class Shared: NSObject {
    static let shared = Shared() //lazy init, and it only runs once
    
    var isTest                      = false
    var isReset                     = false
    var isLocal                     = false
    var iCloudAvailable             = false
    var allowsCellularAccess        = true
    var isAppLoaded                 = false
    var statusBarShouldBeHidden     = true
    var shouldHideHomeIndicator     = false
    var local                       = "http://192.168.11.8:5000"
    var server                      = "https://luna-10.herokuapp.com"
    var DeviceID                    = UIDevice.current.identifierForVendor!.uuidString
    var statusBarAnimation:UIStatusBarAnimation = .slide
    var statusBarStyle:UIStatusBarStyle = .lightContent
    var UIApplication:UIApplication!
    var ViewController:ViewController!
    var customURLScheme:URL?
    var checkAppPermissionsAction:((Bool)->())?
    var pushNotification:[AnyHashable : Any]?
    var access_token:String?
    
    let username        = "admin@kenchanayo202112.demo"
    let password        = "kenchanayo2021"
    let clientId        = "3MVG95mg0lk4batglb1jjklLcg.ElOOcs_JHJnkCIfhUcnz6x.EFizSSJbCfzwll430lBIb38_nGkaf.qVf0Q"
    let clientSecret    = "A8060E39956499AD7190F3E310B7D7C922884A2940A2BC99B3D24A4021DA6011"
    let link            = "https://kenchanayo202112demo-dev-ed.my.salesforce.com"
}
