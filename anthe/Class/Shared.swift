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
    
    let username        = "XXXX"
    let password        = "XXXX"
    let clientId        = "XXXXXXXXXXXXX"
    let clientSecret    = "XXXXXXXXXXXXXX"
    let link            = "https://xxxxxxx-dev-ed.my.salesforce.com"
}
