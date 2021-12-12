//
//  ApexRemote.swift
//  anthe
//
//  Created by Mart Ryan Civil on 2021/12/11.
//

import Foundation

class ApexRemote {
    
    static let instance:ApexRemote = ApexRemote()
    
    init() {}
    
    func addChildTag( recordId:String, photoId:String, callback: ((Bool, NSDictionary?)->())?=nil ) {
        Utility.shared.getAccessToken(username: Shared.shared.username,
                                      password: Shared.shared.password,
                                      clientId: Shared.shared.clientId,
                                      clientSecret: Shared.shared.clientSecret) { access_token in
            guard let access_token = access_token else {
                print("[ERROR] Access Token not obtained")
                return
            }
            
            let headers:[String: String] = [
                "Authorization" : "Bearer \(access_token)",
                "Content-Type"  : "application/json;charset=UTF-8"
            ]

            let json:[String: Any] = [
                "type"          : 8,
                "recordId"      : recordId,
                "photoId"       : photoId
            ]
        
            let data:[String: Any] = [
                "jsonString"    : Utility.shared.dictionaryToJSON(dictonary: json as NSDictionary)
            ]

            let _ = Ajax.instance.request(
                urlString   : Shared.shared.link + "/services/apexrest/appleiphone",
                method      : "POST",
                data        : data as NSDictionary,
                headers     : headers as NSDictionary,
                onSuccess   : { response in
                    guard let value = Utility.shared.ApexBase64JSONStringToDictionary(apexbase64: response.value(forKey: "value") as? String ?? "{}"),
                          let result = value.value(forKey: "result") as? Bool else {
                              callback?( false, ["errorMessage":"Error in registering Apple Watch Token"] )
                              return
                    }

                    if result {
                        callback?( true, value )
                    } else {
                        let message = value.value(forKey: "message") as? String
                        if message == "Token already exists" {
                            callback?( true, nil )
                        } else {
                            callback?( false, ["errorMessage":"Error in registering Apple Watch Token: " + (message ?? "no message" ) ] )
                        }
                    }
                }, onFail   : { message in
                    print( message )
                    callback?( false, ["errorMessage":"Error in registering Apple Watch Token: " + message] )
                }
            )
        }
    }
    
    func addTag( recordId:String, tags:[String], callback: ((Bool, NSDictionary?)->())?=nil ) {
        Utility.shared.getAccessToken(username: Shared.shared.username,
                                      password: Shared.shared.password,
                                      clientId: Shared.shared.clientId,
                                      clientSecret: Shared.shared.clientSecret) { access_token in
            guard let access_token = access_token else {
                print("[ERROR] Access Token not obtained")
                return
            }
            
            let headers:[String: String] = [
                "Authorization" : "Bearer \(access_token)",
                "Content-Type"  : "application/json;charset=UTF-8"
            ]

            var tagz = tags
            tagz.append("写真")
            let json:[String: Any] = [
                "type"          : 7,
                "recordId"      : recordId,
                "tags"          : tagz.joined(separator: ";")
            ]
        
            let data:[String: Any] = [
                "jsonString"    : Utility.shared.dictionaryToJSON(dictonary: json as NSDictionary)
            ]

            let _ = Ajax.instance.request(
                urlString   : Shared.shared.link + "/services/apexrest/appleiphone",
                method      : "POST",
                data        : data as NSDictionary,
                headers     : headers as NSDictionary,
                onSuccess   : { response in
                    guard let value = Utility.shared.ApexBase64JSONStringToDictionary(apexbase64: response.value(forKey: "value") as? String ?? "{}"),
                          let result = value.value(forKey: "result") as? Bool else {
                              callback?( false, ["errorMessage":"Error in registering Apple Watch Token"] )
                              return
                    }

                    if result {
                        callback?( true, value )
                    } else {
                        let message = value.value(forKey: "message") as? String
                        if message == "Token already exists" {
                            callback?( true, nil )
                        } else {
                            callback?( false, ["errorMessage":"Error in registering Apple Watch Token: " + (message ?? "no message" ) ] )
                        }
                    }
                }, onFail   : { message in
                    print( message )
                    callback?( false, ["errorMessage":"Error in registering Apple Watch Token: " + message] )
                }
            )
        }
    }
    
