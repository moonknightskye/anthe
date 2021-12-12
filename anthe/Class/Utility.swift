//
//  Utility.swift
//  Salesforce Hybrid
//
//  Created by Mart Civil on 2016/12/27.
//  Copyright © 2016年 salesforce.com. All rights reserved.
//

import UIKit
import WebKit
import CoreData
import ARKit


public enum UtilityError: Error {
    case NOTIFICATION_NOT_PERMITTED
    case UNKNOWN
}
extension UtilityError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .NOTIFICATION_NOT_PERMITTED:
            return NSLocalizedString("Local Notification not permitted", comment: "Error")
        case .UNKNOWN:
            return NSLocalizedString("Unknown Error", comment: "Error")
        }
    }
}

final class Apollo11: NSObject {
    private static var counter = 0
    
    static func alert(message:String, onOK:(()->())?=nil, onCancel:(()->())?=nil ) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            onOK?()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
            onCancel?()
        }))
        Shared.shared.ViewController.present(alert, animated: true, completion: nil)
    }
    
    static func generateID() -> Int {
        Apollo11.counter+=1
        return Apollo11.counter
    }
    
    static func Error( code:Any? = -1, message: String ) -> NSError {
        let _code = code as? Int ?? -1
        return NSError(domain: "", code: _code, userInfo: [ NSLocalizedDescriptionKey: message])
    }
}
class Utility: NSObject {
    static let shared = Utility()
    
//    func showStatusBar() {
//        UIApplication.shared.isStatusBarHidden = false
//    }
//    func hideStatusBar() {
//        UIApplication.shared.isStatusBarHidden = true
//    }
    func openSettings() {
        UIApplication.shared.open(URL(string: "App-Prefs:root=General")!, options: [:], completionHandler: nil)
    }
    
    func execute( after:Double, callback: @escaping (()->())) {
        DispatchQueue.main.asyncAfter(deadline: .now() + after ) {
            callback()
        }
    }
    
    func waitUntil(forEvery:Double=0.3, callback: @escaping (()->(Bool))) {
        Timer.scheduledTimer(withTimeInterval: forEvery, repeats: true) { timer in
            if( callback() ) {
                timer.invalidate()
            }
        }
    }
    
    func alert(message:String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            switch action.style{
            case .default:
                print("default")
                
            case .cancel:
                print("cancel")
                
            case .destructive:
                print("destructive")
                
            @unknown default:
                break
        }}))
        DispatchQueue.main.async {
            Shared.shared.ViewController.present(alert, animated: true, completion: nil)
        }
    }
    
    func statusBarHeight() -> CGFloat {
        guard let statusBarSize = Shared.shared.ViewController.view.window?.windowScene?.statusBarManager?.statusBarFrame.size else {
            return 0
        }
        return Swift.min(statusBarSize.width, statusBarSize.height)
    }
    
