/*
 * The MIT License(MIT)
 *
 * Copyright(c) 2016 Copyleaks LTD (https://copyleaks.com)
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 *
 */

import Foundation
import MobileCoreServices

// MARK: - Convenience

public class CopyleaksApi {
    
    /* Private Api parameters */
    
    private var rout: String = ""
    private var method: CopyleaksHTTPMethod = .GET
    private var parameters: [String: AnyObject]? = nil
    
    /**
     The background completion handler closure provided by the UIApplicationDelegate
     'application:handleEventsForBackgroundURLSession:completionHandler: method. By setting the background
     completion handler, the SessionDelegate `sessionDidFinishEventsForBackgroundURLSession` closure implementation
     will automatically call the handler.
     */

    public var backgroundCompletionHandler: (() -> Void)?
    
    let queue = dispatch_queue_create(nil, DISPATCH_QUEUE_SERIAL)
    public let session: NSURLSession
    public let delegate: CopyleaksSessionDelegate
    
    
    /* Copyleaks headers */
    private var headers: [String: String] = [String: String]()
    
    /* Init Api */
    
    public init (
        method: CopyleaksHTTPMethod,
        rout: String,
        parameters: [String: AnyObject]? = nil,
        headers: [String: String]? = nil)
    {
        self.method = method
        self.rout = rout
        self.parameters = parameters
        
        if headers != nil {
            self.headers = headers!
        }

        // Configure default headers
        
        self.headers[CopyleaksConst.cacheControlHeader] = CopyleaksConst.cacheControlValue
        self.headers[CopyleaksConst.contentTypeHeader] = CopyleaksHTTPContentType.JSON
        self.headers[CopyleaksConst.userAgentHeader] = CopyleaksConst.userAgentValue
        self.headers[CopyleaksConst.acceptLanguageHeader] = CopyleaksConst.defaultAcceptLanguage

        // Configure Authorization header
        
        if let token = CopyleaksToken.getAccessToken()?.generateAccessToken() {
            self.headers["Authorization"] = token
        }
        
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        config.HTTPAdditionalHeaders = self.headers
        self.delegate = CopyleaksSessionDelegate()
        self.session = NSURLSession(configuration: config, delegate: delegate, delegateQueue: nil)
        delegate.sessionDidFinishEventsForBackgroundURLSession = { [weak self] session in
            guard let strongSelf = self else { return }
            dispatch_async(dispatch_get_main_queue()) { strongSelf.backgroundCompletionHandler?() }
        }
        
    }
    
    // MARK: - Request Methods
    
    /* Request constructor */
  
    private func configureRequest(
        _ URL: NSURL,
          body: NSData? = nil) -> NSMutableURLRequest
    {
        let mutableURLRequest = NSMutableURLRequest(URL: URL)
        mutableURLRequest.HTTPMethod = method.rawValue
        
        for (headerField, headerValue) in headers {
            mutableURLRequest.setValue(headerValue, forHTTPHeaderField: headerField)
        }
        
        if let data = body {
            mutableURLRequest.HTTPBody = data
        }
        
        return mutableURLRequest
    }

    
    /**
     Creates a request
     - parameter body:  The Copyleaks request body. Dafault value is 'nil'.
     
     - returns: The created request.
     */
    
    public func request(body: NSData? = nil) -> CopyleaksRequest
    {
        
        let components = NSURLComponents()
        components.scheme = "https"
        components.host = CopyleaksConst.serviceHost
        components.path = "/" + CopyleaksConst.serviceVersion + "/" + rout
        
        let mutableURLRequest = self.configureRequest(
            components.URL!,
            body: body)
        
        do {
            if parameters != nil {
                let options = NSJSONWritingOptions()
                let data = try NSJSONSerialization.dataWithJSONObject(parameters!, options: options)
                mutableURLRequest.HTTPBody = data
            }
        } catch {
            assert(true, "Incorrect encoding")
        }
        
        var dataTask: NSURLSessionDataTask!
        dispatch_sync(queue) { dataTask = self.session.dataTaskWithRequest(mutableURLRequest.mutableCopy() as! NSMutableURLRequest) }
        
        let request = CopyleaksRequest(session: session, task: dataTask)
        delegate[request.delegate.task] = request.delegate
        request.resume()
        
        return request
        
    }
    