    func getImage( recordId:String, callback: ((Bool, NSDictionary?)->())?=nil ) {
        Utility.shared.getAccessToken(username: Shared.shared.username,
                                      password: Shared.shared.password,
                                      clientId: Shared.shared.clientId,
                                      clientSecret: Shared.shared.clientSecret) { access_token in
            guard let access_token = access_token else {
                print("[ERROR] Access Token not obtained")
                return
            }
            
            let headers:[String: String] = [
                "Authorization" : "Bearer \(access_token)",
                "Content-Type"  : "application/json;charset=UTF-8"
            ]

            let json:[String: Any] = [
                "type"          : 6,
                "recordId"      : recordId,
            ]
        
            let data:[String: Any] = [
                "jsonString"    : Utility.shared.dictionaryToJSON(dictonary: json as NSDictionary)
            ]

            let _ = Ajax.instance.request(
                urlString   : Shared.shared.link + "/services/apexrest/appleiphone",
                method      : "POST",
                data        : data as NSDictionary,
                headers     : headers as NSDictionary,
                onSuccess   : { response in
                    guard let value = Utility.shared.ApexBase64JSONStringToDictionary(apexbase64: response.value(forKey: "value") as? String ?? "{}"),
                          let result = value.value(forKey: "result") as? Bool else {
                              callback?( false, ["errorMessage":"Error in registering Apple Watch Token"] )
                              return
                    }

                    if result {
                        callback?( true, value )
                    } else {
                        let message = value.value(forKey: "message") as? String
                        if message == "Token already exists" {
                            callback?( true, nil )
                        } else {
                            callback?( false, ["errorMessage":"Error in registering Apple Watch Token: " + (message ?? "no message" ) ] )
                        }
                    }
                }, onFail   : { message in
                    print( message )
                    callback?( false, ["errorMessage":"Error in registering Apple Watch Token: " + message] )
                }
            )
        }
    }
    func getChildInfo( childRecordId:String, callback: ((Bool, NSDictionary?)->())?=nil ) {
        Utility.shared.getAccessToken(username: Shared.shared.username,
                                      password: Shared.shared.password,
                                      clientId: Shared.shared.clientId,
                                      clientSecret: Shared.shared.clientSecret) { access_token in
            guard let access_token = access_token else {
                print("[ERROR] Access Token not obtained")
                return
            }
            
            let headers:[String: String] = [
                "Authorization" : "Bearer \(access_token)",
                "Content-Type"  : "application/json;charset=UTF-8"
            ]

            let json:[String: Any] = [
                "type"          : 5,
                "childRecordId" : childRecordId,
            ]
        
            let data:[String: Any] = [
                "jsonString"    : Utility.shared.dictionaryToJSON(dictonary: json as NSDictionary)
            ]

            let _ = Ajax.instance.request(
                urlString   : Shared.shared.link + "/services/apexrest/appleiphone",
                method      : "POST",
                data        : data as NSDictionary,
                headers     : headers as NSDictionary,
                onSuccess   : { response in
                    guard let value = Utility.shared.ApexBase64JSONStringToDictionary(apexbase64: response.value(forKey: "value") as? String ?? "{}"),
                          let result = value.value(forKey: "result") as? Bool else {
                              callback?( false, ["errorMessage":"Error in registering Apple Watch Token"] )
                              return
                    }

                    if result {
                        callback?( true, value )
                    } else {
                        let message = value.value(forKey: "message") as? String
                        if message == "Token already exists" {
                            callback?( true, nil )
                        } else {
                            callback?( false, ["errorMessage":"Error in registering Apple Watch Token: " + (message ?? "no message" ) ] )
                        }
                    }
                }, onFail   : { message in
                    print( message )
                    callback?( false, ["errorMessage":"Error in registering Apple Watch Token: " + message] )
                }
            )
        }
    }
    
