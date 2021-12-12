//
//  File.swift
//  anthe
//
//  Created by Mart Ryan Civil on 2021/12/11.
//

import Foundation
import UIKit

public enum FileError: Error {
    case INEXISTENT
    case SOURCE_UNDEFINED
    case INVALID_PARAMETERS
    case DOWNLOAD_ALREADY_INQUEUE
    case ALREADY_EXISTS
    case ONLY_DOCUMENT_TYPE
    case ONLY_URL_TYPE
    case CANNOT_CREATE
    case CANNOT_MOVE
    case CANNOT_DELETE
    case CANNOT_COPY
    case CANNOT_RENAME
    case INVALID_FORMAT
    case NO_DATA
    case ALREADY_UNZIPPED
    case INVALID_FILETYPE
    case UNKNOWN_ERROR
}
extension FileError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .INEXISTENT:
            return NSLocalizedString("File does not exists.", comment: "Error")
        case .SOURCE_UNDEFINED:
            return NSLocalizedString("Provide either code or file to load", comment: "Error")
        case .CANNOT_CREATE:
            return NSLocalizedString("Failed to create file/directory", comment: "Error")
        case .DOWNLOAD_ALREADY_INQUEUE:
            return NSLocalizedString("Download already in queue", comment: "Error")
        case .INVALID_PARAMETERS:
            return NSLocalizedString("Invalid/insufficient parameter", comment: "Error")
        case .ALREADY_EXISTS:
            return NSLocalizedString("File/directory already exists", comment: "Error")
        case .ONLY_DOCUMENT_TYPE:
            return NSLocalizedString("\(FilePathType.DOCUMENT_TYPE) can perform this action", comment: "Error")
        case .ONLY_URL_TYPE:
            return NSLocalizedString("\(FilePathType.URL_TYPE) can perform this action", comment: "Error")
        case .CANNOT_MOVE:
            return NSLocalizedString("Cannot move file/directory", comment: "Error")
        case .CANNOT_RENAME:
            return NSLocalizedString("Cannot rename file/directory", comment: "Error")
        case .CANNOT_COPY:
            return NSLocalizedString("Cannot copy file/directory", comment: "Error")
        case .CANNOT_DELETE:
            return NSLocalizedString("Cannot delete file/directory", comment: "Error")
        case .INVALID_FORMAT:
            return NSLocalizedString("Invalid Format", comment: "Error")
        case .NO_DATA:
            return NSLocalizedString("No Data available", comment: "Error")
        case .UNKNOWN_ERROR:
            return NSLocalizedString("Unknown Error occured", comment: "Error")
        case .ALREADY_UNZIPPED:
            return NSLocalizedString("The file may already have been unzipped", comment: "Error")
        case .INVALID_FILETYPE:
            return NSLocalizedString("This filetype cannot perform this command", comment: "Error")
        }
    }
}

public enum SystemFilePath:String {
    case DOCUMENT        = ""
    case DOWNLOADS      = "Downloads"
    case CACHE          = "_cache"
}

public enum FileExtention:String {
    case PNG            = "png"
    case JPG            = "jpg"
    case HEIC           = "heic"
    case JPEG           = "jpeg"
    case GIF            = "gif"
    case HTML           = "html"
    case ZIP            = "zip"
    case MP4            = "mp4"
    case MOV            = "mov"
    case M4V            = "m4v"
    case JS             = "js"
    case CSS            = "css"
    case TXT            = "txt"
    case ML             = "mlmodel"
    case UNSUPPORTED    = "unsupported"
}

public enum FilePathType:String {
    case DOCUMENT_TYPE  = "document"
    case BUNDLE_TYPE    = "bundle"
    case URL_TYPE       = "url"
    case ASSET_TYPE     = "asset"
    case ICLOUD_TYPE    = "icloud"
}

public enum FileType:String {
    case FILE           = "File"
    case HTML_FILE      = "HtmlFile"
    case IMAGE_FILE     = "ImageFile"
    case VIDEO_FILE     = "VideoFile"
    case ZIP_FILE       = "ZipFile"
}

class File {
    
    private var fileId:Int?
    private var fileName:String?
    private var path:String?
    private var pathType:FilePathType = FilePathType.DOCUMENT_TYPE
    private var filePath:URL!
    private var fileExtension:FileExtention?
    private var uploadSession:URLSession?
    static var counter = 0;
    static var UPLOADLIST:[File] = [File]()
    
    
    init(){}
    
