//
//  NFCReader.swift
//  Luna
//
//  Created by Mart Civil on 2018/02/16.
//  Copyright © 2018年 salesforce.com. All rights reserved.
// Apple video: https://developer.apple.com/videos/play/wwdc2019/715/
//

import Foundation
import UIKit
import CoreNFC

class NFCReader {
    
    static let instance:NFCReader = NFCReader()
    var session: NFCNDEFReaderSession!
    var sessiontag:NFCTagReaderSession?
    //var message: NFCNDEFMessage = .init(records: [])
    var writemessage:[String:Any]?
    var nfcscanAction:(([NSDictionary])->())?
    var nfcerrorAction:((String)->())?
    
    
    init() {}
    
    func scan(message:String, onSuccess:@escaping (([NSDictionary])->()), onFail:@escaping ((String)->())) {
        writemessage = nil
        session = NFCNDEFReaderSession(delegate: Shared.shared.ViewController, queue: nil, invalidateAfterFirstRead: true)
        session.alertMessage = message
        session.begin()
        nfcscanAction = onSuccess
        nfcerrorAction = onFail
    }
    
    func scanResult( result:[NSDictionary]?=nil, error: String?=nil ) {
        print("[INFO] scanResult SCAN")
        if result != nil {
            nfcscanAction?( result! )
        }
        if error != nil {
            nfcerrorAction?( error! )
        }
    }
    
    func write(message:String, content:[String:Any], onSuccess:@escaping (([NSDictionary])->()), onFail:@escaping ((String)->())) {
        writemessage = content
        session = NFCNDEFReaderSession(delegate: Shared.shared.ViewController, queue: nil, invalidateAfterFirstRead: false)
        session.alertMessage = message
        session.begin()
        nfcscanAction = onSuccess
        nfcerrorAction = onFail
    }
    
    func scanFelica(message:String, onSuccess:@escaping (([NSDictionary])->()), onFail:@escaping ((String)->())) {
        writemessage = nil
        sessiontag = NFCTagReaderSession(pollingOption: .iso18092, delegate: Shared.shared.ViewController, queue: nil)
        sessiontag!.alertMessage = message
        sessiontag!.begin()
        nfcscanAction = onSuccess
        nfcerrorAction = onFail
    }
}

extension ViewController: NFCNDEFReaderSessionDelegate, NFCTagReaderSessionDelegate {
    
    func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {
        print("tagReaderSessionDidBecomeActive(_:)")
    }
    