    func attachImage( contentvid:String, callback: ((Bool, NSDictionary?)->())?=nil ) {
        Utility.shared.getAccessToken(username: Shared.shared.username,
                                      password: Shared.shared.password,
                                      clientId: Shared.shared.clientId,
                                      clientSecret: Shared.shared.clientSecret) { access_token in
            guard let access_token = access_token else {
                print("[ERROR] Access Token not obtained")
                return
            }
            
            let headers:[String: String] = [
                "Authorization" : "Bearer \(access_token)",
                "Content-Type"  : "application/json;charset=UTF-8"
            ]
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "YYYY-MM-dd"

            let json:[String: Any] = [
                "type"          : 4,
                "username"      : Shared.shared.username,
                "date"          : dateFormatter.string(from: Date()),
                "contentvid"    : contentvid
            ]
        
            let data:[String: Any] = [
                "jsonString"    : Utility.shared.dictionaryToJSON(dictonary: json as NSDictionary)
            ]

            let _ = Ajax.instance.request(
                urlString   : Shared.shared.link + "/services/apexrest/appleiphone",
                method      : "POST",
                data        : data as NSDictionary,
                headers     : headers as NSDictionary,
                onSuccess   : { response in
                    guard let value = Utility.shared.ApexBase64JSONStringToDictionary(apexbase64: response.value(forKey: "value") as? String ?? "{}"),
                          let result = value.value(forKey: "result") as? Bool else {
                              callback?( false, ["errorMessage":"Error in registering Apple Watch Token"] )
                              return
                    }

                    if result {
                        callback?( true, value )
                    } else {
                        let message = value.value(forKey: "message") as? String
                        if message == "Token already exists" {
                            callback?( true, nil )
                        } else {
                            callback?( false, ["errorMessage":"Error in registering Apple Watch Token: " + (message ?? "no message" ) ] )
                        }
                    }
                }, onFail   : { message in
                    print( message )
                    callback?( false, ["errorMessage":"Error in registering Apple Watch Token: " + message] )
                }
            )
        }
    }
    
    func getDailyEvent( callback: ((Bool, NSDictionary?)->())?=nil ) {
        Utility.shared.getAccessToken(username: Shared.shared.username,
                                      password: Shared.shared.password,
                                      clientId: Shared.shared.clientId,
                                      clientSecret: Shared.shared.clientSecret) { access_token in
            guard let access_token = access_token else {
                print("[ERROR] Access Token not obtained")
                return
            }
            
            let headers:[String: String] = [
                "Authorization" : "Bearer \(access_token)",
                "Content-Type"  : "application/json;charset=UTF-8"
            ]
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "YYYY-MM-dd"

            let json:[String: Any] = [
                "type"          : 3,
                "username"      : Shared.shared.username,
                "date"          : dateFormatter.string(from: Date())
            ]
        
            let data:[String: Any] = [
                "jsonString"    : Utility.shared.dictionaryToJSON(dictonary: json as NSDictionary)
            ]

            let _ = Ajax.instance.request(
                urlString   : Shared.shared.link + "/services/apexrest/appleiphone",
                method      : "POST",
                data        : data as NSDictionary,
                headers     : headers as NSDictionary,
                onSuccess   : { response in
                    guard let value = Utility.shared.ApexBase64JSONStringToDictionary(apexbase64: response.value(forKey: "value") as? String ?? "{}"),
                          let result = value.value(forKey: "result") as? Bool else {
                              callback?( false, ["errorMessage":"Error in registering Apple Watch Token"] )
                              return
                    }

                    if result {
                        callback?( true, value )
                    } else {
                        let message = value.value(forKey: "message") as? String
                        if message == "Token already exists" {
                            callback?( true, nil )
                        } else {
                            callback?( false, ["errorMessage":"Error in registering Apple Watch Token: " + (message ?? "no message" ) ] )
                        }
                    }
                }, onFail   : { message in
                    print( message )
                    callback?( false, ["errorMessage":"Error in registering Apple Watch Token: " + message] )
                }
            )
        }
    }
    