    public init( fileId:Int, asset:String, filePath:URL ) {
        self.setID(fileId: fileId)
        self.setFileName(fileName: asset)
        self.setPathType(pathType: FilePathType.ASSET_TYPE )
        self.setFilePath(filePath: filePath )
    }
    
    public init( fileId:Int, document:String, filePath: URL ) {
        self.setID(fileId: fileId)
        self.setFileName(fileName: document)
        self.setPathType(pathType: FilePathType.DOCUMENT_TYPE)
        self.setFilePath(filePath: filePath)
    }
    
    public init( fileId:Int, document:String, path:String?=nil, filePath:URL?=nil ) throws {
        self.setID(fileId: fileId)
        self.setFileName(fileName: document)
        self.setPathType(pathType: FilePathType.DOCUMENT_TYPE)
        self.setPath(path: path)
        self.setFilePath(filePath: filePath)
        if !self.isFileExists() {
            throw FileError.INEXISTENT
        }
    }
    
    public init( fileId:Int, bundle:String, filePath: URL ) {
        self.setID(fileId: fileId)
        self.setFileName(fileName: bundle)
        self.setPathType(pathType: FilePathType.BUNDLE_TYPE)
        self.setFilePath(filePath: filePath)
    }
    public init( fileId:Int, bundle:String, path:String?=nil, filePath:URL?=nil ) throws {
        self.setID(fileId: fileId)
        self.setFileName(fileName: bundle)
        self.setPathType(pathType: FilePathType.BUNDLE_TYPE)
        self.setPath(path: path)
        self.setFilePath(filePath: filePath)
        if !self.isFileExists() {
            throw FileError.INEXISTENT
        }
    }
    
    public init( fileId:Int, path:String?=nil, filePath: URL ) {
        self.setID(fileId: fileId)
        self.setFilePath(filePath: filePath)
        self.setPath(path: path)
        self.setPathType(pathType: File.getFilePathType( filePath: filePath ).rawValue)
        if let fileName = filePath.absoluteString.getFilenameFromFilePath() {
            self.setFileName(fileName: fileName)
        }
    }
    
    public init( fileId:Int, file:Data, document:String, path:String?=nil ) throws {
        if let relativeURL = FileManager.getDocumentsDirectoryPath(pathType: .DOCUMENT_TYPE, relative: path) {
            if !FileManager.isExists(url: relativeURL) {
                if !FileManager.createDirectory(absolutePath: relativeURL.path) {
                    throw FileError.CANNOT_CREATE
                }
            }
            var isSuccess = false
            FileManager.saveDocument(file: file, filename: document, relative: path, onSuccess: { (filePath) in
                self.setID(fileId: fileId)
                self.setFileName(fileName: document)
                self.setPath(path: path)
                self.setFilePath(filePath: filePath)
                isSuccess = true
            }, onFail: { (errorMessage) in
                print( errorMessage )
                isSuccess = false
            })
            if !isSuccess {
                print("some problems")
                throw FileError.UNKNOWN_ERROR
            }
            
        } else {
            throw FileError.UNKNOWN_ERROR
        }
    }
    
    public init( fileId:Int, url:String ) throws {
        if url.isValidURL() {

            if let filePath = URL(string: url) {
                self.setFilePath(filePath: filePath)
            } else {
                throw FileError.INVALID_PARAMETERS
            }
            
            //getFilenameFromURL -> isValidURL -> canOpenURL needs to run in main
            //DispatchQueue.main.async {
                if let filename = url.getFilenameFromURL() {
                    self.setFileName(fileName: filename)
                }
            //}
            self.setPathType(pathType: FilePathType.URL_TYPE)
            self.setID(fileId: fileId)
        } else {
            throw FileError.INVALID_PARAMETERS
        }
    }
    