    func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError error: Error) {
        if let readerError = error as? NFCReaderError {
            print("tagReaderSession(_:) didInvalidateWithError")
            if (readerError.code != .readerSessionInvalidationErrorFirstNDEFTagRead)
                && (readerError.code != .readerSessionInvalidationErrorUserCanceled) {
                let alertController = UIAlertController(
                    title: "Session Invalidated",
                    message: error.localizedDescription,
                    preferredStyle: .alert
                )
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                DispatchQueue.main.async {
                    NFCReader.instance.scanResult(error: error.localizedDescription)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
        NFCReader.instance.sessiontag = nil
    }

    func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
        print("tagReaderSession(_:) didDetect")
        if tags.count > 1 {
            let retryInterval = DispatchTimeInterval.milliseconds(500)
            session.alertMessage = "More than 1 tag is detected, please remove all tags and try again."
            DispatchQueue.global().asyncAfter(deadline: .now() + retryInterval, execute: {
                session.restartPolling()
            })
            return
        }

        let tag = tags.first!
        session.connect(to: tag) { (error) in
            if nil != error {
                session.invalidate(errorMessage: "Connection error. Please try again.")
                return
            }

            guard case .feliCa(let feliCaTag) = tag else {
                let retryInterval = DispatchTimeInterval.milliseconds(500)
                session.alertMessage = "A tag that is not FeliCa is detected, please try again with tag FeliCa."
                DispatchQueue.global().asyncAfter(deadline: .now() + retryInterval, execute: {
                    session.restartPolling()
                })
                return
            }

            let idm = feliCaTag.currentIDm.map { String(format: "%.2hhx", $0) }.joined()
            let systemCode = feliCaTag.currentSystemCode.map { String(format: "%.2hhx", $0) }.joined()

            var result = [String:Any]()
            result["id"] = idm
            result["systemCode"] = systemCode
            //print("IDm: \(idm)")
            //print("System Code: \(systemCode)")

            let serviceCode = Data([0x09,0x0f].reversed())       // サービス(データ)を特定するコード
            //let blockList = (0..<12).map { Data([0x80, UInt8($0)]) } // データの取得方法/位置を決める
            let blockList = (0..<UInt8(14)).map { Data([0x80, $0]) }
            
            feliCaTag.requestService(nodeCodeList: [serviceCode]) { nodes, error in
                guard error == nil else {
                    session.invalidate(errorMessage: "Felica requestService error: \(error!.localizedDescription)")
                    print("Felica requestService error")
                    return
                }
                guard let data = nodes.first, data != Data([0xff, 0xff]) else {
                    session.invalidate(errorMessage: "履歴情報が存在しません")
                    print("履歴情報が存在しません。")
                    return
                }

                feliCaTag.readWithoutEncryption(
                    serviceCodeList: [serviceCode],
                    blockList: blockList) { status1, status2, dataList, error in
                        guard error == nil else {
                            session.invalidate(errorMessage: "履歴情報が存在しません")
                            return
                        }
                        guard status1 == 0x00, status2 == 0x00 else {
                            session.invalidate(errorMessage: "ステータスコードが正常ではありません: status1 & status2")
                            return
                        }
                        
                        //機器種別を取得します
                        let getConsoleType = {(data:Data) -> String in
                            switch (data[0] & 0xff) {
                                case 0x03: return "精算機";
                                case 0x04: return "携帯型端末";
                                case 0x05: return "等車載端末"; //bus
                                case 0x07: return "券売機";
                                case 0x08: return "券売機";
                                case 0x09: return "入金機(クイックチャージ機)";
                                case 0x12: return "券売機(東京モノレール)";
                                case 0x13: return "券売機等";
                                case 0x14: return "券売機等";
                                case 0x15: return "券売機等";
                                case 0x16: return "改札機";
                                case 0x17: return "簡易改札機";
                                case 0x18: return "窓口端末";
                                case 0x19: return "窓口端末(みどりの窓口)";
                                case 0x1a: return "改札端末";
                                case 0x1b: return "携帯電話";
                                case 0x1c: return "乗継清算機";
                                case 0x1d: return "連絡改札機";
                                case 0x1f: return "簡易入金機";
                                case 0x46: return "VIEW ALTTE";
                                case 0x48: return "VIEW ALTTE";
                                case 0xc7: return "物販端末";  //sales
                                case 0xc8: return "自販機";   //sales
                                default:
                                    return "???";
                            }
                        }
                        
                        //処理種別を取得します
                        let getProcessType = {(data:Data) -> String in
                            switch (data[1] & 0xff) {
                                case 0x01: return "運賃支払(改札出場)";
                                case 0x02: return "チャージ";
                                case 0x03: return "券購(磁気券購入)";
                                case 0x04: return "精算";
                                case 0x05: return "精算(入場精算)";
                                case 0x06: return "窓出(改札窓口処理)";
                                case 0x07: return "新規(新規発行)";
                                case 0x08: return "控除(窓口控除)";
                                case 0x0d: return "バス(PiTaPa系)";    //byBus
                                case 0x0f: return "バス(IruCa系)";     //byBus
                                case 0x11: return "再発(再発行処理)";
                                case 0x13: return "支払(新幹線利用)";
                                case 0x14: return "入A(入場時オートチャージ)";
                                case 0x15: return "出A(出場時オートチャージ)";
                                case 0x1f: return "入金(バスチャージ)";            //byBus
                                case 0x23: return "券購 (バス路面電車企画券購入)";  //byBus
                                case 0x46: return "物販";                 //sales
                                case 0x48: return "特典(特典チャージ)";
                                case 0x49: return "入金(レジ入金)";         //sales
                                case 0x4a: return "物販取消";              //sales
                                case 0x4b: return "入物 (入場物販)";        //sales
                                case 0xc6: return "物現 (現金併用物販)";     //sales
                                case 0xcb: return "入物 (入場現金併用物販)"; //sales
                                case 0x84: return "精算 (他社精算)";
                                case 0x85: return "精算 (他社入場精算)";
                                default:
                                    return "???";
                            }
                        }
                        //バス利用の場合trueが戻ります
                        let isByBus = {(data:Data) -> Bool in
                            return (data[0] & 0xff) == 0x05
                        }

                        //端末種別が「物販」か否かを判定します
                        let isProductSales = {(data:Data) -> Bool in
                            return (data[0] & 0xff) == 0xc7 || (data[0] & 0xff) == 0xc8
                        }
                        
                        //処理種別が「チャージ」か否かを判定します (店舗名を取得できるか否かを判定します)
                        let isCharge = {(data:Data) -> Bool in
                            return (data[1] & 0xff) == 0x02
                        }
                        
                        let getDate = { (data: Data) -> String in
                            let date = UInt16(bytes: data[4...5])
                            let year = (date >> 9) + 2000
                            let month = ((date >> 5) & 0xf)
                            let day = date & 0x1f
                            if( isProductSales(data) ) {
                                let time = UInt16(bytes: data[6...7])
                                let hh = time >> 11
                                let min = (time >> 5) & 0x3f
                                return "\(year)/\(month)/\(day) \(String(format: "%02d:%02d", hh, min))"
                            }
                            return "\(year)/\(month)/\(day)"
                        }
                        
                        let getTrainStation = {(areaCode:Int, lineCode:Int, stationCode:Int) -> [String:Any] in
                            return [
                                "areaCode"      : areaCode & 0xff,
                                "lineCode"      : lineCode & 0xff,
                                "stationCode"   : stationCode & 0xff
                            ]
                        }
                        let getBusStation = {(lineCode:Int, stationCode:Int) -> [String:Any] in
                            return [
                                "lineCode"      : lineCode,
                                "stationCode"   : stationCode
                            ]
                        }
                        let getStation = {(data:Data, type:String) -> [String:Any] in
                            if( !isByBus(data) ) {
                                if( type == "IN" ) {
                                    return getTrainStation(Int(data[15]), Int(data[6]), Int(data[7]))
                                } else {
                                    return getTrainStation(Int(data[15]), Int(data[8]), Int(data[9]))
                                }
                            } else {
                                return getBusStation(Int(UInt16(bytes: data[6...7])), Int(UInt16(bytes: data[8...9])))
                            }
                        }
                        
                        print("==========================")
                        var records = [[String:Any]]()
                        for data in dataList {
                            var record = [String:Any]()
                            record["isByBus"] = isByBus(data)
                            record["isProductSales"] = isProductSales(data)
                            record["isCharge"] = isCharge(data)
                            //http://tech-blog.rakus.co.jp/entry/20190930/ios
                            //SELECT * FROM 'StationCode' WHERE AreaCode = 0 AND LineCode = 29 AND StationCode = 15
                            //https://inloop.github.io/sqlite-viewer/
                            //‎⁨Macintosh HD⁩ ▸ ⁨ユーザ⁩ ▸ ⁨mcivil⁩ ▸ ⁨ダウンロード⁩ ▸ ⁨nfc-felica⁩ ▸ ⁨nfc-felica⁩ ▸ ⁨branches⁩ ▸ ⁨nfc-felica-2.3.2⁩ ▸ ⁨assets⁩ ▸ StationCode.db
                            
//                            explorer.ajax({
//                                type    : "POST",
//                                url     : "https://luna-10.herokuapp.com/getStation",
//                                headers: {
//                                    "Content-Type"      : "application/json"
//                                },
//                                responseType: 'json',
//                                data: JSON.stringify({
//                                    areaCode           : '0',
//                                    lineCode           : '29',
//                                    stationCode        : '15'
//                                })
//                            }).then(result => { console.log(result) })
//

//                            explorer.ajax({
//                                type    : "POST",
//                                url     : "https://luna-10.herokuapp.com/getIrucaStation",
//                                headers: {
//                                    "Content-Type"      : "application/json"
//                                },
//                                responseType: 'json',
//                                data: JSON.stringify({
//                                    areaCode            : '0',
//                                    lineCode            : 'e51',
//                                    stationCode         : '6f8'
//                                })
//                            }).then(result => { console.log(result) })
                            record["date"] = getDate(data)
                            record["consoleType"] = [
                                "code"  : (data[0] & 0xff),
                                "label" : getConsoleType(data)
                            ]
                            record["processType"] = [
                                "code"  : (data[1] & 0xff),
                                "label" : getProcessType(data)
                            ]
                            //print( "処理日付: \(record["date"])" )
                            //print( "機器種別: \(getProcessType(data))" )
                            //print( "処理種別: \(getProcessType(data))" )
                            if( !(record["isProductSales"] as! Bool) && !(record["isCharge"] as! Bool)) {
                                record["in"] = getStation( data, "IN")
                                record["out"] = getStation( data, "OUT")
                                //print( "入場駅 \(getStation( data, "IN"))" )
                                //print( "出場駅 \(getStation( data, "OUT"))" )
                            }
                            //print("残高: ", Int(data[10]) + Int(data[11]) << 8)
                            record["balance"] = Int(data[10]) + Int(data[11]) << 8
                            print(record)
                            print("==========================")
                            records.append(record)
                        }
                        result["records"] = records
                        print("レコード数: \(dataList.count)")
                }
                Utility.shared.execute(after: 0.3) {
                    NFCReader.instance.scanResult(result: [result] as [NSDictionary])
                    session.alertMessage = ""//"Read success!\nIDm: \(idm)\nSystem Code: \(systemCode)"
                    session.invalidate()
                }
            }
        }
    }
    
    
    func readerSessionDidBecomeActive(_ session: NFCNDEFReaderSession) {
        print("[INFO] NFC readerSessionDidBecomeActive")
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        print("[INFO] NFCNDEFReaderSession didDetectNDEFs")
    }
    
    public func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        print( "[ERROR] ", error.localizedDescription )
        NFCReader.instance.scanResult(error: error.localizedDescription)
    }
    
    //https://www.firesideswift.com/blog/2019/10/29/basic-reading-and-writing-to-tags-using-corenfc
    //https://qiita.com/tattn/items/aef6dd51d514e9a4bea7
    func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [NFCNDEFTag]) {
        if tags.count > 1 {
            // Restart polling in 500ms
            let retryInterval = DispatchTimeInterval.milliseconds(500)
            session.alertMessage = "More than 1 tag is detected, please remove all tags and try again."
            DispatchQueue.global().asyncAfter(deadline: .now() + retryInterval, execute: {
                session.restartPolling()
            })
            return
        }
        
        // Connect to the found tag and perform NDEF message reading
        let tag = tags.first!
        session.connect(to: tag, completionHandler: { (error: Error?) in
            if nil != error {
                session.alertMessage = "Unable to connect to tag."
                session.invalidate()
                return
            }
            
            tag.queryNDEFStatus(completionHandler: { (ndefStatus: NFCNDEFStatus, capacity: Int, error: Error?) in
                
                var statusMessage:String = ""
                //[INFO] NFC Read
                if( NFCReader.instance.writemessage == nil ) {
                    if .notSupported == ndefStatus {
                        session.invalidate(errorMessage: "Tag is not NDEF compliant")
                        return
                    } else if nil != error {
                        session.invalidate(errorMessage: "Unable to query NDEF status of tag")
                        return
                    }
                    
                    tag.readNDEF(completionHandler: { (message: NFCNDEFMessage?, error: Error?) in
                        if nil != error || nil == message {
                            session.invalidate(errorMessage: "Fail to read NDEF from tag")
                        } else {
                            //statusMessage = "Found 1 NDEF message"
                            statusMessage = ""
                            
                            var nfcdict = [[String: Any]]()
                            //for message in messages {
                            for record in message!.records {
                                var value = [String: Any]()
                                
                                if let type = String.init(data: record.type, encoding: .utf8) {
                                    value["type"] = type
                                    //value.setValue( type, forKey: "type")
                                }
                                if let identifier = String.init(data: record.identifier, encoding: .utf8) {
                                    value["identifier"] = identifier
                                    //value.setValue( identifier, forKey: "identifier")
                                }
                                
                                
                                value["payload"] = Utility.shared.DataToBase64(data: record.payload)
                                //value.setValue( Utility.shared.DataToBase64(data: record.payload), forKey: "payload")
                                
//                                if let parsedPayload = VYNFCNDEFPayloadParser.parse(record) {
//                                    if let wifi = parsedPayload as? VYNFCNDEFWifiSimpleConfigPayload {
//                                        for credential in wifi.credentials {
//                                            switch credential {
//                                            case let wificonfig as VYNFCNDEFWifiSimpleConfigCredential:
//                                                let json = "{\"ssid\":\"\(wificonfig.ssid)\",\"passphrase\":\"\(wificonfig.networkKey)\"}"
//                                                value["payload"] =  Utility.shared.DataToBase64(data: Utility.shared.StringToData(txt: json))
//                                                //value.setValue( Utility.shared.DataToBase64(data: Utility.shared.StringToData(txt: json)), forKey: "payload")
//                                            default:
//                                                break
//                                            }
//                                        }
//                                    }
//                                }

                                value["typeNameFormat"] = record.typeNameFormat.rawValue
                                //value.setValue( record.typeNameFormat.rawValue, forKey: "typeNameFormat")
                                nfcdict.append(value)
                            }
                            //}
                            NFCReader.instance.scanResult(result: nfcdict as [NSDictionary])
                            session.alertMessage = statusMessage
                            session.invalidate()
                        }
                    })
                } else {
                    //[INFO] WRITE NFC
                    switch ndefStatus {
                    case .notSupported:
                        statusMessage = "Tag is not NDEF compliant."
                    case .readOnly:
                        statusMessage = "Tag is read only."
                    case .readWrite:
                        let generatePayload = { (content: [String:Any]) -> NFCNDEFPayload? in
                            guard let _formatType = content["formatType"] as? String else {
                                return nil
                            }
                            
                            var type:Data?
                            var payload:Data = Data()
                            
                            var formatType:NFCTypeNameFormat?
                            switch _formatType {
                            case "text":
                                formatType = .nfcWellKnown
                                guard let message = content["message"] as? String else {
                                    return nil
                                }
                                let _type = content["type"] as? String ?? "T"
                                type = _type.data(using: .utf8)!
                                payload = Data([0x02,0x65,0x6E])
                                payload.append( message.data(using: .utf8)! )
                                break
                            case "media":
                                formatType = .media
                                guard let message = content["message"] as? String else {
                                    return nil
                                }
                                let _type = content["type"] as? String ?? "text/plain"
                                type = _type.data(using: .utf8)!
                                payload.append( message.data(using: .utf8)! )
                                break
                            default:
                                break
                            }
                            if formatType == nil || type == nil {
                                return nil
                            }
                            return NFCNDEFPayload.init(
                                format      : formatType!,
                                type        : type!,
                                identifier  : Data.init(count: 0),
                                payload     : payload,
                                chunkSize   : 0)
                        }
                        //https://blog.st.com/wp-content/uploads/NDEFVCardRecordViewController.swift
                        //NFCNDEFPayload.init(format: .media, type: <#T##Data#>, identifier: <#T##Data#>, payload: <#T##Data#>)
                        
//                        var payloadData = Data([0x02,0x65,0x6E]) // 0x02 + 'en' = Locale Specifier
//                        payloadData.append("Text To Write".data(using: .utf8)!)
//                        let textRecord = NFCNDEFPayload.init(
//                            format: NFCTypeNameFormat.nfcWellKnown,
//                            type: "T".data(using: .utf8)!,
//                            identifier: Data.init(count: 0),
//                            payload: payloadData,
//                            chunkSize: 0)

//                        let mediaRecord = NFCNDEFPayload.init(
//                            format: NFCTypeNameFormat.media,
//                            type: "text/plain".data(using: .utf8)!,
//                            identifier: Data.init(count: 0),
//                            payload: "Merry Christmas".data(using: .utf8)!,
//                            chunkSize: 0)
                        
                        guard let messagepayload = generatePayload( NFCReader.instance.writemessage! ) else {
                            session.invalidate(errorMessage: "Failed to generate payload")
                            return
                        }
                        tag.writeNDEF(NFCNDEFMessage.init(records: [messagepayload]), completionHandler: { (error: Error?) in
                            if nil != error {
                                session.invalidate(errorMessage: "Write NDEF message fail: \(error!)")
                            } else {
                                let _result = ["result":true]
                                NFCReader.instance.scanResult(result: [_result as NSDictionary])
                                session.alertMessage = ""
                                session.invalidate()
                            }
                        })
                        return
                    @unknown default:
                        statusMessage = "Unknown NDEF tag status."
                    }
                    session.invalidate(errorMessage: statusMessage)
                }
            })
        })
    }
}

extension FixedWidthInteger {
    init(bytes: UInt8...) {
        self.init(bytes: bytes)
    }

    init<T: DataProtocol>(bytes: T) {
        let count = bytes.count - 1
        self = bytes.enumerated().reduce(into: 0) { (result, item) in
            result += Self(item.element) << (8 * (count - item.offset))
        }
    }
}