    func getDailyReport( callback: ((Bool, NSDictionary?)->())?=nil ) {
        Utility.shared.getAccessToken(username: Shared.shared.username,
                                      password: Shared.shared.password,
                                      clientId: Shared.shared.clientId,
                                      clientSecret: Shared.shared.clientSecret) { access_token in
            guard let access_token = access_token else {
                print("[ERROR] Access Token not obtained")
                return
            }
            
            let headers:[String: String] = [
                "Authorization" : "Bearer \(access_token)",
                "Content-Type"  : "application/json;charset=UTF-8"
            ]
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "YYYY-MM-dd"

            let json:[String: Any] = [
                "type"          : 2,
                "username"      : Shared.shared.username,
                "date"          : dateFormatter.string(from: Date())
            ]
        
            let data:[String: Any] = [
                "jsonString"    : Utility.shared.dictionaryToJSON(dictonary: json as NSDictionary)
            ]

            let _ = Ajax.instance.request(
                urlString   : Shared.shared.link + "/services/apexrest/appleiphone",
                method      : "POST",
                data        : data as NSDictionary,
                headers     : headers as NSDictionary,
                onSuccess   : { response in
                    guard let value = Utility.shared.ApexBase64JSONStringToDictionary(apexbase64: response.value(forKey: "value") as? String ?? "{}"),
                          let result = value.value(forKey: "result") as? Bool else {
                              callback?( false, ["errorMessage":"Error in registering Apple Watch Token"] )
                              return
                    }

                    if result {
                        callback?( true, value )
                    } else {
                        let message = value.value(forKey: "message") as? String
                        if message == "Token already exists" {
                            callback?( true, nil )
                        } else {
                            callback?( false, ["errorMessage":"Error in registering Apple Watch Token: " + (message ?? "no message" ) ] )
                        }
                    }
                }, onFail   : { message in
                    print( message )
                    callback?( false, ["errorMessage":"Error in registering Apple Watch Token: " + message] )
                }
            )
        }
    }
    
    func getUserData( callback: ((Bool, NSDictionary?)->())?=nil ) {
        Utility.shared.getAccessToken(username: Shared.shared.username,
                                      password: Shared.shared.password,
                                      clientId: Shared.shared.clientId,
                                      clientSecret: Shared.shared.clientSecret) { access_token in
            guard let access_token = access_token else {
                print("[ERROR] Access Token not obtained")
                return
            }
            
            let headers:[String: String] = [
                "Authorization" : "Bearer \(access_token)",
                "Content-Type"  : "application/json;charset=UTF-8"
            ]
            
            let json:[String: Any] = [
                "type"          : 1,
                "username"        : Shared.shared.username,
            ]
        
            let data:[String: Any] = [
                "jsonString"    : Utility.shared.dictionaryToJSON(dictonary: json as NSDictionary)
            ]

            let _ = Ajax.instance.request(
                urlString   : Shared.shared.link + "/services/apexrest/appleiphone",
                method      : "POST",
                data        : data as NSDictionary,
                headers     : headers as NSDictionary,
                onSuccess   : { response in
                    guard let value = Utility.shared.ApexBase64JSONStringToDictionary(apexbase64: response.value(forKey: "value") as? String ?? "{}"),
                          let result = value.value(forKey: "result") as? Bool else {
                              callback?( false, ["errorMessage":"Error in registering Apple Watch Token"] )
                              return
                    }

                    if result {
                        callback?( true, value )
                    } else {
                        let message = value.value(forKey: "message") as? String
                        if message == "Token already exists" {
                            callback?( true, nil )
                        } else {
                            callback?( false, ["errorMessage":"Error in registering Apple Watch Token: " + (message ?? "no message" ) ] )
                        }
                    }
                }, onFail   : { message in
                    print( message )
                    callback?( false, ["errorMessage":"Error in registering Apple Watch Token: " + message] )
                }
            )
        }
    }
    
}