//    func getContext () -> NSManagedObjectContext {
//        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
//    }
    
    func dictionaryToJSON( dictonary:NSDictionary )-> String {
        var allInfoJSONString: String?
        do {
            let allInfoJSON = try JSONSerialization.data(withJSONObject: dictonary, options: JSONSerialization.WritingOptions(rawValue: 0))
            allInfoJSONString = (NSString(data: allInfoJSON, encoding: String.Encoding.utf8.rawValue)! as String).replacingOccurrences(of: "\'", with: "%27")
            //allInfoJSONString = (NSString(data: allInfoJSON, encoding: String.Encoding.utf8.rawValue)! as String).replacingOccurrences(of: "\"", with: "%22")
            //.replace(/'/g, "%27")
        } catch let error as NSError {
            print(error)
        }
        return allInfoJSONString!
    }
    func boundsToDictionary(bounds:CGRect) -> NSDictionary {
        return ["x":bounds.origin.x, "y":bounds.origin.y, "width":bounds.size.width, "height":bounds.size.height]
    }
    
    func extractInfo( statement:String ) -> [String: Any] {
        var result = [String: [String:[Any]]]()
        do {
            let populate = { (target: inout[String:[Any]], label: String, value: Any?) -> () in
                if( value != nil ) {
                    if( target[label] == nil ) {
                        target[label] = []
                    }
                    target[label]!.append(value!)
                }
            }
            let detector = try NSDataDetector(types: NSTextCheckingAllTypes)
            let range = NSRange(statement.startIndex..<statement.endIndex, in: statement)
            detector.enumerateMatches(in: statement,
                                      options: [],
                                      range: range) { (match, flags, _) in
                guard let match = match else { return }

                switch match.resultType {
                case .date:
                    if( result["date"] == nil) {
                        result["date"] = [String: [Any]]()
                    }
                    populate( &result["date"]!, "date", match.date )
                    populate( &result["date"]!, "timeZone", match.timeZone )
                    populate( &result["date"]!, "duration", match.duration )
                case .address:
                    if let components = match.components {
                        if( result["address"] == nil) {
                            result["address"] = [String: [Any]]()
                        }
                        populate( &result["address"]!, "name", components[.name] )
                        populate( &result["address"]!, "jobTitle", components[.jobTitle] )
                        populate( &result["address"]!, "organization", components[.organization] )
                        populate( &result["address"]!, "street", components[.street] )
                        populate( &result["address"]!, "locality", components[.city] )
                        populate( &result["address"]!, "region", components[.state] )
                        populate( &result["address"]!, "postalCode", components[.zip] )
                        populate( &result["address"]!, "country", components[.country] )
                        populate( &result["address"]!, "phoneNumber", components[.phone] )
                    }
                case .link:
                    if let url = match.url {
                        if( result["link"] == nil) {
                            result["link"] = [String: [Any]]()
                        }
                        populate( &result["link"]!, "url", url )
                    }
                case .phoneNumber:
                    if let phoneNumber = match.phoneNumber {
                        if( result["telephone"] == nil) {
                            result["telephone"] = [String: [Any]]()
                        }
                        populate( &result["telephone"]!, "phoneNumber", phoneNumber )
                    }
                case .transitInformation:
                    if let components = match.components {
                        if( result["transitInformation"] == nil) {
                            result["transitInformation"] = [String: [Any]]()
                        }
                        populate( &result["transitInformation"]!, "airline", components[.airline])
                        populate( &result["transitInformation"]!, "flight", components[.flight] )
                    }
                default:
                    return
                }
            }
            
            let options: NSLinguisticTagger.Options = [.omitPunctuation, .omitWhitespace, .joinNames]
            let tags: [NSLinguisticTag] = [.personalName, .organizationName]
            
            let tagger = NSLinguisticTagger(tagSchemes: [.nameType], options: 0)
            tagger.string = statement
            let range2 = NSRange(location: 0, length: statement.utf16.count)
            tagger.enumerateTags(in: range2, unit: .word, scheme: .nameType, options: options) { tag, tokenRange, stop in
                if let tag = tag, tags.contains(tag) {
                    if let range = Range(tokenRange, in: statement) {
                        let name = statement[range]
                        switch tag {
                        case .personalName:
                            if( result["personalName"] == nil) {
                                result["personalName"] = [String: [Any]]()
                            }
                            populate( &result["personalName"]!, "name", name )
                        case .organizationName:
                            if( result["organizationName"] == nil) {
                                result["organizationName"] = [String: [Any]]()
                            }
                            populate( &result["organizationName"]!, "company", name )
                        default:
                            return
                        }
                    }
                }
            }
        } catch {
            print("handle error")
        }
        return result
    }
    
    func StringToDictionary( txt: String )-> NSDictionary? {
        if let data = txt.data(using: String.Encoding.utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject] as NSDictionary?
            } catch {}
        }
        return nil
    }
    
//    func executeOnFullPermission( execute:@escaping ((Bool)->()) ) {
//        #if targetEnvironment(simulator)
//            UserNotification.instance.requestAuthorization { (isNotifPermitted) in
//                execute(true)
//            }
//        #else
//            UserNotification.instance.requestAuthorization { (isNotifPermitted) in
//                if( isNotifPermitted ) {
//                    DispatchQueue.main.async {
//                        Location.instance.checkPermissionAction = { isLocPermitted in
//                            if isLocPermitted {
//                                execute(true)
//                            } else {
//                                execute(false)
//                            }
//                        }
//
//                        if !Location.instance.isAccessPermitted {
//                            Location.instance.requestAuthorization()
//                        } else {
//                            Location.instance.checkPermissionAction?(true)
//                        }
//                    }
//
//                } else {
//                    execute(false)
//                }
//            }
//        #endif
//    }
    
