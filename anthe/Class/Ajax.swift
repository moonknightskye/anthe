//
//  Ajax.swift
//  Luna
//
//  Created by Mart Civil on 2018/02/28.
//  Copyright © 2018年 salesforce.com. All rights reserved.
//

import Foundation


class Ajax:NSObject, URLSessionTaskDelegate {
    
    //IMPLEMENT WEBSOCKETS https://devcenter.heroku.com/articles/node-websockets
    //https://appspector.com/blog/websockets-in-ios-using-urlsessionwebsockettask
    static let instance:Ajax = Ajax("Luna")
    
    init(_ : String) {}
    
    func request(urlString:String, method:String?="POST", data:NSDictionary?=nil, multipart:NSDictionary?=nil, headers:NSDictionary?=nil, onSuccess: ((NSDictionary)->())?=nil, onFail: ((String)->())?=nil) -> URLSession? {
        var request  = URLRequest(url: URL(string: urlString)!)
        request.httpMethod = method
        request.httpShouldHandleCookies = true
        
        if let headers = headers as? [String : String] {
            request.allHTTPHeaderFields = headers
        }
    
        if let data = data {
            request.httpBody = Utility.shared.dictionaryToJSON(dictonary: data).data(using: .utf8)
        } else if let multipart = multipart {
            let boundary = "Boundary-\(UUID().uuidString)"
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            guard let body = createBody(multipart: multipart, boundary: boundary) else {
                onFail?("failed to get the body")
                return nil
            }
            request.httpBody = body
        }
        
        
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: request) { data, response, error in
            
            guard let data = data, error == nil else {
                onFail?(error.debugDescription)
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, let responseString = String(data: data, encoding: .utf8) {
                
                guard let resp = Utility.shared.StringToDictionary(txt: responseString) else {
                    if( httpStatus.statusCode == 200 || httpStatus.statusCode == 201 ) {
                        let r = NSMutableDictionary()
                        r.setValue(responseString, forKey: "value")
                        onSuccess?(r)
                    } else {
                        onFail?(responseString)
                    }
                    return
                }
                
                if( httpStatus.statusCode == 200 || httpStatus.statusCode == 201) {
                    onSuccess?( resp )
                } else {
                    guard let message = resp.value(forKey: "message") as? String else {
                        onFail?(responseString)
                        return
                    }
                    onFail?(message)
                    
                    print("REQUEST FAILED response: \(response!)")
                    print("REQUEST FAILED resp: \(resp)")
                }
            }
        }
        
        task.resume()
        return session
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        
        let progress:Float = (Float(totalBytesSent) / Float(totalBytesExpectedToSend)) * 100
        for ( _, uploadFile) in File.UPLOADLIST.enumerated() {
            if( uploadFile.getUploadSession()! == session ) {
                //CommandProcessor.processUploading(file: uploadFile, progress: progress)
                print("[PROGRESS] \(String(describing: progress))")
            }
        }
    }
    
    
//    private func createBody(multipart: NSDictionary, boundary: String) -> Data? {
//        let body = NSMutableData()
//
//        let boundaryPrefix = "--\(boundary)\r\n"
//
//        for (key, value) in multipart {
//            body.appendString(boundaryPrefix)
//            if( String(describing: key) == "fileInstance" ) {
//                guard let fileInstance = multipart.value(forKey: "fileInstance") as? File else {
//                    return nil
//                }
//                guard let multipartdict = getMultipart( file: fileInstance ) else {
//                    return nil
//                }
//                body.appendString("Content-Disposition: form-data; name=\"file\"; filename=\"\(multipartdict.value(forKey: "filename") as! String)\"\r\n")
//                body.appendString("Content-Type: \(multipartdict.value(forKey: "mimetype") as! String)\r\n\r\n")
//                body.append(multipartdict.value(forKey: "data") as! Data)
//                body.appendString("\r\n")
//            } else {
//                body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
//                body.appendString("\(value)\r\n")
//            }
//        }
//
//        body.appendString("--".appending(boundary.appending("--\r\n")))
//
//        return body as Data
//    }

    private func createBody(multipart: NSDictionary, boundary: String) -> Data? {
        let body = NSMutableData()
        
        let boundaryPrefix = "--\(boundary)\r\n"
        
        for (key, value) in multipart {
            body.appendString(boundaryPrefix)
            if( String(describing: key) == "fileInstance" ) {
                guard let fileInstance = multipart.value(forKey: String(describing: key)) as? File,
                    let multipartdict = getMultipart( file: fileInstance ) else {
                    return nil
                }
                body.appendString("Content-Disposition: form-data; name=\"file\"; filename=\"\(multipartdict.value(forKey: "filename") as! String)\"\r\n")
                body.appendString("Content-Type: \(multipartdict.value(forKey: "mimetype") as! String)\r\n\r\n")
                body.append(multipartdict.value(forKey: "data") as! Data)
                body.appendString("\r\n")
            } else {
                body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                body.appendString("\(value)\r\n")
            }
        }
        
        body.appendString("--".appending(boundary.appending("--\r\n")))
        return body as Data
    }
    
    private func getMultipart( file: File ) -> NSMutableDictionary? {
        let multipart = NSMutableDictionary()
        guard let filename = file.getFileName(),
            let data = file.getFile() else {
                return nil
        }
        multipart.setValue(filename, forKey: "filename")
        multipart.setValue(data, forKey: "data")
        multipart.setValue( file.getMimeType() + "/" + file.getFileExtension().rawValue , forKey: "mimetype")

        return multipart
    }

}

extension NSMutableData {
    func appendString(_ string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: false)
        append(data!)
    }
}