    convenience init( filedict: NSDictionary ) {
        let filePath:URL = URL( string: filedict.value(forKeyPath: "file_path") as! String )!
        let pathType = FilePathType( rawValue: filedict.value(forKeyPath: "path_type") as! String )!
        let fileId:Int! = filedict.value(forKeyPath: "file_id") as? Int ?? File.generateID()

        switch pathType {
        case .BUNDLE_TYPE:
            let fileName:String = filedict.value(forKeyPath: "filename") as! String
            self.init( fileId:fileId, bundle:fileName, filePath:filePath )
            return
        case .DOCUMENT_TYPE:
            let fileName:String = filedict.value(forKeyPath: "filename") as! String
            self.init( fileId:fileId, document:fileName, filePath:filePath )
            return
        case .URL_TYPE:
            self.init()
            self.setFilePath(filePath: filePath)
            self.setPathType(pathType: FilePathType.URL_TYPE)
            return
        case .ICLOUD_TYPE:
            print("IMPLELEMNT THIS")
            break
        default:
            break
        }
        self.init()
    }

    public convenience init( file:NSObject ) throws {
        var isValid = true

        let fileName:String? = file.value(forKeyPath: "filename") as? String
        let path:String? = file.value(forKeyPath: "path") as? String
        let fileId:Int! = file.value(forKeyPath: "file_id") as? Int ?? File.generateID()
        
        if let pathType = file.value(forKeyPath: "path_type") as? String {
            if let filePathType = FilePathType( rawValue: pathType ) {
                switch filePathType {
                case .ASSET_TYPE:
                    if let filePath = file.value(forKeyPath: "file_path") as? String {
                        self.init( fileId:fileId, asset:fileName!, filePath:URL(string:filePath)! )
                        return
                    } else {
                        isValid = false
                    }
                    break
                case .BUNDLE_TYPE:
                    if fileName != nil {
                        try self.init( fileId:fileId, bundle: fileName!, path:path)
                        return
                    } else {
                        isValid = false
                    }
                    break
                case .DOCUMENT_TYPE:
                    if fileName != nil {
                        try self.init( fileId:fileId, document: fileName!, path:path )
                        return
                    } else {
                        isValid = false
                    }
                    break
                case .URL_TYPE:
                    if path != nil {
                        try self.init( fileId:fileId, url: path! )
                        return
                    }else {
                        isValid = false
                    }
                    break
                default:
                    isValid = false
                    break
                }
                
            } else {
                isValid = false
            }
        } else {
            isValid = false
        }
        
        if !isValid {
            throw FileError.INVALID_PARAMETERS
        }
        self.init()
    }
    
    public func getStringContent() throws -> String? {
        switch( self.getFileExtension() ) {
        case .CSS, .HTML, .JS, .TXT:
            return try String(contentsOf: self.getFilePath()!, encoding: String.Encoding.utf8)
        default:
            break
        }
        throw FileError.INVALID_FILETYPE
    }
    
    public func update( dict:NSDictionary ) {
        if let fileName = dict.value(forKeyPath: "filename") as? String{
            self.setFileName(fileName: fileName)
        }
        if let fileExtension = dict.value(forKeyPath: "file_extension") as? String {
            if let fileExt = FileExtention.init(rawValue: fileExtension) {
                self.setFileExtension(fileext: fileExt)
            }
        }
        self.setPath(path: dict.value(forKeyPath: "path") as? String)
        if let filePath = dict.value(forKeyPath: "file_path") as? String {
            if let filePathURL = URL(string: filePath) {
                self.setFilePath(filePath: filePathURL)
            }
        }
        if let pathType = dict.value(forKeyPath: "path_type") as? String {
            if let pathTypeO = FilePathType.init(rawValue: pathType) {
                self.setPathType(pathType: pathTypeO)
            }
        }
    }
    
    func setID(fileId: Int) {
        if self.fileId == nil {
            self.fileId = fileId
        } else {
            print("[ERROR] File ID already set")
        }
    }
    func getID() -> Int {
        if self.fileId == nil {
            self.fileId = File.generateID()
        }
        return self.fileId!
    }
    public class func generateID() -> Int {
        File.counter += 1
        return File.counter
    }

    
    public func toDictionary() -> NSDictionary {
        let dict = NSMutableDictionary()
        if let filename = self.getFileName() {
            dict.setValue(filename, forKey: "filename")
        }
        if let path = self.getPath() {
            dict.setValue(path, forKey: "path")
        }
        if let pathType = self.getPathType() {
            dict.setValue(pathType.rawValue, forKey: "path_type")
        }
        if let filePath = self.getFilePath() {
            dict.setValue(filePath.absoluteString, forKey: "file_path")
        }
        dict.setValue(self.getFileExtension().rawValue, forKey: "file_extension")
        dict.setValue(self.getID(), forKey: "file_id")
        dict.setValue(self.getFileType().rawValue, forKey: "object_type")
        
        if let data = self.getFile() {
            dict.setValue(data.count, forKey: "size")
        }
        
        return dict
    }
    
