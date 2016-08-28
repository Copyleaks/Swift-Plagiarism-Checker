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


// MARK: - Copyleaks response serializer

public protocol CopyleaksResponseSerializerType {
    associatedtype JSON
    associatedtype Error: NSError
    /**
     A closure used by response handlers that takes a request, response, data and error and returns a result.
     */
    var serializeResponse: (NSURLRequest?, NSHTTPURLResponse?, NSData?, NSError?) -> CopyleaksResult<JSON, Error> { get }
}

/**
 A generic CopyleaksResponseSerializerType used to serialize a request, response, and data into a serialized object.
 */

public struct CopyleaksResponseSerializer<JSON, Error: NSError>: CopyleaksResponseSerializerType {
    public typealias SerializedObject = JSON
    public typealias ErrorObject = Error
    
    /**
     A closure used by response handlers that takes a request, response, data and error and returns a result.
     */
    public var serializeResponse: (NSURLRequest?, NSHTTPURLResponse?, NSData?, NSError?) -> CopyleaksResult<JSON, Error>
    
    /**
     Initializes the CopyleaksResponseSerializer instance with the given serialize response closure.
     - parameter serializeResponse: The closure used to serialize the response.
     - returns: The new generic response serializer instance.
     */
    public init(serializeResponse: (NSURLRequest?, NSHTTPURLResponse?, NSData?, NSError?) -> CopyleaksResult<JSON, Error>) {
        self.serializeResponse = serializeResponse
    }
}

/* Used to store all response data returned from a completed `Request`. */

public struct CopyleaksResponse<Value, Error: NSError> {
    
    /* The URL request sent to the server. */
    public let request: NSURLRequest?
    
    /* The server's response to the URL request. */
    public let response: NSHTTPURLResponse?
    
    /* The data returned by the server. */
    public let data: NSData?
    
    public let result: CopyleaksResult<Value, Error>
    
    /**
     Initializes the `Response` instance with the specified URL request, URL response, server data and response
     serialization result.
     
     - parameter request:  The URL request sent to the server.
     - parameter response: The server's response to the URL request.
     - parameter data:     The data returned by the server.
     - parameter result:   The result of response serialization. (not nil)
     
     - returns: the new `Response` instance.
     */
    public init(request: NSURLRequest?, response: NSHTTPURLResponse?, data: NSData?, result: CopyleaksResult<Value, Error>) {
        self.request = request
        self.response = response
        self.data = data
        self.result = result
    }
    
}

extension CopyleaksRequest {
    
    /**
     Adds a handler to be called once the request has finished.
     
     - parameter queue:              The queue on which the completion handler is dispatched.
     - parameter responseSerializer: The response serializer responsible for serializing the request, response, and data.
     - parameter completionHandler:  The code to be executed once the request has finished.
     
     - returns: The request.
     */
    public func response<T: CopyleaksResponseSerializerType>(
        queue queue: dispatch_queue_t? = nil,
              responseSerializer: T,
              completionHandler: CopyleaksResponse<T.JSON, T.Error> -> Void)
        -> Self
    {
        delegate.queue.addOperationWithBlock {
            let result = responseSerializer.serializeResponse(
                self.request,
                self.response,
                self.delegate.data,
                self.delegate.error
            )
            
            let response = CopyleaksResponse<T.JSON, T.Error>(
                request: self.request,
                response: self.response,
                data: self.delegate.data,
                result: result
            )
            
            dispatch_async(queue ?? dispatch_get_main_queue()) {
                if self.delegate.data != nil {
                    let datastring = NSString(data: self.delegate.data!, encoding: NSUTF8StringEncoding)
                    print(">>> response str: \(datastring)")
                } else {
                    print(">>> response str: nil")
                }
                
                completionHandler(response)
            }
        }
        return self
    }
    
    /**
     Creates a response serializer that returns a JSON object constructed from the response data using
     `NSJSONSerialization` with the specified reading options.
     
     - parameter options: The JSON serialization reading options. `.AllowFragments` by default.
     
     - returns: A JSON object response serializer.
     */
    
    public static func JSONResponseSerializer(options options: NSJSONReadingOptions = .AllowFragments) -> CopyleaksResponseSerializer<AnyObject, NSError> {
        return CopyleaksResponseSerializer { _, response, data, error in

            if let copyleaksErrorCode = response?.allHeaderFields["copyleaks-error-code"] {
                let code:Int = Int(copyleaksErrorCode as! String)!
                do {
                    let JSON = try NSJSONSerialization.JSONObjectWithData(data!, options: options)
                    if let errorMessage: String = JSON["Message"] as? String {
                        return .Failure(NSError.error(code, message: errorMessage))
                    } else {
                        return .Failure(NSError.error(code))
                    }
                } catch {
                    return .Failure(NSError.error(code))
                }
            }
            
            guard error == nil else { return .Failure(error!) }
            
            if let response = response where response.statusCode == 204 { return .Success(NSNull()) }
            
            guard let validData = data where validData.length > 0 else {
                let message = "JSON could not be serialized. Input data was nil or zero length."
                return .Failure(NSError.error(0, message: message))
            }
            
            do {
                let JSON = try NSJSONSerialization.JSONObjectWithData(validData, options: options)
                return .Success(JSON)
            } catch {
                return .Failure(error as! NSError)
            }
        }
    }

    /**
     Adds a handler to be called once the request has finished.
     - parameter queue:             The queue on which the completion handler is dispatched.
     - parameter options:           The JSON serialization reading options. `.AllowFragments` by default.
     - parameter completionHandler: A closure to be executed once the request has finished.
     
     - returns: The request.
     */
    
    public func responseJSON(queue queue: dispatch_queue_t? = nil, options: NSJSONReadingOptions = .AllowFragments, completionHandler: CopyleaksResponse<AnyObject, NSError> -> Void) -> Self {
        return response (
            queue: queue,
            responseSerializer: CopyleaksRequest.JSONResponseSerializer(options: options),
            completionHandler: completionHandler
        )
    }

}

/* Copyleaks NSError extension */

extension NSError {
    static func error(code: Int = 0, message: String? = nil) -> NSError {
        let userInfo = [NSLocalizedFailureReasonErrorKey: message ?? "Unknown error"]
        return NSError(domain: CopyleaksConst.errorDomain, code: code, userInfo: userInfo)
    }
}