//    func log( _ isPermitted:Bool ) {
//        if let id = SystemSettings.instance.get(key: "id") as? Int,
//           let logaccess = SystemSettings.instance.get(key: "logaccess") as? Bool {
//            if id != -1 && logaccess {
//                HapticFeedback.instance.feedback(type: "medium", onSuccess: nil) { errorMessage in
//                    HapticFeedback.instance.feedback(type: "pop")
//                }
//                Location.instance.startLocationTracking()
//                execute(after: 0.3) {
//                    Location.instance.stopLocationTracking()
//                    CommandProcessor.queue(command: Command( commandCode: CommandCode.LOGACCESS ))
//                }
//            } else {
//                HapticFeedback.instance.feedback(type: "heavy", onSuccess: nil) { errorMessage in
//                    HapticFeedback.instance.feedback(type: "nope")
//                }
//            }
//        }
//    }
    
    func contains( source: [String], str: String ) -> Bool {
        let filteredStrings = source.filter({(item: String) -> Bool in
            let stringMatch = item.lowercased().range(of: str.lowercased())
            return stringMatch != nil ? true : false
        })
        return (filteredStrings as NSArray).count > 0
    }
    
    func splitDataToChunks( file:Data, onSplit:((Data)->()), onSuccess:((Bool)->()) ) {
        let length = file.count
        let chunkSize = (1024 * 1024) * 3
        var offset = 0
        var count = 0
        repeat {
            // get the length of the chunk
            let thisChunkSize = ((length - offset) > chunkSize) ? chunkSize : (length - offset);
            
            // get the chunk
            onSplit( file.subdata(in: offset..<offset + thisChunkSize ) )
            
            count+=1
            print("processing chunk # \(count)")
            
            // update the offset
            offset += thisChunkSize;
        } while (offset < length);
        onSuccess( true )
    }
    
    func StringToData( txt: String ) -> Data {
        return txt.data(using: .utf8, allowLossyConversion: false)!
    }
    
    func DataToString( data: Data ) -> String {
        return NSString(data: data, encoding: String.Encoding.utf8.rawValue)! as String
    }
    
    func DataToBase64( data: Data ) -> String {
        return data.base64EncodedString()
//        return data.base64EncodedString(options: NSData.Base64EncodingOptions.lineLength64Characters)
    }
    
    func Base64ToData( base64: String ) -> Data {
        return Data(base64Encoded: base64)!
    }
    
    func DictionaryToData( dict: NSDictionary ) -> Data? {
        do {
            return try NSKeyedArchiver.archivedData(withRootObject: dict, requiringSecureCoding: true)
        } catch _ as NSError {
            return nil
        }
        //return NSKeyedArchiver.archivedData(withRootObject: dict)
    }
    
    func DataToDictionary( data:Data ) -> NSDictionary? {
        do {
            guard let _data = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? NSDictionary else {
                return nil
            }
            return _data
        } catch _ as NSError {
            return nil
        }
    }
    
    func degrees(radians:Double) -> Double {
        return ( 180 / Double.pi ) * radians
    }
    
    func printDictionary( dictonary:NSDictionary ) {
        for (key, _) in dictonary {
            print( key )
            print( dictonary[ key ]! )
        }
    }
    
    func getDeviceOrientation() -> CGImagePropertyOrientation {
        let curDeviceOrientation = UIDevice.current.orientation
        let exifOrientation: CGImagePropertyOrientation
        
        switch curDeviceOrientation {
        case UIDeviceOrientation.portraitUpsideDown:  // Device oriented vertically, home button on the top
            exifOrientation = .left
        case UIDeviceOrientation.landscapeLeft:       // Device oriented horizontally, home button on the right
            exifOrientation = .upMirrored
        case UIDeviceOrientation.landscapeRight:      // Device oriented horizontally, home button on the left
            exifOrientation = .down
        case UIDeviceOrientation.portrait:            // Device oriented vertically, home button on the bottom
            exifOrientation = .up
        default:
            exifOrientation = .up
        }
        return exifOrientation
    }

    func getDimentionScaleValue( originalDimention:CGRect, resizedDimention:CGRect ) -> CGFloat {
        let width = 1 - ((originalDimention.width - resizedDimention.width) / originalDimention.width)
        let height = 1 - ((originalDimention.height - resizedDimention.height) / originalDimention.height)
        return CGFloat(max(width, height))
    }

    func getScaledDimention( dimention:CGRect, scale:CGFloat ) -> CGRect {
        return CGRect(x: dimention.origin.x, y: dimention.origin.y, width: dimention.width * scale, height: dimention.height * scale)
    }

    func getAspectRatioCoordinates( origin:CGPoint, originalDimention:CGRect, resizedDimention:CGRect ) -> CGPoint {
        let x = ((1-origin.y) * originalDimention.width) - ((originalDimention.width - resizedDimention.width) / 2)
        let y = (origin.x * originalDimention.height) - ((originalDimention.height - resizedDimention.height) / 2)
        return CGPoint(x: x, y: y)
    }
    
    func getAccessToken(username:String, password:String, clientId:String, clientSecret:String, callback: ((String?)->())?=nil) {
        if( Shared.shared.access_token != nil ) {
            callback?( Shared.shared.access_token )
            return
        }
        
        let parameter:[String: String] = [
            "url"       : "https://login.salesforce.com/services/oauth2/token",
            "method"    : "POST"
        ]
        
        let headers:[String: String] = [
            "Content-Type" : "application/json"
        ]
        
        let multipart:[String: String] = [
            "grant_type"    : "password",
            "client_id"     : clientId,
            "client_secret" : clientSecret,
            "username"      : username,
            "password"      : password
        ]
        
        let _ = Ajax.instance.request(urlString: parameter[ "url" ]!, method: parameter[ "method" ]!, multipart: multipart as NSDictionary, headers: headers as NSDictionary, onSuccess: { (token) in
            guard let token = token as NSDictionary?, let access_token = token.value(forKey: "access_token") as? String else {
                print("No access_token returned")
                callback?(nil)
                return
            }
            Shared.shared.access_token = access_token
            callback?( access_token )
        }, onFail: { (message) in
            print( "[ERROR] getAccessToken: \(message)" )
            callback?(nil)
        })
    }
    
    func ApexBase64JSONStringToDictionary( apexbase64: String ) -> NSDictionary? {
        let from = apexbase64.index(apexbase64.startIndex, offsetBy:1)
        let to = apexbase64.index(apexbase64.startIndex, offsetBy:apexbase64.count - 1)
        let restoreData = Data(base64Encoded: String(apexbase64[from..<to]) )
        let restoreString = String(data: restoreData!, encoding: .utf8)!
        return JSONStringToDictionary(txt: restoreString)
    }
    
    func JSONStringToDictionary( txt: String )-> NSDictionary? {
        if let data = txt.data(using: String.Encoding.utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject] as NSDictionary?
            } catch {}
        }
        return nil
    }
    
    func download( urlString: String, completionHandler: @escaping (Result<Data, Error>) -> Void ) {
        guard let dUrl = NSURL(string: urlString) as URL?  else {
            completionHandler(.failure(UtilityError.UNKNOWN))
            return
        }
        
        let downloadSession = URLSession.shared.dataTask(with: dUrl ) { (data: Data?, _, error: Error?) in
            if error != nil || data == nil {
                completionHandler(.failure(UtilityError.UNKNOWN))
                return
            }
            completionHandler(.success(data!))
        }
        downloadSession.resume()
    }
    
    public var loading:LoadingView?
    
    func showloading() {
        self.loading             = LoadingView( frame: Shared.shared.ViewController.view.frame )
        self.loading!.setup()

        Shared.shared.ViewController.view.addSubview( self.loading! )
    }
    
    func hideLoading() {
        self.loading?.closeDetailViewPage(finished: true)
    }
}