    public func setFileName( fileName: String ) {
        self.fileName = fileName
        self.setFileExtension(fileext: File.getFileExtension(filename: fileName ))
    }
    public func getFileName() -> String? {
        return self.fileName
    }
    
    public func getUploadSession() -> URLSession? {
        return self.uploadSession
    }
    
    public func setPath( path:String?=nil ) {
        self.path = path
    }
    public func getPath() -> String? {
        return self.path
    }
    
    public func setFileExtension( fileext: FileExtention ) {
        self.fileExtension = fileext
    }
    public func getFileExtension() -> FileExtention {
        return self.fileExtension!
    }
    public class func getFileExtension( filename:String ) -> FileExtention {
        if let name = filename.lastIndexOf(target: ".") {
            if let fileext = FileExtention(rawValue: filename.substring(from: name + 1).lowercased() ) {
                return fileext
            }
        }
        return FileExtention.UNSUPPORTED
    }
    
    public func setPathType( pathType: FilePathType ) {
        self.pathType = pathType
    }
    public func setPathType( pathType: String ) {
        if let ptype = FilePathType(rawValue: pathType) {
            self.pathType = ptype
        }
    }
    public func getPathType() -> FilePathType? {
        return self.pathType
    }
    public func isFileExists() -> Bool {
        switch self.getPathType()! {
        case .ASSET_TYPE:
            return true
        case .URL_TYPE:
            if let filePath = self.getFilePath() {
                return filePath.absoluteString.isValidURL()
            }
        case .BUNDLE_TYPE, .DOCUMENT_TYPE, .ICLOUD_TYPE:
            if isFolderExists() {
                if let filePath = self.getFilePath() {
                    return FileManager.isExists(url: filePath)
                }
            }
        }
        return false
    }
    public func getFile() -> Data? {
        do {
            if let filePath = self.getFilePath() {
                return try Data(contentsOf: filePath)
            }
        } catch {}
        return nil
    }
    
    public func isFolderExists() -> Bool {
        if let dirPath = FileManager.getDocumentsDirectoryPath( pathType: self.pathType, relative: self.path ) {
            return FileManager.isExists(url: dirPath)
        }
        return false
    }
    
    public func setFilePath( filePath: URL?=nil ) {
        self.filePath = filePath
    }
    public func getFilePath() -> URL? {
        if self.filePath == nil {
            self.filePath = self.generateFilePath()
        }
        return self.filePath
    }
    
    private func generateFilePath() -> URL? {
        switch self.pathType {
        case FilePathType.BUNDLE_TYPE:
            if self.getFileName() == nil || (self.fileName?.isEmpty)! {
                return nil
            }
            let filename = self.getFileName()!.substring(from: 0, to: self.getFileName()!.indexOf(target: "."));
            let fileext = self.getFileName()!.substring(from: self.getFileName()!.indexOf(target: ".")! + 1, to: self.getFileName()!.length);
            
            if let url = Bundle.main.path(forResource: filename, ofType: fileext, inDirectory: self.getPath()!) {
                return URL( fileURLWithPath:url )
            }
            break
        case FilePathType.DOCUMENT_TYPE:
            if self.fileName == nil || (self.fileName?.isEmpty)! {
                return nil
            }
            return FileManager.generateDocumentFilePath(fileName: self.getFileName()!, relativePath: self.getPath())
        default:
            break
        }
        return nil
    }
    
    public class func getFileType( url: URL ) -> FileType {
        if let fileName = url.absoluteString.getFilenameFromFilePath() {
            if let dotIndex = fileName.indexOf(target: ".") {
                if let fileExt = FileExtention(rawValue: fileName.substring(from: dotIndex + 1).lowercased() ) {
                    return File.getFileType( fileExt: fileExt )
                }
            }
        }
        return .FILE
    }
    
    public func getFileType() -> FileType {
        if let filePath = self.getFilePath() {
            return File.getFileType( url: filePath )
        }
        return File.getFileType( fileExt: self.getFileExtension() )
    }
    
