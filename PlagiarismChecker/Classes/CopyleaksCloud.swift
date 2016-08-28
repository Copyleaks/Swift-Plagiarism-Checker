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

public class CopyleaksCloud {
    
    public typealias CopyleaksSuccessBlock = (result: CopyleaksResult<AnyObject, NSError>) -> Void
    public var successBlock: CopyleaksSuccessBlock?
    
    /**
     Callbacks
     Copyleaks API supports two types of completion callbacks that are invoked once the process has 
     been completed, with or without success.
     When using callbacks, there is no need to check the request's status manually. We will automatically 
     inform you when the process has completed running and the results are ready.
     */
    
    /* Copyleaks product type. Default is businesses */
    public var productType: CopyleaksProductType = .Businesses
    

    /**
     HTTP-Callbacks
     Add the Http request header copyleaks-http-callback with the URL of your endpoint.
     Tracking your processes is available by adding the token process ID {PID} as a parameter
     to your URL. This will allow you to follow each process individually.
     */
    
    public var httpCallback: String?
    
    
    /**
     Email-Callbacks
     Register a callback email to get informed when the request has been completed.
     When the API request status is complete, you will get an email to your inbox and
     the scan results will be available, using the result (Academic \ Businesses) method.
     */
    
    public var emailCallback: String?
    
    /**
     Custom Fields
     You can add custom payload to the request headers. The payload is stored in a
     'dictionary' representing a collection of string key and string value pairs.
     */
    
    public var clientCustomMessage: String?
    
    /**
     Allow Partial Scan
     If you don't have enough credits to scan the entire submitted text, part of the
     text will be scanned, according to the amount of credits you have left.
     
     For example, you have 5 credits and you would like to scan text that requires 10 credits.
     If you added the copyleaks-allow-partial-scanto your request only 5 pages out of 10 will
     be scanned. Otherwise, none of the pages will be scanned and you will get back an error
     messsage stating that you don't have enough credits to complete the scan.
     */
    
    public var allowPartialScan: Bool = false


    /* Generate current language */
    
    static let acceptLanguage: String = NSLocale.preferredLanguages().prefix(6).enumerate().map { index, languageCode in
        return "\(languageCode)"
        }.joinWithSeparator(", ")
    
    /**
     Initializes the CopyleaksCloud instance with the specified configuration and delegate;
     - parameter product: The product type. Dafault value from Copyleaks
     */

    public init(
        _ product: CopyleaksProductType? = Copyleaks.sharedSDK.productType)
    {
        if product != nil {
            Copyleaks.setProduct(product!)
        }
    }
    //deinit { session.invalidateAndCancel() }

    
    // MARK: - Public Api methods
    
    /* Login to the Copyleaks API using your email and API key */
    
    public func login(
        email:String,
        apiKey: String,
        success: (result: CopyleaksResult<AnyObject, NSError>) -> Void)
    {
        var params:[String: AnyObject] = [String: AnyObject]()
        params["Email"] = email
        params["ApiKey"] = apiKey
        
        let api = CopyleaksApi(
            method: .POST,
            rout: "account/login-api",
            parameters: params,
            headers: nil)
        
        api.request().responseJSON { (response) in
            let token = CopyleaksToken(response: response)
            token.save()
            success(result: response.result)
        }
    }
    
    
    /* Starting a new process by providing a URL to scan. */
    
    public func createByUrl(
        url: NSURL,
        success: CopyleaksSuccessBlock?)
    {
        var params:[String: AnyObject] = [String: AnyObject]()
        params["Url"] = url.absoluteString
        
        let api = CopyleaksApi(
            method: .POST,
            rout: productType.rawValue.lowercaseString + "/create-by-url",
            parameters: params,
            headers: nil)
        
        api.configureOptionalHeaders(
            httpCallback,
            emailCallback,
            clientCustomMessage,
            allowPartialScan)
        
        api.request().responseJSON { (response) in
            success?(result: response.result)
        }
        
    }
    
    /* Starting a new process by providing a file to scan. */

    public func createByFile(
        fileURL fileURL: NSURL,
                language: String,
                success: CopyleaksSuccessBlock?)
    {
        let api = CopyleaksApi(
            method: .POST,
            rout: productType.rawValue.lowercaseString + "/create-by-file",
            parameters: nil,
            headers: nil)
        
        api.configureOptionalHeaders(
            httpCallback,
            emailCallback,
            clientCustomMessage,
            allowPartialScan)
        
        api.uploadFile(
            fileURL,
            language: language).responseJSON { (response) in
                success?(result: response.result)
        }
    }