extension String {
    func escapeString() -> String {
        var newString = self.replacingOccurrences(of:"\"", with: "\"\"")
        if newString.contains(s: ",") || newString.contains(s:"\n") {
            newString = String(format: "\"%@\"", newString)
        }

        return newString
    }
}

extension String {
    var decodingUnicodeCharacters: String { applyingTransform(.init("Hex-Any"), reverse: false) ?? "" }
}

extension float4x4 {
    /**
     Treats matrix as a (right-hand column-major convention) transform matrix
     and factors out the translation component of the transform.
    */
    var translation: SIMD3<Float> {
        get {
            let translation = columns.3
            return [translation.x, translation.y, translation.z]
        }
        set(newValue) {
            columns.3 = [newValue.x, newValue.y, newValue.z, columns.3.w]
        }
    }
    
    /**
     Factors out the orientation component of the transform.
    */
    var orientation: simd_quatf {
        return simd_quaternion(self)
    }
    
    /**
     Creates a transform matrix with a uniform scale factor in all directions.
     */
    init(uniformScale scale: Float) {
        self = matrix_identity_float4x4
        columns.0.x = scale
        columns.1.y = scale
        columns.2.z = scale
    }
}

// MARK: - CGPoint extensions

extension CGPoint {
    /// Extracts the screen space point from a vector returned by SCNView.projectPoint(_:).
    init(_ vector: SCNVector3) {
        self.init(x: CGFloat(vector.x), y: CGFloat(vector.y))
    }

    /// Returns the length of a point when considered as a vector. (Used with gesture recognizers.)
    var length: CGFloat {
        return sqrt(x * x + y * y)
    }
}