    public class func getFileType( fileExt: FileExtention ) -> FileType {
        switch fileExt {
        case .GIF, .JPEG, .JPG, .PNG, .HEIC:
            return .IMAGE_FILE
        case .M4V, .MP4, .MOV:
            return .VIDEO_FILE
        case .HTML:
            return .HTML_FILE
        case .ZIP:
            return .ZIP_FILE
        default:
            return .FILE
        }
    }
    
    public class func getMimeType( fileType: FileType ) -> String {
        switch fileType {
            case .IMAGE_FILE:
                return "image"
            case .VIDEO_FILE:
                return "video"
            case .HTML_FILE:
                return "text"
            case .ZIP_FILE:
                return "application"
            case .FILE:
                return "application"
        }
    }
    
    public func getMimeType() -> String {
        return File.getMimeType( fileType: self.getFileType() )
    }
    
    public class func getFilePathType( filePath: URL ) -> FilePathType {
        if filePath.absoluteString.contains("file:///private/var/mobile/Containers/Data/Application") {
            return .DOCUMENT_TYPE
        } else if filePath.absoluteString.contains("file:///private/var/containers/Bundle/Application") {
            return .BUNDLE_TYPE
        } else if filePath.absoluteString.contains("assets-library://asset/") {
            return .ASSET_TYPE
        } else if filePath.absoluteString.contains("http") || filePath.absoluteString.contains("ftp") {
            return .URL_TYPE
        }
    
        return .DOCUMENT_TYPE
    }

    public func getBase64Value( onSuccess:@escaping ((String)->()), onFail:@escaping ((String)->()) ) {
        switch self.getPathType()! {
        case .BUNDLE_TYPE, .DOCUMENT_TYPE:
            if let file = self.getFile() {
                onSuccess( Utility.shared.DataToBase64(data: file) )
                return
            }
            onFail( FileError.INVALID_FORMAT.localizedDescription + ":  \(self.getFileExtension())" )
            break
        default:
            onFail( FileError.UNKNOWN_ERROR.localizedDescription )
            break
        }
    }

    public class func getFileObject( url:URL ) {
        //file:///var/mobile/Containers/Data/Application/11A53667-B394-4175-9BE0-7667B666D3B7/Documents/sample.mp4
        //file:///var/containers/Bundle/Application/4EB9C028-2932-473D-A0D2-DDD915F2C3F0/Luna.app/resource/index.html
        //file:///private/var/mobile/Containers/Data/Application/A2B7116C-796D-493A-B0A1-B04F1AD26CD5/tmp/51316933297__C7247589-153A-4F6A-BCFA-73A9518ED50E.MOV
        //assets-library://asset/asset.MOV?id=B49A35C0-9DF0-418B-ADD4-9D5B8A33C1D4&ext=MOV
        
        
//        if let fileName = url.path.getFilenameFromURL() {
//            if let fileExt = FileExtention(rawValue: fileName.substring(from: fileName.indexOf(target: ".")! + 1).lowercased() ) {
//                let fileType = File.getFileType(fileExt: fileExt)
//
//            }
//        }
        
    }
    
    public func copy( relative:String?="", onSuccess:((URL)->())?=nil, onFail:((String)->())?=nil ) -> Bool {
        if self.getPathType() == .URL_TYPE {
            if onFail != nil {
                onFail!( FileError.CANNOT_COPY.localizedDescription )
            }
            return false
        }
        if let relativeURL = FileManager.getDocumentsDirectoryPath(pathType: .DOCUMENT_TYPE, relative: relative) {
            if !FileManager.isExists(url: relativeURL) {
                if !FileManager.createDirectory(absolutePath: relativeURL.path) {
                    if onFail != nil {
                        onFail!( FileError.CANNOT_CREATE.localizedDescription )
                    }
                    return false
                }
            }
        }
        if let filePath = self.getFilePath() {
            return FileManager.copyFile( filePath: filePath, relativeTo: relative, onSuccess:onSuccess, onFail:onFail)
        }
        if onFail != nil {
            onFail!( FileError.CANNOT_COPY.localizedDescription )
        }
        return false
    }
    
