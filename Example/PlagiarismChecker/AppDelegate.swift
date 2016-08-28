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

import UIKit
import PlagiarismChecker

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(
        application: UIApplication,
        didFinishLaunchingWithOptions
        launchOptions: [NSObject: AnyObject]?) -> Bool {

        // CopyleaksSDK Configure.
        
        Copyleaks.configure(
            sandboxMode: true,
            product: .Businesses)
        
        
        return true
    }


}

// Utilities

func Alert(title : String, message: String?) {
    let alert = UIAlertController(
        title: title,
        message: message,
        preferredStyle: UIAlertControllerStyle.Alert)
    
    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
    var topController = UIApplication.sharedApplication().keyWindow!.rootViewController! as UIViewController
    
    while ((topController.presentedViewController) != nil) {
        topController = topController.presentedViewController!;
    }
    let app = UIApplication.sharedApplication().delegate as! AppDelegate
    app.window?.rootViewController?.presentViewController(alert, animated:true, completion:nil)
}