    // MARK: - Upload Methods
    
    /**
     Creates a request for uploading File to the specified URL request.
     - parameter fileURL:   The File URL.
     - parameter language:  The Language Code that identifies the language of the content.
     
     - returns: The created upload request.
     */
    
    public func uploadFile (
        _ fileURL : NSURL,
          language: String)
        -> CopyleaksRequest
    {
        let components = NSURLComponents()
        components.scheme = "https"
        components.host = CopyleaksConst.serviceHost
        components.path = "/" + CopyleaksConst.serviceVersion + "/" + rout
        components.query = "language=" + language
        
        let boundary = generateBoundary()
        var uploadData = NSMutableData()
        uploadData.appendData("--\(boundary)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        
        if let
            fileName = fileURL.lastPathComponent,
            pathExtension = fileURL.pathExtension,
            uploadFile: NSData = NSFileManager.defaultManager().contentsAtPath(fileURL.absoluteString)
        {
            let mimeType = mimeTypeForPathExtension(pathExtension)
            
            uploadData.appendData("Content-Disposition: form-data; name=\"file\"; filename=\"\(fileName).\(pathExtension)\"\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
            uploadData.appendData("Content-Type: \(mimeType)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
            let strBase64:String = uploadFile.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
            uploadData.appendData("Content-Transfer-Encoding: binary\r\n\r\n\(strBase64)".dataUsingEncoding(NSUTF8StringEncoding)!)
            uploadData.appendData("\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        }
        uploadData.appendData("--\(boundary)--\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        
        // Configure headers
        
        headers["Accept"] = "application/json"
        headers[CopyleaksConst.contentTypeHeader] = "multipart/form-data;boundary="+boundary
        headers["Content-Length"] = String(uploadData.length)
        
        
        let mutableURLRequest = self.configureRequest(
            components.URL!,
            body: uploadData)

        var uploadTask: NSURLSessionUploadTask!
        dispatch_sync(queue) {
            uploadTask = self.session.uploadTaskWithRequest(mutableURLRequest, fromData: uploadData)
            //uploadTask = self.session.dataTaskWithRequest(mutableURLRequest)
        }
        
        let request = CopyleaksRequest(session: session, task: uploadTask)
        delegate[request.delegate.task] = request.delegate
        request.resume()
        return request
    }
    
    
    /* Configure MIME type from path */
    
    private func mimeTypeForPathExtension(pathExtension: String) -> String {
        if let
            id = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension, nil)?.takeRetainedValue(),
            contentType = UTTypeCopyPreferredTagWithClass(id, kUTTagClassMIMEType)?.takeRetainedValue()
        {
            return contentType as String
        }
        return "application/octet-stream"
    }
    
    
    /* Boundary generator */
    
    private func generateBoundary() -> String {
        return String(format: "copyleaks.boundary.%08x%08x", arc4random(), arc4random())
    }
    
    /**
     Callbacks optional headers
     Copyleaks API supports two types of completion callbacks that are invoked once the process has
     been completed, with or without success.
     When using callbacks, there is no need to check the request's status manually. We will automatically
     inform you when the process has completed running and the results are ready.
     */
    
    public func configureOptionalHeaders(
        _ httpCallback: String? = nil,
          _ emailCallback: String? = nil,
            _ clientCustomMessage: String? = nil,
              _ allowPartialScan: Bool = false)
    {
        if Copyleaks.sharedSDK.sandboxMode {
            headers["copyleaks-sandbox-mode"] = "true"
        }
        if allowPartialScan {
            headers["copyleaks-allow-partial-scan"] = "true"
        }
        if let val = httpCallback {
            headers["copyleaks-http-callback"] = val
        }
        if let val = emailCallback {
            headers["copyleaks-email-callback"] = val
        }
        if let val = clientCustomMessage {
            headers["copyleaks-client-custom-Message"] = val
        }
    }

}
