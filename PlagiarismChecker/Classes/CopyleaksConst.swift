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

/* HTTP method definitions. */

public enum CopyleaksHTTPMethod: String {
    case GET, POST, PUT, DELETE
}

/* HTTP Content Type. */

public struct CopyleaksHTTPContentType {
    public static let JSON          = "application/json"
    public static let URLEncoded    = "application/x-www-form-urlencoded"
    public static let Multipart     = "multipart/form-data"
}

public struct CopyleaksConst {
    
    /* Default Accept language */
    public static let defaultAcceptLanguage: String = "en-US"
    
    /* Base api url */
    public static let serviceHost: String = "api.copyleaks.com"
    
    /* Api version */
    public static let serviceVersion: String = "v1"
    
    /* Datetime format*/
    public static let dateTimeFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'";
    public static let creationDateTimeFormat = "dd/MM/yyyy HH:mm:ss";
    

    /* Content-Type header */
    public static let contentTypeHeader:String = "Content-Type"
    
    /* Accept-Language header */
    public static let acceptLanguageHeader:String = "Accept-Language"
    
    /* User-Agent header */
    public static let userAgentHeader:String = "User-Agent"
    /* User-Agent value */
    public static let userAgentValue: String = "CopyleaksSDK/1.0"
    
    /* Cache-Control header & value */
    public static let cacheControlHeader: String = "Cache-Control"
    public static let cacheControlValue: String = "no-cache"
    
    /* Copyleaks Error domain */
    public static let errorDomain: String = "com.copyleaks"
    
}