    public func rename( fileName:String, onSuccess:@escaping((URL)->()), onFail:((String)->())?=nil  ) -> Bool {
        if self.getPathType() != .DOCUMENT_TYPE {
            if onFail != nil {
                onFail!( FileError.ONLY_DOCUMENT_TYPE.localizedDescription )
            }
            return false
        }
        if let filePath = self.getFilePath() {
            return FileManager.renameFile(fileName: fileName, filePath: filePath, onSuccess: { result in
                self.setFileName(fileName: fileName)
                self.setFilePath(filePath: result)
                onSuccess( result )
            }, onFail:onFail)
        }
        if onFail != nil {
            onFail!( FileError.CANNOT_RENAME.localizedDescription )
        }
        return false
    }
    
    
    public func move( relative:String?=nil, isOverwrite:Bool?=false, onSuccess:@escaping((URL)->()), onFail:((String)->())?=nil ) -> Bool {
        if self.getPathType() != .DOCUMENT_TYPE {
            if onFail != nil {
                onFail!( FileError.ONLY_DOCUMENT_TYPE.localizedDescription )
            }
            return false
        }
        if let relativeURL = FileManager.getDocumentsDirectoryPath(pathType: .DOCUMENT_TYPE, relative: relative) {
            if let file = FileManager.generateDocumentFilePath(fileName: self.getFileName()!, relativePath: relative ) {
                if FileManager.isExists(url: file ) {
                    if isOverwrite! {
                        if !FileManager.deleteFile(filePath: file) {
                            if onFail != nil {
                                onFail!( FileError.CANNOT_DELETE.localizedDescription )
                            }
                            return false
                        }
                    } else {
                        if onFail != nil {
                            onFail!( FileError.ALREADY_EXISTS.localizedDescription )
                        }
                        return false
                    }
                }
            }

            if !FileManager.isExists(url: relativeURL) {
                if !FileManager.createDirectory(absolutePath: relativeURL.path) {
                    if onFail != nil {
                        onFail!( FileError.CANNOT_CREATE.localizedDescription )
                    }
                    return false
                }
            }
            if let fileName = self.getFileName() {
                return FileManager.moveFile(document: fileName, relativeFrom: self.getPath(), relativeTo: relative, onSuccess:{ result in
                    self.setPath(path: relative)
                    self.setFilePath(filePath: result)
                    onSuccess( result )
                }, onFail: onFail)
            }
        }
        if onFail != nil {
            onFail!( FileError.CANNOT_MOVE.localizedDescription )
        }
        return false
    }
    
    public func delete( onSuccess:@escaping ((Bool)->()), onFail:((String)->())?=nil ) -> Bool {
        if( self.pathType == .DOCUMENT_TYPE ) {
            if let filePath = self.getFilePath() {
                return FileManager.deleteFile(filePath: filePath, onSuccess:{
                    self.filePath = nil
                    onSuccess(true)
                }, onFail:onFail )
            }
        } else {
            if onFail != nil {
                onFail!(FileError.ONLY_DOCUMENT_TYPE.localizedDescription)
            }
            return false
        }
        if onFail != nil {
            onFail!(FileError.CANNOT_DELETE.localizedDescription)
        }
        return false
    }

//    public func share( onSuccess:@escaping((Bool)->()), onFail:@escaping ((String)->()) ) {
//        if let filePath = self.getFilePath() {
//            FileManager.share(filePaths: [filePath], onSuccess: onSuccess )
//        } else {
//            onFail( FileError.INVALID_PARAMETERS.localizedDescription )
//        }
//    }
    
    func uploadFile( base64:String?="", callback: @escaping ((Bool, String?)->()) ) {
        let upload = { (base64String:String)->() in
            Utility.shared.getAccessToken(username     : Shared.shared.username,
                                   password     : Shared.shared.password,
                                   clientId     : Shared.shared.clientId,
                                   clientSecret : Shared.shared.clientSecret ) { access_token in
                if( access_token != nil ) {
                    
                    let headers:[String: String] = [
                        "Authorization" : "Bearer \(access_token!)",
                        "Content-Type"  : "application/json;charset=UTF-8"
                    ]
                
                    let data:[String: Any] = [
                        "Title"             : self.getFileName()!,
                        "PathOnClient"      : self.getFileName()!,
                        "ContentLocation"   : "S",
                        "VersionData"       : base64String
                    ]

                    let _ = Ajax.instance.request(
                        urlString   : Shared.shared.link + "/services/data/v44.0/sobjects/ContentVersion",
                        method      : "POST",
                        data        : data as NSDictionary,
                        headers     : headers as NSDictionary,
                        onSuccess   : { response in
                            guard let success = response.value(forKey: "success") as? Bool else {
                                callback( false, "Malformed request" )
                                return
                            }
                            if success {
                                callback(true, response.value(forKey: "id") as? String)
                            } else {
                                callback(false, "Error occured")
                            }
                        }, onFail   : { message in
                            print( message )
                        }
                    )
                }
            }
        }
        
        if base64 != nil {
            upload( base64! )
        } else {
            self.getBase64Value { _base64 in
                upload( _base64 )
            } onFail: { errorMessage in
                callback(false, errorMessage)
            }
        }
    }
    