    /* Starting a new process by providing a text to scan. */
    
    public func createByText(
        text: String,
        success: CopyleaksSuccessBlock?)
    {
        let api = CopyleaksApi(
            method: .POST,
            rout: productType.rawValue.lowercaseString + "/create-by-text",
            parameters: nil,
            headers: nil)
        
        api.configureOptionalHeaders(
            httpCallback,
            emailCallback,
            clientCustomMessage,
            allowPartialScan)
        
        let body = text.dataUsingEncoding(NSUTF8StringEncoding)
        
        api.request(body).responseJSON { (response) in
            success?(result: response.result)
        }
    }
    
    /* Starting a new process by providing a photo with text. */
    
    public func createByOCR(
        fileURL fileURL: NSURL,
                language: String,
                success: CopyleaksSuccessBlock?)
    {
        let api = CopyleaksApi(
            method: .POST,
            rout: productType.rawValue.lowercaseString + "/create-by-file-ocr",
            parameters: nil,
            headers: nil)
        
        api.configureOptionalHeaders(
            httpCallback,
            emailCallback,
            clientCustomMessage,
            allowPartialScan)
        
        api.uploadFile(
            fileURL,
            language: language).responseJSON { (response) in
                success?(result: response.result)
        }
    }
    
    /* Get the scan progress details using the processId. */
    
    public func statusProcess(
        processId: String,
        success: CopyleaksSuccessBlock?)
    {
        let api = CopyleaksApi(
            method: .GET,
            rout: productType.rawValue.lowercaseString + "/" + processId + "/status",
            parameters: nil,
            headers: nil)
        
        api.request().responseJSON { (response) in
            success?(result: response.result)
        }
    }
    
    /* Get the results using the processId. */
    
    public func resultProcess(
        processId: String,
        success: CopyleaksSuccessBlock?)
    {
        let api = CopyleaksApi(
            method: .GET,
            rout: productType.rawValue.lowercaseString + "/" + processId + "/result",
            parameters: nil,
            headers: nil)
        
        api.request().responseJSON { (response) in
            success?(result: response.result)
        }
    }
    
    /* 
     * Delete the specific process from the server, after getting the scan results.
     * Only completed processes can be deleted.
     */
    
    public func deleteProcess(
        processId: String,
        success: CopyleaksSuccessBlock?)
    {
        let api = CopyleaksApi(
            method: .DELETE,
            rout: productType.rawValue.lowercaseString + "/" + processId + "/delete",
            parameters: nil,
            headers: nil)
        
        api.request().responseJSON { (response) in
            success?(result: response.result)
        }
    }

    /* Receive a list of all your active processes. */
    
    public func processesList(
        success: CopyleaksSuccessBlock?)
    {
        let api = CopyleaksApi(
            method: .GET,
            rout: productType.rawValue.lowercaseString + "/list",
            parameters: nil,
            headers: nil)
        
        api.request().responseJSON { (response) in
            success?(result: response.result)
        }
    }
    
    /* Get count of credits */
    
    public func countCredits(
        success: CopyleaksSuccessBlock?)
    {
        let api = CopyleaksApi(
            method: .GET,
            rout: productType.rawValue.lowercaseString + "/count-credits",
            parameters: nil,
            headers: nil)
        
        api.request().responseJSON { (response) in
            success?(result: response.result)
        }
    }
    
    /* Get full list of the supported OCR languages. */
  
    public func languagesList(
        success: CopyleaksSuccessBlock?)
    {
        let api = CopyleaksApi(
            method: .GET,
            rout: "/miscellaneous/ocr-languages-list",
            parameters: nil,
            headers: nil)
        
        api.request().responseJSON { (response) in
            success?(result: response.result)
        }
    }

    /* Get list of the supported file types . */
    
    public func supportedFileTypes(
        success: CopyleaksSuccessBlock?)
    {
        let api = CopyleaksApi(
            method: .GET,
            rout: "/miscellaneous/supported-file-types",
            parameters: nil,
            headers: nil)
        
        api.request().responseJSON { (response) in
            success?(result: response.result)
        }
    }

}
