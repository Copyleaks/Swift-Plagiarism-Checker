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

public class Copyleaks: NSObject {
    
    /**
     You can test the integration with Copyleaks API for free using the sandbox mode.
     You will be able to submit content to scan and get back mock results, simulating
     the way Copyleaks will work.
     */

    private var _sandboxMode: Bool = false
    public var sandboxMode: Bool {
        get {
            return _sandboxMode
        }
    }
    
    /* Product type */

    private var _productType: CopyleaksProductType?
    public var productType: CopyleaksProductType? {
        get {
            return _productType
        }
    }
    
    /* Default Accept Language */
    
    private var _acceptLanguage: String?
    public var acceptLanguage: String? {
        get {
            return _acceptLanguage
        }
    }


    class var sharedSDK: Copyleaks {
        
        struct Static {
            static var instance: Copyleaks?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = Copyleaks()
        }
        return Static.instance!
    }

    public class func configure(
        sandboxMode mode: Bool,
        product: CopyleaksProductType,
        preferLanguage: String = CopyleaksConst.defaultAcceptLanguage)
    {
        self.sharedSDK._sandboxMode = mode
        self.sharedSDK._productType = product
        self.sharedSDK._acceptLanguage = preferLanguage
    }
    
    public class func setProduct(product: CopyleaksProductType) {
        self.sharedSDK._productType = product
    }
    
    
    /* Logout and clear Token info. */
    
    public class func logout(success: () -> Void) {
        CopyleaksToken.clear()
        success()
    }

    
    public class func isAuthorized() -> Bool {
        guard let token = CopyleaksToken.getAccessToken() else {
            return false
        }
        return token.isValid()
    }

}