    func upload( appid:Int, onSuccess:((Any)->())?=nil, onFail:((String)->())?=nil ) {
        if self.getPathType() != .DOCUMENT_TYPE {
            if onFail != nil {
                onFail!( FileError.ONLY_DOCUMENT_TYPE.localizedDescription )
            }
        }
        
        var parameter               = [String: Any]()
        parameter[ "url" ]          = "\(Shared.shared.server)/file-upload"
        parameter[ "method" ]       = "POST"
        
        var headers                 = [String: String]()
        headers[ "Content-Type" ]   = "application/json"
        headers[ "Accept" ]         = "application/json"
        parameter[ "headers" ]      = headers
        
//        guard let userid = SystemSettings.instance.get(key: "id") else {
//            onFail?( "userid is not available" )
//            return
//        }
        
//        var data = [String: Any]()
//        data[ "userid" ] = userid
//        data[ "appid" ] = appid
//        data[ "filename" ] = self.getFileName()!
//        data[ "type" ] = self.getMimeType() + "/" + self.getFileExtension().rawValue
//        data[ "base64" ] = Utility.shared.DataToBase64(data: self.getFile()!)
//        parameter[ "data" ] = data
        var multipart               = [String: Any]()
        multipart[ "userid" ]       = 1234
        multipart[ "appid" ]        = appid
        multipart[ "filename" ]     = self.getFileName()!
        multipart[ "type" ]         = self.getMimeType() + "/" + self.getFileExtension().rawValue
        multipart[ "fileInstance" ] = self
        //multipart[ "size" ]         = self.getFile()!.count
        parameter[ "multipart" ]    = multipart
        
        
        print("MATO UPLOADING=========")
        print(multipart)
        
        if( self.addUpload() ) {
            uploadSession = Ajax.instance.request(urlString: parameter["url"] as! String, method: parameter[ "method" ] as? String, multipart: multipart as NSDictionary, headers: headers as NSDictionary, onSuccess: { (result) in
                print("UPLOAD RESULT", result)
                onSuccess?( result )
                self.removeUpload()
            }) { (errorMessage) in
                print(errorMessage)
                onFail?("Server error occured")
                self.removeUpload()
            }
        } else {
            onFail?("File already in upload queue")
            self.removeUpload()
        }
    }
    
    private func addUpload() -> Bool {
        if let _ = File.getToBeUploadedFile( fileId: self.getID() ) {
            print("File to be uploaded already in queue")
            return false
        }
        File.UPLOADLIST.append( self )
        return true
    }
    public class func getToBeUploadedFile( fileId:Int ) -> File? {
        for (_, file) in File.UPLOADLIST.enumerated() {
            if  file.getID() == fileId{
                return file
            }
        }
        return nil
    }
    private func removeUpload() {
        File.removeUpload( file: self )
        print("Removed file from to be upload list \(self.getID())")
    }
    public class func removeUpload( file: File ) {
        for ( index, ufile) in File.UPLOADLIST.enumerated() {
            if ufile === file {
                File.UPLOADLIST.remove(at: index)
            }
        }
    }

//    public func download( to:String?=nil, isOverwrite:Bool?=false, onSuccess:@escaping((Int)->()), onFail:((String)->()) ) {
//        do {
//            let manager = try DownloadManager(file: self, savePath: to, isOverwrite:isOverwrite)
//            onSuccess( manager.getID() )
//            manager.onDownload()
//        } catch let error as NSError {
//            onFail( error.localizedDescription )
//        }
//    }

}
